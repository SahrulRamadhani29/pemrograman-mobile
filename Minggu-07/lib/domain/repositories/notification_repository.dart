import '../entities/announcement_target.dart';
import '../entities/notification_state.dart';

abstract interface class NotificationRepository {
  NotificationState get state;
  Stream<NotificationState> get changes;
  Stream<AnnouncementTarget> get destinations;
  Future<void> initialize();
  Future<void> activate();
  Future<void> syncInbox();
  Future<void> markRead(int id);
  Future<void> setTopic(bool enabled);
  Future<void> signOut();
  Future<void> rotateRegistrationForTest();
  void resetSession();
  void dispose();
}
