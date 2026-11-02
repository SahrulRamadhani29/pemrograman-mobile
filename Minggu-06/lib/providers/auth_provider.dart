import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/inbox_repository.dart';
import '../data/token_store.dart';

final tokenStoreProvider = Provider((ref) => TokenStore());
final authRepositoryProvider = Provider((ref) => AuthRepository());
final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);
final apiClientProvider = Provider(
  (ref) => buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider),
    onSessionExpired: () => ref.read(authStateProvider.notifier).expire(),
  ),
);
final inboxRepositoryProvider = Provider(
  (ref) => InboxRepository(ref.watch(apiClientProvider)),
);
final inboxProvider = FutureProvider<List<Announcement>>((ref) async {
  if (ref.watch(authStateProvider).value != true) return [];
  return ref.watch(inboxRepositoryProvider).unread();
});

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      await ref.watch(tokenStoreProvider).readAccess() != null;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      final store = ref.read(tokenStoreProvider);
      await store.save(access: session.access, refresh: session.refresh);
      if (session.userId != null) await store.saveUserId(session.userId!);
      return true;
    });
  }

  Future<void> expire() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }
}
