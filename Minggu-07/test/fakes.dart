import 'dart:async';

import 'package:campus_notify/domain/entities/auth_session.dart';
import 'package:campus_notify/domain/entities/announcement.dart';
import 'package:campus_notify/domain/entities/incoming_announcement.dart';
import 'package:campus_notify/domain/entities/announcement_target.dart';
import 'package:campus_notify/domain/entities/notification_state.dart';
import 'package:campus_notify/domain/failures/app_failure.dart';
import 'package:campus_notify/domain/repositories/auth_repository.dart';
import 'package:campus_notify/domain/repositories/inbox_repository.dart';
import 'package:campus_notify/domain/repositories/notification_repository.dart';
import 'package:campus_notify/domain/storage/session_store.dart';

class MemorySessionStore implements SessionStore {
  String? access;
  String? refresh;
  String? user;
  @override
  Future<String?> readAccess() async => access;
  @override
  Future<String?> readRefresh() async => refresh;
  @override
  Future<String?> readUserId() async => user;
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

class MemoryAuthRepository implements AuthRepository {
  int refreshCalls = 0;
  bool fails = false;
  AppFailure? loginFailure;
  String? emailReceived;
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    emailReceived = email;
    if (loginFailure != null) throw loginFailure!;
    return const AuthSession(access: 'access', refresh: 'refresh', userId: '7');
  }

  @override
  Future<AuthSession> refresh(String token) async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (fails) {
      throw const AppFailure(
        'Sesi berakhir',
        kind: FailureKind.unauthenticated,
      );
    }
    return const AuthSession(access: 'fresh', refresh: 'rotated');
  }

  @override
  Future<void> logout(String installationId) async {}
}

class MemoryInboxRepository implements InboxRepository {
  MemoryInboxRepository({List<Announcement>? items}) : items = items ?? [];
  final List<Announcement> items;
  AppFailure? detailFailure;
  final List<int> reads = [];
  @override
  Future<List<Announcement>> unread() async =>
      items.where((item) => !reads.contains(item.id)).toList();
  @override
  Future<Announcement> detail(int id) async {
    if (detailFailure != null) throw detailFailure!;
    final matching = items.where((item) => item.id == id);
    if (matching.isEmpty) {
      throw const AppFailure(
        'Pengumuman tidak ditemukan.',
        kind: FailureKind.notFound,
      );
    }
    return matching.first;
  }

  @override
  Future<void> markRead(int id) async {
    reads.add(id);
  }

  @override
  Future<int> receive(IncomingAnnouncement message) async =>
      message.announcementId ?? 9;
}

class MemoryNotifications implements NotificationRepository {
  MemoryNotifications({this.inbox});
  final InboxRepository? inbox;
  AppFailure? readFailure;
  AppFailure? logoutFailure;
  bool signedOut = false;
  final List<int> reads = [];
  final _states = StreamController<NotificationState>.broadcast();
  final _destinations = StreamController<AnnouncementTarget>.broadcast();
  @override
  NotificationState get state => const NotificationState();
  @override
  Stream<NotificationState> get changes => _states.stream;
  @override
  Stream<AnnouncementTarget> get destinations => _destinations.stream;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> activate() async {}
  @override
  Future<void> syncInbox() async {}
  @override
  Future<void> markRead(int id) async {
    if (readFailure != null) throw readFailure!;
    await inbox?.markRead(id);
    reads.add(id);
  }

  @override
  Future<void> setTopic(bool enabled) async {}
  @override
  Future<void> signOut() async {
    if (logoutFailure != null) throw logoutFailure!;
    signedOut = true;
  }

  @override
  Future<void> rotateRegistrationForTest() async {}
  @override
  void resetSession() {}
  @override
  void dispose() {
    unawaited(_states.close());
    unawaited(_destinations.close());
  }
}
