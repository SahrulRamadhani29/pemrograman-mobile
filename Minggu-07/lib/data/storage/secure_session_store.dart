import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/storage/session_store.dart';
import '../api/api_errors.dart';

class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage storage;
  @override
  Future<void> save({required String access, required String refresh}) =>
      guardData(() async {
        await storage.write(key: 'access_token', value: access);
        await storage.write(key: 'refresh_token', value: refresh);
      });
  @override
  Future<String?> readAccess() =>
      guardData(() => storage.read(key: 'access_token'));
  @override
  Future<String?> readRefresh() =>
      guardData(() => storage.read(key: 'refresh_token'));
  @override
  Future<String?> readUserId() => guardData(() => storage.read(key: 'user_id'));
  @override
  Future<void> saveUserId(String id) =>
      guardData(() => storage.write(key: 'user_id', value: id));
  @override
  Future<void> clear() => guardData(() async {
    for (final key in ['access_token', 'refresh_token', 'user_id']) {
      await storage.delete(key: key);
    }
  });
}
