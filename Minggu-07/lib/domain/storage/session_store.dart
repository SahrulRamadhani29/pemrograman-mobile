abstract interface class SessionStore {
  Future<void> save({required String access, required String refresh});
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<String?> readUserId();
  Future<void> saveUserId(String id);
  Future<void> clear();
}
