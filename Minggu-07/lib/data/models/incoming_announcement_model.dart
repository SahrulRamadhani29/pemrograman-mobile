import '../../domain/entities/incoming_announcement.dart';

class IncomingAnnouncementModel extends IncomingAnnouncement {
  const IncomingAnnouncementModel({
    required super.messageId,
    super.announcementId,
    required super.title,
    required super.body,
  });
  factory IncomingAnnouncementModel.fromJson(Map<String, dynamic> json) =>
      IncomingAnnouncementModel(
        messageId: json['message_id'] as String,
        announcementId: (json['announcement_id'] as num?)?.toInt(),
        title: json['title'] as String,
        body: json['body']?.toString() ?? '',
      );
  factory IncomingAnnouncementModel.fromEntity(IncomingAnnouncement item) =>
      IncomingAnnouncementModel(
        messageId: item.messageId,
        announcementId: item.announcementId,
        title: item.title,
        body: item.body,
      );
  Map<String, dynamic> toJson() => {
    'message_id': messageId,
    'announcement_id': announcementId,
    'title': title,
    'body': body,
  };
  IncomingAnnouncement toEntity() => IncomingAnnouncement(
    messageId: messageId,
    announcementId: announcementId,
    title: title,
    body: body,
  );
}
