import '../entities/announcement.dart';
import '../entities/incoming_announcement.dart';

abstract interface class InboxRepository {
  Future<List<Announcement>> unread();
  Future<Announcement> detail(int id);
  Future<void> markRead(int id);
  Future<int> receive(IncomingAnnouncement message);
}
