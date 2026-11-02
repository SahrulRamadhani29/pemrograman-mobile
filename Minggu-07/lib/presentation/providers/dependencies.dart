// Composition root: hanya file wiring ini yang mengenal implementasi data.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_client.dart';
import '../../data/api/config.dart';
import '../../data/repositories/api_auth_repository.dart';
import '../../data/repositories/api_device_repository.dart';
import '../../data/repositories/api_inbox_repository.dart';
import '../../data/repositories/firebase_notification_repository.dart';
import '../../data/storage/secure_session_store.dart';
import '../../data/storage/secure_device_identity_store.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/storage/session_store.dart';
import '../../domain/storage/device_identity_store.dart';
import 'session_expiry.dart';

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SecureSessionStore(),
);
final deviceIdentityStoreProvider = Provider<DeviceIdentityStore>(
  (ref) => SecureDeviceIdentityStore(),
);
final rawApiProvider = Provider((ref) => createDio());
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(ref.watch(rawApiProvider)),
);
final apiClientProvider = Provider(
  (ref) => buildApiClient(
    ref.watch(sessionStoreProvider),
    ref.watch(authRepositoryProvider),
    onSessionExpired: () async {
      await ref.read(sessionStoreProvider).clear();
      ref.read(sessionExpiryProvider).add(null);
    },
  ),
);
final inboxRepositoryProvider = Provider<InboxRepository>(
  (ref) => ApiInboxRepository(ref.watch(apiClientProvider)),
);
final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => ApiDeviceRepository(ref.watch(apiClientProvider)),
);
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final service = FirebaseNotificationRepository(
    ref.watch(sessionStoreProvider),
    ref.watch(deviceIdentityStoreProvider),
    ApiAuthRepository(ref.watch(apiClientProvider)),
    ref.watch(deviceRepositoryProvider),
    ref.watch(inboxRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
