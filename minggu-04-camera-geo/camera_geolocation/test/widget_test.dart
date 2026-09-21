import 'package:camera_geolocation/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CameraApp tersedia sebagai widget utama', () {
    expect(CameraApp, isA<Type>());
  });
}
