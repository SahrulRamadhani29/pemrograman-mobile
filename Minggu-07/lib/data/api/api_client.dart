import 'package:dio/dio.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/failures/app_failure.dart';
import 'config.dart';
import '../../domain/storage/session_store.dart';

Dio buildApiClient(
  SessionStore store,
  AuthRepository auth, {
  required Future<void> Function() onSessionExpired,
  Dio? client,
}) {
  final dio = client ?? createDio();
  Future<void>? refreshing;
  Future<void> refreshOnce() async {
    final token = await store.readRefresh();
    if (token == null) {
      throw const AppFailure(
        'Sesi berakhir',
        kind: FailureKind.unauthenticated,
      );
    }
    final session = await auth.refresh(token);
    await store.save(access: session.access, refresh: session.refresh);
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await store.readAccess();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) return handler.next(error);
        if (error.requestOptions.extra['retried'] == true) {
          await store.clear();
          await onSessionExpired();
          return handler.next(error);
        }
        try {
          final pending = refreshing ??= refreshOnce();
          try {
            await pending;
          } finally {
            if (identical(refreshing, pending)) refreshing = null;
          }
          final request = error.requestOptions;
          request.extra['retried'] = true;
          request.headers['Authorization'] =
              'Bearer ${await store.readAccess()}';
          final response = await dio.fetch<dynamic>(request);
          return handler.resolve(response);
        } catch (failure) {
          // Koneksi terputus bukan bukti refresh token tidak valid.
          if (failure is AppFailure &&
              (failure.kind == FailureKind.unauthenticated ||
                  failure.kind == FailureKind.validation)) {
            await store.clear();
            await onSessionExpired();
          }
          return handler.next(error);
        }
      },
    ),
  );
  return dio;
}
