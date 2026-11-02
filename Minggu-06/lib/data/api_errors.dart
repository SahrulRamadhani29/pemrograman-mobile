import 'package:dio/dio.dart';

String friendlyApiError(Object error) {
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Server belum merespons. Coba lagi sebentar.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung. Periksa koneksi dan server API.';
    }
    final code = error.response?.statusCode;
    if (code == 401) {
      return 'Email atau kata sandi salah, atau sesi sudah berakhir.';
    }
    if (code == 429) return 'Terlalu banyak percobaan. Tunggu satu menit.';
    if (code == 404) return 'Pengumuman tidak ditemukan.';
    if (code == 422) return 'Periksa kembali data yang diisi.';
    return 'Permintaan belum berhasil. Silakan coba lagi.';
  }
  return 'Terjadi kendala. Silakan coba lagi.';
}
