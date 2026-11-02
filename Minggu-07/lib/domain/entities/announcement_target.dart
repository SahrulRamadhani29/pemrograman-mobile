class AnnouncementTarget {
  const AnnouncementTarget(this.announcementId);
  final int? announcementId;
  factory AnnouncementTarget.fromRoute(String? value) {
    var route = value?.trim() ?? '';
    if (!route.startsWith('/')) route = '/$route';
    final match = RegExp(r'^/pengumuman/([1-9]\d*)$').firstMatch(route);
    return AnnouncementTarget(
      match == null ? null : int.tryParse(match.group(1)!),
    );
  }
  String get path =>
      announcementId == null ? '/' : '/pengumuman/$announcementId';
}
