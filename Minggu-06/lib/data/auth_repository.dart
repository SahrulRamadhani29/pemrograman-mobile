import 'package:dio/dio.dart';

import 'config.dart';

class AuthSession {
  const AuthSession({required this.access, required this.refresh, this.userId});
  final String access;
  final String refresh;
  final String? userId;
  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    access: json['access_token'] as String,
    refresh: json['refresh_token'] as String,
    userId: (json['user'] as Map?)?['id']?.toString(),
  );
}

class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? createDio();
  final Dio _dio;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/login',
      data: {'email': email.trim(), 'password': password},
    );
    return AuthSession.fromJson(response.data!);
  }

  Future<AuthSession> refresh(String token) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/refresh',
      data: {'refresh_token': token},
    );
    return AuthSession.fromJson(response.data!);
  }
}
