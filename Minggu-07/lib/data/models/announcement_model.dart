import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    required super.createdAt,
  });
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        id: (json['id'] as num).toInt(),
        title: json['title']?.toString() ?? 'Pengumuman',
        body: json['body']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );
  Announcement toEntity() =>
      Announcement(id: id, title: title, body: body, createdAt: createdAt);
}
