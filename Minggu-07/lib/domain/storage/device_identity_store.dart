abstract interface class DeviceIdentityStore {
  Future<String> installationId();
  Future<void> saveFcm(String token);
  Future<String?> readFcm();
}
