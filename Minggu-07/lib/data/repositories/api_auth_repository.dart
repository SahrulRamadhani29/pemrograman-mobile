import 'package:dio/dio.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../api/api_errors.dart';
import '../models/auth_session_model.dart';

class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository(this.dio);
  final Dio dio;
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => guardData(() async {
    final result = await dio.post<Map<String, dynamic>>(
      '/login',
      data: {'email': email.trim(), 'password': password},
    );
    return AuthSessionModel.fromJson(result.data!).toEntity();
  });
  @override
  Future<AuthSession> refresh(String token) => guardData(() async {
    final result = await dio.post<Map<String, dynamic>>(
      '/refresh',
      data: {'refresh_token': token},
    );
    return AuthSessionModel.fromJson(result.data!).toEntity();
  });
  @override
  Future<void> logout(String installationId) => guardData(() async {
    await dio.post<void>('/logout', data: {'installation_id': installationId});
  });
}
