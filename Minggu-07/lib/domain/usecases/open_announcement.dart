import '../entities/announcement.dart';
import '../repositories/inbox_repository.dart';
import '../repositories/notification_repository.dart';

class OpenAnnouncement {
  const OpenAnnouncement(this.inbox, this.notifications);
  final InboxRepository inbox;
  final NotificationRepository notifications;
  Future<Announcement> call(int id) async {
    final item = await inbox.detail(id);
    await notifications.markRead(id);
    return item;
  }
}
