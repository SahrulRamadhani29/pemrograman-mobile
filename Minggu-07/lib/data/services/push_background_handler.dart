import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/announcement_target.dart';
import '../storage/secure_session_store.dart';
import 'launcher_badge.dart';

Future<void> savePendingMessage(RemoteMessage message) async {
  final route = AnnouncementTarget.fromRoute(message.data['route']?.toString())
      .path;
  final id = int.tryParse(route.split('/').last);
  final title = (message.notification?.title ?? message.data['title'] ?? '')
      .toString();
  final body = (message.notification?.body ?? message.data['body'] ?? '')
      .toString();
  if (id == null && title.trim().isEmpty && body.trim().isEmpty) return;
  final owner = await SecureSessionStore().readUserId();
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
