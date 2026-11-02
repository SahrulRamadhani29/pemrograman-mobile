class NotificationState {
  const NotificationState({
    this.tokenPreview = 'Belum tersedia',
    this.status = 'Menyiapkan notifikasi',
    this.tokenUpdates = 0,
    this.tokenRefreshEvents = 0,
    this.unreadCount = 0,
    this.permissionGranted = false,
    this.topicSubscribed = false,
    this.badgeSupported = false,
    this.soundInfo = 'Belum diperiksa',
    this.inboxRevision = 0,
  });
  final String tokenPreview;
  final String status;
  final int tokenUpdates;
  final int tokenRefreshEvents;
  final int unreadCount;
  final bool permissionGranted;
  final bool topicSubscribed;
  final bool badgeSupported;
  final String soundInfo;
  final int inboxRevision;
}
