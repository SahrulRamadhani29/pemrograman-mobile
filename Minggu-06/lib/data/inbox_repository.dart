import 'package:dio/dio.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    id: (json['id'] as num).toInt(),
    title: json['title']?.toString() ?? 'Pengumuman',
    body: json['body']?.toString() ?? '',
    createdAt:
        DateTime.tryParse(json['created_at']?.toString() ?? '') ??
        DateTime.now(),
  );
}

class InboxRepository {
  InboxRepository(this.dio);
  final Dio dio;
  Future<List<Announcement>> unread() async {
    final response = await dio.get<Map<String, dynamic>>('/inbox');
    return (response.data!['data'] as List)
        .map(
          (item) =>
              Announcement.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<Announcement> detail(int id) async {
    final response = await dio.get<Map<String, dynamic>>('/pengumuman/$id');
    return Announcement.fromJson(
      Map<String, dynamic>.from(response.data!['data'] as Map),
    );
  }

  Future<void> markRead(int id) => dio.post('/pengumuman/$id/read');
  Future<int> receive(Map<String, dynamic> message) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/inbox/received',
      data: message,
    );
    return (response.data!['id'] as num).toInt();
  }
}
