import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://127.0.0.1:8447/api',
);
SecurityContext? developmentTlsContext;

Future<void> prepareDevelopmentTls() async {
  final host = Uri.parse(apiBaseUrl).host;
  if (kDebugMode && (host == '127.0.0.1' || host == 'localhost')) {
    final cert = await rootBundle.load('assets/dev-ca.pem');
    developmentTlsContext = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificatesBytes(cert.buffer.asUint8List());
  }
}

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  if (developmentTlsContext != null) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient(context: developmentTlsContext),
    );
  }
  return dio;
}
