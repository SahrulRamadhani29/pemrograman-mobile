import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/announcement.dart';
import 'auth_provider.dart';
import 'dependencies.dart';
import 'notification_controller.dart';
export 'auth_provider.dart';
export 'usecase_providers.dart';

final inboxProvider = FutureProvider<List<Announcement>>((ref) async {
  if (ref.watch(authStateProvider).value != true) return [];
  return ref.watch(inboxRepositoryProvider).unread();
});
final pushServiceProvider = Provider<NotificationController>((ref) {
  final controller = NotificationController(
    ref.watch(notificationRepositoryProvider),
    () => ref.invalidate(inboxProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});
