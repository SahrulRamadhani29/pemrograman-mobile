import '../repositories/notification_repository.dart';
import '../storage/session_store.dart';

class Logout {
  const Logout(this.notifications, this.store);
  final NotificationRepository notifications;
  final SessionStore store;
  Future<void> call() async {
    await notifications.signOut();
    await store.clear();
  }
}
