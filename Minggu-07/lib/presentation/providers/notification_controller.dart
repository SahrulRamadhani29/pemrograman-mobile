import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/announcement_target.dart';
import '../../domain/entities/notification_state.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  NotificationController(this.repository, this.onInboxChanged)
    : _state = repository.state {
    _subscription = repository.changes.listen((value) {
      final changed = value.inboxRevision != _state.inboxRevision;
      _state = value;
      if (changed) onInboxChanged();
      notifyListeners();
    });
  }
  final NotificationRepository repository;
  final VoidCallback onInboxChanged;
  late final StreamSubscription<NotificationState> _subscription;
  NotificationState _state;
  String get tokenPreview => _state.tokenPreview;
  String get status => _state.status;
  int get tokenUpdates => _state.tokenUpdates;
  int get tokenRefreshEvents => _state.tokenRefreshEvents;
  int get unreadCount => _state.unreadCount;
  bool get permissionGranted => _state.permissionGranted;
  bool get topicSubscribed => _state.topicSubscribed;
  bool get badgeSupported => _state.badgeSupported;
  String get soundInfo => _state.soundInfo;
  Stream<AnnouncementTarget> get destinations => repository.destinations;
  Future<void> initialize() => repository.initialize();
  Future<void> activate() => repository.activate();
  Future<void> syncInbox() => repository.syncInbox();
  Future<void> setTopic(bool enabled) => repository.setTopic(enabled);
  Future<void> rotateRegistrationForTest() =>
      repository.rotateRegistrationForTest();
  void resetSession() => repository.resetSession();
  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
