import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/domain/entities/announcement.dart';
import 'package:campus_notify/domain/failures/app_failure.dart';
import 'package:campus_notify/domain/usecases/login.dart';
import 'package:campus_notify/domain/usecases/logout.dart';
import 'package:campus_notify/domain/usecases/open_announcement.dart';

import 'fakes.dart';

void main() {
  test(
    'Login menyimpan sesi dan pemilik akun setelah autentikasi berhasil',
    () async {
      final repo = MemoryAuthRepository();
      final store = MemorySessionStore();
      final result = await Login(repo, store)(
        ' rama@polinema.ac.id ',
        'valid-password',
      );
      expect(result.userId, '7');
      expect(repo.emailReceived, 'rama@polinema.ac.id');
      expect(store.access, 'access');
      expect(store.refresh, 'refresh');
      expect(store.user, '7');
    },
  );
  test('Login gagal mengembalikan Failure dan tidak membuat sesi', () async {
    final failure = const AppFailure(
      'Kata sandi salah',
      kind: FailureKind.unauthenticated,
    );
    final repo = MemoryAuthRepository()..loginFailure = failure;
    final store = MemorySessionStore();
    await expectLater(
      Login(repo, store)('rama@polinema.ac.id', 'wrong'),
      throwsA(same(failure)),
    );
    expect(store.access, isNull);
    expect(store.refresh, isNull);
    expect(store.user, isNull);
  });
  test('OpenAnnouncement memuat detail lalu menyimpan tanda baca', () async {
    final item = Announcement(
      id: 8,
      title: 'Kabar',
      body: 'Isi',
      createdAt: DateTime(2026),
    );
    final inbox = MemoryInboxRepository(items: [item]);
    final notifications = MemoryNotifications(inbox: inbox);
    addTearDown(notifications.dispose);
    expect(await OpenAnnouncement(inbox, notifications)(8), same(item));
    expect(inbox.reads, [8]);
    expect(notifications.reads, [8]);
    expect(await inbox.unread(), isEmpty);
  });
  test('Detail gagal tidak boleh menandai pesan dibaca', () async {
    final failure = const AppFailure('Gagal memuat', kind: FailureKind.network);
    final inbox = MemoryInboxRepository()..detailFailure = failure;
    final notifications = MemoryNotifications(inbox: inbox);
    addTearDown(notifications.dispose);
    await expectLater(
      OpenAnnouncement(inbox, notifications)(8),
      throwsA(same(failure)),
    );
    expect(inbox.reads, isEmpty);
    expect(notifications.reads, isEmpty);
  });
  test(
    'Kegagalan tanda baca tetap menjadi Failure dan pesan tetap belum dibaca',
    () async {
      final item = Announcement(
        id: 8,
        title: 'Kabar',
        body: 'Isi',
        createdAt: DateTime(2026),
      );
      final inbox = MemoryInboxRepository(items: [item]);
      final notifications = MemoryNotifications(inbox: inbox)
        ..readFailure = const AppFailure(
          'API offline',
          kind: FailureKind.network,
        );
      addTearDown(notifications.dispose);
      await expectLater(
        OpenAnnouncement(inbox, notifications)(8),
        throwsA(isA<AppFailure>()),
      );
      expect(await inbox.unread(), [item]);
    },
  );
  test('Logout melepas notifikasi kemudian membersihkan sesi', () async {
    final store = MemorySessionStore()..access = 'active';
    final notifications = MemoryNotifications();
    addTearDown(notifications.dispose);
    await Logout(notifications, store)();
    expect(notifications.signedOut, isTrue);
    expect(store.access, isNull);
  });
  test(
    'Logout gagal tetap memberi Failure dan mempertahankan sesi untuk retry',
    () async {
      final store = MemorySessionStore()..access = 'active';
      final notifications = MemoryNotifications()
        ..logoutFailure = const AppFailure(
          'API offline',
          kind: FailureKind.network,
        );
      addTearDown(notifications.dispose);
      await expectLater(
        Logout(notifications, store)(),
        throwsA(isA<AppFailure>()),
      );
      expect(store.access, 'active');
    },
  );
}
