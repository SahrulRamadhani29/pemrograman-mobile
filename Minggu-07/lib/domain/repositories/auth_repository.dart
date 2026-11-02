import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> refresh(String refreshToken);
  Future<void> logout(String installationId);
}
