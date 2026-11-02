import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legacy_vivo_badge/legacy_vivo_badge.dart';

import '../data/inbox_repository.dart';
import '../data/token_store.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import 'launcher_badge.dart';
import 'pending_inbox.dart';

const campusChannel = AndroidNotificationChannel(
  'pengumuman',
  'Pengumuman Kampus',
  description: 'Informasi kuliah dan kegiatan kampus',
  importance: Importance.high,
  playSound: true,
  showBadge: true,
);

Future<void> savePendingMessage(RemoteMessage message) async {
  final route = routeFromMessage(message.data);
  final id = int.tryParse(route.split('/').last);
  final title = (message.notification?.title ?? message.data['title'] ?? '')
      .toString();
  final body = (message.notification?.body ?? message.data['body'] ?? '')
      .toString();
  if (id == null && title.trim().isEmpty && body.trim().isEmpty) return;
  final owner = await TokenStore().readUserId();
  if (owner == null) return;
  final prefs = SharedPreferencesAsync();
  final key = 'push-pending-$owner';
  final items = await prefs.getStringList(key) ?? [];
  final payload = {
    'message_id':
        message.messageId ??
        '${message.sentTime?.millisecondsSinceEpoch}-${message.notification?.title}',
    'announcement_id': id,
    'title': title.trim().isEmpty ? 'Pengumuman' : title,
    'body': body,
  };
  if (!items.any(
    (item) => jsonDecode(item)['message_id'] == payload['message_id'],
  )) {
    await prefs.setStringList(key, [...items, jsonEncode(payload)]);
    final unread = await prefs.getStringList('unread-ids-$owner') ?? [];
    final read = await prefs.getStringList('read-ids-$owner') ?? [];
    final itemKey = id?.toString() ?? payload['message_id'].toString();
    if (!read.contains(itemKey) && !unread.contains(itemKey)) {
      unread.add(itemKey);
      await prefs.setStringList('unread-ids-$owner', unread);
      if (await LauncherBadge.isSupported()) {
        await LauncherBadge.update(unread.length);
      }
    }
  }
}

// Android menjalankannya pada isolate terpisah. Tidak ada BuildContext/Riverpod.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await savePendingMessage(message);
  // notification+data ditampilkan Android sendiri. Jangan tampilkan banner kedua.
}

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(
    ref.watch(tokenStoreProvider),
    ref.watch(apiClientProvider),
    ref.watch(inboxRepositoryProvider),
    () => ref.invalidate(inboxProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

class PushService extends ChangeNotifier {
  PushService(this.store, this.api, this.inbox, this.onInboxChanged);
  final TokenStore store;
  final Dio api;
  final InboxRepository inbox;
  final VoidCallback onInboxChanged;
  final local = FlutterLocalNotificationsPlugin();
  final routes = StreamController<String>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  String tokenPreview = 'Belum tersedia';
  String status = 'Menyiapkan notifikasi';
  int tokenUpdates = 0;
  int tokenRefreshEvents = 0;
  int unreadCount = 0;
  bool permissionGranted = false;
  bool topicSubscribed = false;
  bool badgeSupported = false;
  String soundInfo = 'Belum diperiksa';
  String? _activeUser;
  RemoteMessage? _initial;
  String? _localInitial;
  Future<void>? _draining;

  Future<void> initialize() async {
    await local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) routes.add(routeFromMessage({'route': payload}));
      },
    );
    await local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(campusChannel);
    badgeSupported = await LauncherBadge.isSupported();
    _initial = await FirebaseMessaging.instance.getInitialMessage();
    final launch = await local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      _localInitial = launch?.notificationResponse?.payload;
    }
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((message) {
        unawaited(_foreground(message));
      }),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        unawaited(_opened(message));
      }),
    );
    _subscriptions.add(
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        tokenRefreshEvents++;
        unawaited(
          _register(token).catchError((Object _) {
            status = 'Token baru menunggu koneksi API';
            notifyListeners();
          }),
        );
      }),
    );
    // iOS: banner foreground ditampilkan local, bukan ganda oleh Firebase.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );
    status = 'Siap setelah login';
    notifyListeners();
  }

  Future<void> activate() async {
    final user = await store.readUserId();
    if (user == null || _activeUser == user) return;
    _activeUser = user;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _register(token);
      final subscribed =
          await SharedPreferencesAsync().getBool('topic-$user') ?? true;
      await setTopic(subscribed);
      await syncInbox();
      final initial = _initial;
      _initial = null;
      if (initial != null) await _opened(initial);
      if (_localInitial != null) {
        routes.add(routeFromMessage({'route': _localInitial}));
        _localInitial = null;
      }
      status = permissionGranted
          ? 'Notifikasi aktif'
          : 'Izin notifikasi belum diberikan';
    } catch (_) {
      _activeUser = null;
      status = 'Belum tersambung. Tarik daftar untuk mencoba lagi.';
    }
    notifyListeners();
  }

  Future<void> _register(String token) async {
    await store.saveFcm(token);
    tokenPreview =
        '${token.substring(0, token.length < 12 ? token.length : 12)}...';
    if (await store.readAccess() == null) return;
    final result = await api.post<Map<String, dynamic>>(
      '/devices',
      data: {
        'installation_id': await store.installationId(),
        'fcm_token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
    );
    tokenUpdates = (result.data?['token_updates'] as num?)?.toInt() ?? 1;
    notifyListeners();
  }

  Future<void> setTopic(bool enabled) async {
    if (enabled) {
      await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(
        'pengumuman-kampus',
      );
    }
    topicSubscribed = enabled;
    final user = await store.readUserId();
    if (user != null) {
      await SharedPreferencesAsync().setBool('topic-$user', enabled);
    }
    notifyListeners();
  }

  Future<void> _foreground(RemoteMessage message) async {
    await savePendingMessage(message);
    try {
      await syncInbox();
    } catch (_) {
      /* Tetap tampilkan push ketika API offline. */
    }
    final route = routeFromMessage(message.data);
    final id = int.tryParse(route.split('/').last) ?? message.hashCode.abs();
    await local.show(
      id: id,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      payload: route,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'pengumuman',
          'Pengumuman Kampus',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          icon: 'ic_notification',
          number: unreadCount,
          channelShowBadge: true,
          tag: 'announcement-$id',
          autoCancel: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          badgeNumber: unreadCount,
        ),
      ),
    );
  }

  Future<void> _opened(RemoteMessage message) async {
    await savePendingMessage(message);
    try {
      await syncInbox();
    } catch (_) {
      /* Detail menampilkan tombol coba lagi. */
    }
    routes.add(routeFromMessage(message.data));
  }

  Future<void> syncInbox() async {
    final existing = _draining;
    if (existing != null) return existing;
    final operation = _drain();
    _draining = operation;
    try {
      await operation;
    } finally {
      _draining = null;
    }
  }

  Future<void> _drain() async {
    final user = await store.readUserId();
    if (user == null) return;
    final prefs = SharedPreferencesAsync();
    final key = 'push-pending-$user';
    final pending = await prefs.getStringList(key) ?? [];
    final result = await syncPendingInbox(
      inbox: inbox,
      pending: pending,
      removePending: (encoded) async {
        final current = await prefs.getStringList(key) ?? [];
        current.remove(encoded);
        await prefs.setStringList(key, current);
      },
    );
    final items = result.items;
    await prefs.setStringList(
      'unread-ids-$user',
      items.map((item) => item.id.toString()).toList(),
    );
    await updateBadge(items.length);
    onInboxChanged();
    if (result.deferredMessages > 0) {
      status = 'Ada pesan menunggu sinkronisasi';
      notifyListeners();
    }
  }

  Future<void> updateBadge(int count) async {
    unreadCount = count;
    if (badgeSupported) {
      try {
        await LauncherBadge.update(count);
      } catch (_) {
        /* Ikon lonceng tetap tersedia. */
      }
    }
    if (Platform.isAndroid) {
      final audio = await LegacyVivoBadge.audioStatus();
      soundInfo = audio['ringer_normal'] == true
          ? 'Mode bunyi, volume ${audio['notification_volume']}/${audio['max_volume']}'
          : 'Mode diam atau getar aktif';
    }
    notifyListeners();
  }

  Future<void> markRead(int id) async {
    await inbox.markRead(id);
    final user = await store.readUserId();
    if (user != null) {
      final prefs = SharedPreferencesAsync();
      final read = await prefs.getStringList('read-ids-$user') ?? [];
      if (!read.contains('$id')) read.add('$id');
      await prefs.setStringList(
        'read-ids-$user',
        read.length > 500 ? read.sublist(read.length - 500) : read,
      );
    }
    await local.cancel(id: id, tag: 'announcement-$id');
    await syncInbox();
    if (unreadCount == 0) await local.cancelAll();
  }

  Future<void> signOut() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
    await api.delete(
      '/devices',
      data: {'installation_id': await store.installationId()},
    );
    await api.post(
      '/logout',
      data: {'installation_id': await store.installationId()},
    );
    _activeUser = null;
    topicSubscribed = false;
    await local.cancelAll();
    await updateBadge(0);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(routes.close());
    super.dispose();
  }

  void resetSession() {
    _activeUser = null;
  }

  Future<void> rotateRegistrationForTest() async {
    if (!kDebugMode) return;
    await FirebaseMessaging.instance.deleteToken();
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _register(token);
    notifyListeners();
  }
}
