class AuthSession {
  const AuthSession({required this.access, required this.refresh, this.userId});
  final String access;
  final String refresh;
  final String? userId;
}
