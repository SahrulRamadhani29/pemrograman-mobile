import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/settings_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (_, state) {
      final auth = ref.read(authStateProvider);
      final login = state.matchedLocation == AppRoutes.login;
      if (auth.isLoading) return login ? null : AppRoutes.loading;
      if (auth.value != true) {
        if (login) return null;
        final next = routeFromMessage({'route': state.uri.path});
        return '${AppRoutes.login}?next=${Uri.encodeComponent(next)}';
      }
      if (login) {
        return routeFromMessage({'route': state.uri.queryParameters['next']});
      }
      if (state.matchedLocation == AppRoutes.loading) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.loading,
        builder: (_, _) =>
            const Scaffold(body: Center(child: CupertinoActivityIndicator())),
      ),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.announcement,
        pageBuilder: (_, state) => CupertinoPage(
          key: state.pageKey,
          child: AnnouncementPage(
            id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          ),
        ),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class CampusApp extends ConsumerStatefulWidget {
  const CampusApp({super.key});
  @override
  ConsumerState<CampusApp> createState() => _CampusAppState();
}

class _CampusAppState extends ConsumerState<CampusApp> {
  StreamSubscription<String>? _routes;
  ProviderSubscription<AsyncValue<bool>>? _auth;
  @override
  void initState() {
    super.initState();
    final push = ref.read(pushServiceProvider);
    final ready = push.initialize();
    _routes = push.routes.stream.listen((route) {
      if (mounted) ref.read(routerProvider).go(route);
    });
    _auth = ref.listenManual(authStateProvider, (_, value) {
      if (value.value == true) {
        unawaited(ready.then((_) => push.activate()));
      } else if (value is AsyncData<bool>) {
        push.resetSession();
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    unawaited(_routes?.cancel());
    _auth?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F5F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2369F5),
          primary: const Color(0xFF2369F5),
          surface: Colors.white,
        ),
        fontFamily: 'sans-serif',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F5F9),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE6E8EF)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
