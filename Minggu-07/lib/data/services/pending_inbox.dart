import 'dart:convert';

import '../../domain/entities/announcement.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../models/incoming_announcement_model.dart';

class InboxSyncResult {
  const InboxSyncResult(this.items, this.deferredMessages);
  final List<Announcement> items;
  final int deferredMessages;
}

Future<InboxSyncResult> syncPendingInbox({
  required InboxRepository inbox,
  required Iterable<String> pending,
  required Future<void> Function(String encoded) removePending,
}) async {
  var deferred = 0;
  for (final encoded in pending) {
    try {
      final payload = Map<String, dynamic>.from(jsonDecode(encoded) as Map);
      // Versi lama mengantrekan event Firebase tanpa isi sebagai pesan ini.
      final emptyLegacyEvent =
          payload['announcement_id'] == null &&
          payload['title'] == 'Pengumuman' &&
          (payload['body']?.toString().trim().isEmpty ?? true) &&
          const ['0-null', 'null-null'].contains(payload['message_id']);
      if (!emptyLegacyEvent) {
        await inbox.receive(
          IncomingAnnouncementModel.fromJson(payload).toEntity(),
        );
      }
      await removePending(encoded);
    } catch (_) {
      // Pertahankan pesan gagal untuk dicoba lagi, lalu lanjut ke pesan lainnya.
      deferred++;
    }
  }
  // Kegagalan satu pesan tidak boleh menghalangi pembacaan inbox dari server.
  return InboxSyncResult(await inbox.unread(), deferred);
}
