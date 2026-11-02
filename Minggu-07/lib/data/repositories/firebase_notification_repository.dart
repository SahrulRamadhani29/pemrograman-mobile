import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legacy_vivo_badge/legacy_vivo_badge.dart';

import '../../domain/entities/announcement_target.dart';
import '../../domain/entities/notification_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/storage/session_store.dart';
import '../../domain/storage/device_identity_store.dart';
import '../api/api_errors.dart';
import '../services/launcher_badge.dart';
import '../services/pending_inbox.dart';
import '../services/push_background_handler.dart';

const campusChannel = AndroidNotificationChannel(
  'pengumuman',
  'Pengumuman Kampus',
  description: 'Informasi kuliah dan kegiatan kampus',
  importance: Importance.high,
  playSound: true,
  showBadge: true,
);

class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository(
    this.store,
    this.identity,
    this.auth,
    this.devices,
    this.inbox,
  );
  final SessionStore store;
  final DeviceIdentityStore identity;
  final AuthRepository auth;
  final DeviceRepository devices;
  final InboxRepository inbox;
  final local = FlutterLocalNotificationsPlugin();
  final _destinations = StreamController<AnnouncementTarget>.broadcast();
  final _changes = StreamController<NotificationState>.broadcast();
  int _inboxRevision = 0;
  @override
  Stream<AnnouncementTarget> get destinations => _destinations.stream;
  @override
  Stream<NotificationState> get changes => _changes.stream;
  @override
  NotificationState get state => NotificationState(
    tokenPreview: tokenPreview,
    status: status,
    tokenUpdates: tokenUpdates,
    tokenRefreshEvents: tokenRefreshEvents,
    unreadCount: unreadCount,
    permissionGranted: permissionGranted,
    topicSubscribed: topicSubscribed,
    badgeSupported: badgeSupported,
    soundInfo: soundInfo,
    inboxRevision: _inboxRevision,
  );
  void _publish() {
    if (!_changes.isClosed) _changes.add(state);
  }

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

  @override
  Future<void> initialize() => guardData(() => _initialize());

  Future<void> _initialize() async {
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
        if (payload != null) {
          _destinations.add(AnnouncementTarget.fromRoute(payload));
        }
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
            _publish();
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
    _publish();
  }

  @override
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
        _destinations.add(AnnouncementTarget.fromRoute(_localInitial));
        _localInitial = null;
      }
      status = permissionGranted
          ? 'Notifikasi aktif'
          : 'Izin notifikasi belum diberikan';
    } catch (_) {
      _activeUser = null;
      status = 'Belum tersambung. Tarik daftar untuk mencoba lagi.';
    }
    _publish();
  }

  Future<void> _register(String token) async {
    await identity.saveFcm(token);
    tokenPreview =
        '${token.substring(0, token.length < 12 ? token.length : 12)}...';
    if (await store.readAccess() == null) return;
    tokenUpdates = await devices.register(
      installationId: await identity.installationId(),
      token: token,
      platform: Platform.isIOS ? 'ios' : 'android',
    );
    _publish();
  }

  @override
  Future<void> setTopic(bool enabled) => guardData(() => _setTopic(enabled));

  Future<void> _setTopic(bool enabled) async {
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
    _publish();
  }

  Future<void> _foreground(RemoteMessage message) async {
    await savePendingMessage(message);
    try {
      await syncInbox();
    } catch (_) {
      /* Tetap tampilkan push ketika API offline. */
    }
    final route = AnnouncementTarget.fromRoute(
      message.data['route']?.toString(),
    ).path;
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
    _destinations.add(
      AnnouncementTarget.fromRoute(message.data['route']?.toString()),
    );
  }

  @override
  Future<void> syncInbox() => guardData(() => _syncInbox());

  Future<void> _syncInbox() async {
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
    _inboxRevision++;
    _publish();
    if (result.deferredMessages > 0) {
      status = 'Ada pesan menunggu sinkronisasi';
      _publish();
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
    _publish();
  }

  @override
  Future<void> markRead(int id) => guardData(() => _markRead(id));

  Future<void> _markRead(int id) async {
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

  @override
  Future<void> signOut() => guardData(() => _signOut());

  Future<void> _signOut() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
    final installationId = await identity.installationId();
    await devices.unregister(installationId);
    await auth.logout(installationId);
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
    unawaited(_destinations.close());
    unawaited(_changes.close());
  }

  @override
  void resetSession() {
    _activeUser = null;
  }

  @override
  Future<void> rotateRegistrationForTest() =>
      guardData(() => _rotateRegistrationForTest());

  Future<void> _rotateRegistrationForTest() async {
    if (!kDebugMode) return;
    await FirebaseMessaging.instance.deleteToken();
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _register(token);
    _publish();
  }
}
