import 'dart:convert';

import 'package:campus_notify/data/inbox_repository.dart';
import 'package:campus_notify/messaging/pending_inbox.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class QueueInbox extends InboxRepository {
  QueueInbox() : super(Dio());
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
  Future<int> receive(Map<String, dynamic> message) async {
    if (message['title'] == 'Ditolak') {
      final request = RequestOptions(path: '/inbox/received');
      throw DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: 422),
        type: DioExceptionType.badResponse,
      );
    }
    delivered.add(message['title'] as String);
    return 9;
  }

  @override
  Future<List<Announcement>> unread() async {
    if (failInbox) throw StateError('API offline');
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
        throwsStateError,
      );
    },
  );
}
