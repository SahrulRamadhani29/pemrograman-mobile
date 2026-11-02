import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<String?> readAccess() => _storage.read(key: 'access_token');
  Future<String?> readRefresh() => _storage.read(key: 'refresh_token');
  Future<String?> readUserId() => _storage.read(key: 'user_id');
  Future<void> saveUserId(String id) =>
      _storage.write(key: 'user_id', value: id);
  Future<void> saveFcm(String token) =>
      _storage.write(key: 'fcm_token', value: token);
  Future<String?> readFcm() => _storage.read(key: 'fcm_token');

  Future<String> installationId() async {
    final old = await _storage.read(key: 'installation_id');
    if (old != null) return old;
    final id = const Uuid().v4();
    await _storage.write(key: 'installation_id', value: id);
    return id;
  }

  Future<void> clear() async {
    for (final key in ['access_token', 'refresh_token', 'user_id']) {
      await _storage.delete(key: key);
    }
  }
}
