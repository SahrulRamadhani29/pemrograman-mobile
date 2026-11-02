import 'package:dio/dio.dart';

import '../../domain/repositories/device_repository.dart';
import '../api/api_errors.dart';

class ApiDeviceRepository implements DeviceRepository {
  const ApiDeviceRepository(this.dio);
  final Dio dio;
  @override
  Future<int> register({
    required String installationId,
    required String token,
    required String platform,
  }) => guardData(() async {
    final result = await dio.post<Map<String, dynamic>>(
      '/devices',
      data: {
        'installation_id': installationId,
        'fcm_token': token,
        'platform': platform,
      },
    );
    return (result.data?['token_updates'] as num?)?.toInt() ?? 1;
  });
  @override
  Future<void> unregister(String installationId) => guardData(() async {
    await dio.delete<void>(
      '/devices',
      data: {'installation_id': installationId},
    );
  });
}
