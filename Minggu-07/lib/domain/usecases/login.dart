import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';
import '../storage/session_store.dart';

class Login {
  const Login(this.repository, this.store);
  final AuthRepository repository;
  final SessionStore store;
  Future<AuthSession> call(String email, String password) async {
    final session = await repository.login(
      email: email.trim(),
      password: password,
    );
    await store.save(access: session.access, refresh: session.refresh);
    if (session.userId != null) await store.saveUserId(session.userId!);
    return session;
  }
}
