import 'dart:convert';

import 'package:campus_notify/domain/entities/announcement.dart';
import 'package:campus_notify/domain/entities/incoming_announcement.dart';
import 'package:campus_notify/domain/repositories/inbox_repository.dart';
import 'package:campus_notify/domain/failures/app_failure.dart';
import 'package:campus_notify/data/services/pending_inbox.dart';
import 'package:flutter_test/flutter_test.dart';

class QueueInbox implements InboxRepository {
  final delivered = <String>[];
  bool failInbox = false;
  final items = [
    Announcement(
      id: 8,
      title: 'Belum dibaca',
      body: 'Isi',
      createdAt: DateTime(2026),
    ),
  ];

  @override
  Future<int> receive(IncomingAnnouncement message) async {
    if (message.title == 'Ditolak') {
      throw const AppFailure(
        'Periksa kembali data yang diisi.',
        kind: FailureKind.validation,
      );
    }
    delivered.add(message.title);
    return 9;
  }

  @override
  Future<Announcement> detail(int id) async {
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
    items.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<Announcement>> unread() async {
    if (failInbox) {
      throw const AppFailure('API offline', kind: FailureKind.network);
    }
    return items;
  }
}

String queued(String title) => jsonEncode({
  'message_id': 'fcm-$title',
  'announcement_id': null,
  'title': title,
  'body': 'Isi',
});

void main() {
  test(
    'event kosong lama dibersihkan dan pesan berikutnya tetap disinkronkan',
    () async {
      final inbox = QueueInbox();
      final pending = [
        jsonEncode({
          'message_id': '0-null',
          'announcement_id': null,
          'title': 'Pengumuman',
          'body': '',
        }),
        queued('Pesan baru'),
      ];
      final result = await syncPendingInbox(
        inbox: inbox,
        pending: List.of(pending),
        removePending: (encoded) async {
          pending.remove(encoded);
        },
      );
      expect(inbox.delivered, ['Pesan baru']);
      expect(pending, isEmpty);
      expect(result.items.single.id, 8);
      expect(result.deferredMessages, 0);
    },
  );

  test(
    'pesan ditolak 422 tidak menghalangi pesan lain atau pembacaan inbox',
    () async {
      final inbox = QueueInbox();
      final rejected = queued('Ditolak');
      final pending = [rejected, queued('Pesan baru')];
      final result = await syncPendingInbox(
        inbox: inbox,
        pending: List.of(pending),
        removePending: (encoded) async {
          pending.remove(encoded);
        },
      );
      expect(inbox.delivered, ['Pesan baru']);
      expect(pending, [rejected]);
      expect(result.items.single.title, 'Belum dibaca');
      expect(result.deferredMessages, 1);
    },
  );

  test(
    'kegagalan API inbox diteruskan agar UI tidak menampilkan kosong palsu',
    () async {
      final inbox = QueueInbox()..failInbox = true;
      await expectLater(
        syncPendingInbox(
          inbox: inbox,
          pending: [],
          removePending: (_) async {},
        ),
        throwsA(isA<AppFailure>()),
      );
    },
  );
}
