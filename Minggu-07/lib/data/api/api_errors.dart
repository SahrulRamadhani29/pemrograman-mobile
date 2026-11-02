import 'package:dio/dio.dart';

import '../../domain/failures/app_failure.dart';

AppFailure mapDataFailure(Object error) {
  if (error is AppFailure) return error;
  if (error is DioException) {
    if (error.error is AppFailure) return error.error! as AppFailure;
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AppFailure(
        'Server belum merespons. Coba lagi sebentar.',
        kind: FailureKind.network,
      );
    }
    if (error.type == DioExceptionType.connectionError) {
      return const AppFailure(
        'Tidak dapat terhubung. Periksa koneksi dan server API.',
        kind: FailureKind.network,
      );
    }
    return switch (error.response?.statusCode) {
      401 => const AppFailure(
        'Email atau kata sandi salah, atau sesi sudah berakhir.',
        kind: FailureKind.unauthenticated,
      ),
      404 => const AppFailure(
        'Pengumuman tidak ditemukan.',
        kind: FailureKind.notFound,
      ),
      422 => const AppFailure(
        'Periksa kembali data yang diisi.',
        kind: FailureKind.validation,
      ),
      429 => const AppFailure(
        'Terlalu banyak percobaan. Tunggu satu menit.',
        kind: FailureKind.rateLimited,
      ),
      _ => const AppFailure('Permintaan belum berhasil. Silakan coba lagi.'),
    };
  }
  return const AppFailure('Terjadi kendala. Silakan coba lagi.');
}

Future<T> guardData<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } catch (error) {
    throw mapDataFailure(error);
  }
}
