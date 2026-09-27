// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/models/song.dart';

void main() {
  test('model lagu menyimpan data dengan benar', () {
    const song = Song(id: '1', title: 'Judul', artist: 'Artis', rank: 1);
    expect(song.title, 'Judul');
    expect(song.rank, 1);
  });
}
