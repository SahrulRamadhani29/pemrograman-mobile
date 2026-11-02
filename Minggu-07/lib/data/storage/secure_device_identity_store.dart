import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../domain/storage/device_identity_store.dart';
import '../api/api_errors.dart';

class SecureDeviceIdentityStore implements DeviceIdentityStore {
  SecureDeviceIdentityStore({FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage storage;
  @override
  Future<String> installationId() => guardData(() async {
    final old = await storage.read(key: 'installation_id');
    if (old != null) return old;
    final id = const Uuid().v4();
    await storage.write(key: 'installation_id', value: id);
    return id;
  });
  @override
  Future<void> saveFcm(String token) =>
      guardData(() => storage.write(key: 'fcm_token', value: token));
  @override
  Future<String?> readFcm() => guardData(() => storage.read(key: 'fcm_token'));
}
