import '../../domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.access,
    required super.refresh,
    super.userId,
  });
  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        access: json['access_token'] as String,
        refresh: json['refresh_token'] as String,
        userId: (json['user'] as Map?)?['id']?.toString(),
      );
  AuthSession toEntity() =>
      AuthSession(access: access, refresh: refresh, userId: userId);
}
