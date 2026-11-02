import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> dartFiles(String path) =>
    Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
Iterable<String> importsOf(File file) =>
    RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''')
        .allMatches(file.readAsStringSync())
        .map((m) => m.group(1)!);
void main() {
  test('Domain hanya bergantung pada Dart dan file domain', () {
    final violations = <String>[];
    for (final file in dartFiles('lib/domain')) {
      for (final uri in importsOf(file)) {
        if (uri.startsWith('package:') ||
            uri.contains('/data/') ||
            uri.contains('/presentation/')) {
          violations.add(file.path);
        }
      }
      if (RegExp(r'\b(fromJson|toJson|fromMap|toMap)\b')
          .hasMatch(file.readAsStringSync())) {
        violations.add(file.path);
      }
    }
    expect(violations, isEmpty);
  });
  test('Halaman dan state bebas adapter data kecuali composition root', () {
    final violations = <String>[];
    for (final file in dartFiles('lib/presentation')) {
      if (file.uri.pathSegments.last == 'dependencies.dart') continue;
      for (final uri in importsOf(file)) {
        if (uri.contains('/data/') ||
            const [
              'package:dio',
              'package:firebase',
              'package:flutter_secure_storage',
              'package:shared_preferences',
              'package:legacy_vivo_badge',
            ].any(uri.startsWith)) {
          violations.add(file.path);
        }
      }
    }
    expect(violations, isEmpty);
  });
  test('Data tidak mengimpor presentation', () {
    final violations = dartFiles('lib/data')
        .where((f) => importsOf(f).any((uri) => uri.contains('/presentation/')))
        .map((f) => f.path)
        .toList();
    expect(violations, isEmpty);
  });
}
