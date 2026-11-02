import 'dart:typed_data';

import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/inbox_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/pages/login_page.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:campus_notify/routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryTokenStore extends TokenStore {
  String? access;
  String? refresh;
  String? user;
  @override
  Future<String?> readAccess() async => access;
  @override
  Future<String?> readRefresh() async => refresh;
  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> saveUserId(String id) async {
    user = id;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    user = null;
  }
}

class FakeAuth extends AuthRepository {
  int refreshCalls = 0;
  bool fails = false;
  @override
  Future<AuthSession> refresh(String token) async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (fails) throw StateError('Expired');
    return const AuthSession(access: 'fresh', refresh: 'rotated');
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async =>
      const AuthSession(access: 'access', refresh: 'refresh', userId: '7');
}

class EmptyInbox extends InboxRepository {
  EmptyInbox() : super(Dio());
  @override
  Future<List<Announcement>> unread() async => [];
}

class TestAdapter implements HttpClientAdapter {
  TestAdapter(this.answer);
  final Future<ResponseBody> Function(RequestOptions request) answer;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => answer(options);
  @override
  void close({bool force = false}) {}
}

void main() {
  test('parsing route kosong, tanpa slash, dan id pengumuman', () {
    expect(routeFromMessage({}), '/');
    expect(
      routeFromMessage({'route': 'pengumuman/3', 'id': '3'}),
      '/pengumuman/3',
    );
    expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
  });
  test('payload tidak dapat membuka URL luar atau route sembarang', () {
    for (final route in [
      'https://evil.test',
      '//evil.test',
      '/login',
      '/pengumuman/../pengaturan',
      '/pengumuman/0',
    ]) {
      expect(routeFromMessage({'route': route}), '/');
    }
  });
  test('provider memulihkan login dari secure token store palsu', () async {
    final store = MemoryTokenStore()..access = 'existing';
    final container = ProviderContainer(
      overrides: [tokenStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    expect(await container.read(authStateProvider.future), isTrue);
    await container.read(authStateProvider.notifier).expire();
    expect(container.read(authStateProvider).value, isFalse);
    expect(store.access, isNull);
  });
  test('login menyimpan kedua token dan pemilik sesi', () async {
    final store = MemoryTokenStore();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(FakeAuth()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container
        .read(authStateProvider.notifier)
        .login('user@kampus.test', 'password');
    expect(store.access, 'access');
    expect(store.refresh, 'refresh');
    expect(store.user, '7');
    expect(container.read(authStateProvider).value, isTrue);
  });
  test('logout saat inbox aktif tidak membuat dependensi melingkar', () async {
    final store = MemoryTokenStore()..access = 'existing';
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        inboxRepositoryProvider.overrideWithValue(EmptyInbox()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    final subscription = container.listen(inboxProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(inboxProvider.future);
    await expectLater(
      container.read(authStateProvider.notifier).expire(),
      completes,
    );
    expect(container.read(authStateProvider).value, isFalse);
    expect(await container.read(inboxProvider.future), isEmpty);
    expect(store.access, isNull);
  });
  test(
    '401 me-refresh token, menyimpan rotasi, dan mengulang sekali',
    () async {
      final store = MemoryTokenStore()
        ..access = 'old'
        ..refresh = 'valid';
      final auth = FakeAuth();
      var requests = 0;
      final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
      dio.httpClientAdapter = TestAdapter((request) async {
        requests++;
        return ResponseBody.fromString(
          '{}',
          request.headers['Authorization'] == 'Bearer fresh' ? 200 : 401,
        );
      });
      buildApiClient(store, auth, onSessionExpired: () async {}, client: dio);
      expect((await dio.get<dynamic>('/me')).statusCode, 200);
      expect(requests, 2);
      expect(auth.refreshCalls, 1);
      expect(store.refresh, 'rotated');
    },
  );
  test('401 berulang berhenti setelah retry dan membersihkan sesi', () async {
    final store = MemoryTokenStore()
      ..access = 'old'
      ..refresh = 'valid';
    final auth = FakeAuth();
    var requests = 0;
    var expired = false;
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
    dio.httpClientAdapter = TestAdapter((_) async {
      requests++;
      return ResponseBody.fromString('{}', 401);
    });
    buildApiClient(
      store,
      auth,
      onSessionExpired: () async {
        expired = true;
      },
      client: dio,
    );
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    expect(requests, 2);
    expect(auth.refreshCalls, 1);
    expect(expired, isTrue);
    expect(store.access, isNull);
  });
  test('refresh gagal memaksa login ulang', () async {
    final store = MemoryTokenStore()
      ..access = 'old'
      ..refresh = 'invalid';
    final auth = FakeAuth()..fails = true;
    var expired = false;
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
    dio.httpClientAdapter = TestAdapter(
      (_) async => ResponseBody.fromString('{}', 401),
    );
    buildApiClient(
      store,
      auth,
      onSessionExpired: () async {
        expired = true;
      },
      client: dio,
    );
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    expect(expired, isTrue);
    expect(store.refresh, isNull);
    expect(auth.refreshCalls, 1);
  });
  test('dua request bersamaan berbagi satu proses refresh', () async {
    final store = MemoryTokenStore()
      ..access = 'old'
      ..refresh = 'valid';
    final auth = FakeAuth();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
    dio.httpClientAdapter = TestAdapter(
      (request) async => ResponseBody.fromString(
        '{}',
        request.headers['Authorization'] == 'Bearer fresh' ? 200 : 401,
      ),
    );
    buildApiClient(store, auth, onSessionExpired: () async {}, client: dio);
    await Future.wait([dio.get<dynamic>('/me'), dio.get<dynamic>('/inbox')]);
    expect(auth.refreshCalls, 1);
  });
  test('timeout dan offline dipetakan menjadi pesan yang dapat dibaca', () {
    final request = RequestOptions(path: '/me');
    expect(
      friendlyApiError(
        DioException(
          requestOptions: request,
          type: DioExceptionType.connectionTimeout,
        ),
      ),
      contains('belum merespons'),
    );
    expect(
      friendlyApiError(
        DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        ),
      ),
      contains('Periksa koneksi'),
    );
  });
  testWidgets('form login memvalidasi email dan password tanpa Firebase', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(MemoryTokenStore())],
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login')));
    await tester.pump();
    expect(find.text('Masukkan email yang valid.'), findsOneWidget);
    expect(find.text('Minimal 6 karakter.'), findsOneWidget);
  });
}
