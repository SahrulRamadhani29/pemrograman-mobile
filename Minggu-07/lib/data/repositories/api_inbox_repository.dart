import 'package:dio/dio.dart';

import '../../domain/entities/announcement.dart';
import '../../domain/entities/incoming_announcement.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../api/api_errors.dart';
import '../models/announcement_model.dart';
import '../models/incoming_announcement_model.dart';

class ApiInboxRepository implements InboxRepository {
  const ApiInboxRepository(this.dio);
  final Dio dio;
  @override
  Future<List<Announcement>> unread() => guardData(() async {
    final result = await dio.get<Map<String, dynamic>>('/inbox');
    return (result.data!['data'] as List)
        .map(
          (item) =>
              AnnouncementModel.fromJson(Map<String, dynamic>.from(item as Map))
                  .toEntity(),
        )
        .toList();
  });
  @override
  Future<Announcement> detail(int id) => guardData(() async {
    final result = await dio.get<Map<String, dynamic>>('/pengumuman/$id');
    return AnnouncementModel.fromJson(
      Map<String, dynamic>.from(result.data!['data'] as Map),
    ).toEntity();
  });
  @override
  Future<void> markRead(int id) => guardData(() async {
    await dio.post<void>('/pengumuman/$id/read');
  });
  @override
  Future<int> receive(IncomingAnnouncement message) => guardData(() async {
    final result = await dio.post<Map<String, dynamic>>(
      '/inbox/received',
      data: IncomingAnnouncementModel.fromEntity(message).toJson(),
    );
    return (result.data!['id'] as num).toInt();
  });
}
