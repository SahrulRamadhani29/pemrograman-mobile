class IncomingAnnouncement {
  const IncomingAnnouncement({
    required this.messageId,
    this.announcementId,
    required this.title,
    required this.body,
  });
  final String messageId;
  final int? announcementId;
  final String title;
  final String body;
}
