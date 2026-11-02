abstract interface class DeviceRepository {
  Future<int> register({
    required String installationId,
    required String token,
    required String platform,
  });
  Future<void> unregister(String installationId);
}
