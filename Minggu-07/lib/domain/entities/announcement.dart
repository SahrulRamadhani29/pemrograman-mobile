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
}
