import '../../domain/entities/announcement_target.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const loading = '/loading';
  static const settings = '/pengaturan';
  static const announcement = '/pengumuman/:id';
  static String detail(int id) => '/pengumuman/$id';
  static String safeDestination(String? route) =>
      AnnouncementTarget.fromRoute(route).path;
}
