import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/open_announcement.dart';
import 'dependencies.dart';

final loginUseCaseProvider = Provider(
  (ref) =>
      Login(ref.watch(authRepositoryProvider), ref.watch(sessionStoreProvider)),
);
final logoutUseCaseProvider = Provider(
  (ref) => Logout(
    ref.watch(notificationRepositoryProvider),
    ref.watch(sessionStoreProvider),
  ),
);
final openAnnouncementProvider = Provider(
  (ref) => OpenAnnouncement(
    ref.watch(inboxRepositoryProvider),
    ref.watch(notificationRepositoryProvider),
  ),
);
