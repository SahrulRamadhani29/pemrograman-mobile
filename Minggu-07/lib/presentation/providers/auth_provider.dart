import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dependencies.dart';
import 'session_expiry.dart';
import 'usecase_providers.dart';

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final subscription = ref.watch(sessionExpiryProvider).stream.listen((_) {
      state = const AsyncData(false);
    });
    ref.onDispose(() => unawaited(subscription.cancel()));
    return await ref.watch(sessionStoreProvider).readAccess() != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(loginUseCaseProvider)(email, password);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)();
    state = const AsyncData(false);
  }

  Future<void> expire() async {
    await ref.read(sessionStoreProvider).clear();
    state = const AsyncData(false);
  }
}
