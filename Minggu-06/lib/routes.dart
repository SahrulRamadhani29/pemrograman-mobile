abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const loading = '/loading';
  static const settings = '/pengaturan';
  static const announcement = '/pengumuman/:id';
  static String detail(int id) => '/pengumuman/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  final value = data['route'];
  if (value == null || value.toString().trim().isEmpty) return AppRoutes.home;
  var route = value.toString().trim();
  if (!route.startsWith('/')) route = '/$route';
  // Push hanya boleh membuka halaman yang dikenal aplikasi.
  return RegExp(r'^/pengumuman/[1-9]\d*$').hasMatch(route)
      ? route
      : AppRoutes.home;
}
