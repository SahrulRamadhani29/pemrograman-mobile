import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/song.dart';

class SpotifyService {
  Future<List<Song>> getTrendingIndonesia() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://rss.applemarketingtools.com/api/v2/id/music/most-played/10/songs.json',
        ),
      );
      if (response.statusCode != 200) throw Exception('Chart gagal');
      final results =
          jsonDecode(response.body)['feed']['results'] as List<dynamic>;
      return await Future.wait(
        results.asMap().entries.map((entry) async {
          final item = entry.value as Map<String, dynamic>;
          final title = item['name'] as String;
          final artist = item['artistName'] as String;
          return Song(
            id: item['id'] as String,
            title: title,
            artist: artist,
            rank: entry.key + 1,
            artworkUrl: item['artworkUrl100'] as String?,
            audioAsset: _audioFor(title),
            lyrics: await _lyricsFor(title),
          );
        }),
      );
    } catch (_) {
      return _fallback();
    }
  }

  String? _audioFor(String title) {
    const files = <String, String>{
      'Satu Bulan': 'assets/audio/Satu Bulan - Bernadya.mp3',
      'Untungnya, Hidup Masih Berjalan':
          'assets/audio/Untungnya, Hidup Harus Tetap Berjalan - Bernadya.mp3',
      'Untungnya, Hidup Harus Tetap Berjalan':
          'assets/audio/Untungnya, Hidup Harus Tetap Berjalan - Bernadya.mp3',
      'Mati-Matian': 'assets/audio/Mati-Matian - Mahalini.mp3',
      'Penjaga Hati': 'assets/audio/penjaga hati - Nadhif Basalamah.mp3',
      'Rumah': 'assets/audio/Kita usahakan rumah itu - Sal Priadi.mp3',
      'Kita usahakan rumah itu':
          'assets/audio/Kita usahakan rumah itu - Sal Priadi.mp3',
      'Terlalu Lama Sendiri':
          'assets/audio/Terlalu Lama Sendiri - Kunto Aji.mp3',
      'Hilang Tanpa Bilang': 'assets/audio/Hilang Tanpa Bilang - Meiska.mp3',
      'Tak Segampang Itu': 'assets/audio/Tak Segampang Itu - Anggi Marito.mp3',
      'Kita ke Sana': 'assets/audio/Kita Ke Sana - Hindia.mp3',
    };
    return files[title];
  }

  Future<List<String>> _lyricsFor(String title) async {
    try {
      final source = await rootBundle.loadString('assets/lyrics/top10.txt');
      final part = source
          .split('====')
          .firstWhere(
            (value) => value.toLowerCase().contains(title.toLowerCase()),
            orElse: () => '',
          );
      return part
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where(
            (line) =>
                line.isNotEmpty &&
                !line.startsWith('Lagu ') &&
                line != 'Informasi umum' &&
                line != 'Lirik' &&
                line != 'Share',
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  List<Song> _fallback() => const [
    Song(
      id: '1',
      title: 'Satu Bulan',
      artist: 'Bernadya',
      rank: 1,
      artworkAsset: 'assets/images/cover.jpg',
      audioAsset: 'assets/audio/Satu Bulan - Bernadya.mp3',
    ),
    Song(
      id: '2',
      title: 'Untungnya, Hidup Masih Berjalan',
      artist: 'Bernadya',
      rank: 2,
      audioAsset:
          'assets/audio/Untungnya, Hidup Harus Tetap Berjalan - Bernadya.mp3',
    ),
    Song(
      id: '3',
      title: 'Mati-Matian',
      artist: 'Mahalini',
      rank: 3,
      audioAsset: 'assets/audio/Mati-Matian - Mahalini.mp3',
    ),
    Song(
      id: '4',
      title: 'Penjaga Hati',
      artist: 'Nadhif Basalamah',
      rank: 4,
      audioAsset: 'assets/audio/penjaga hati - Nadhif Basalamah.mp3',
    ),
    Song(
      id: '5',
      title: 'Kita usahakan rumah itu',
      artist: 'Sal Priadi',
      rank: 5,
      audioAsset: 'assets/audio/Kita usahakan rumah itu - Sal Priadi.mp3',
    ),
    Song(
      id: '6',
      title: 'Terlalu Lama Sendiri',
      artist: 'Kunto Aji',
      rank: 6,
      audioAsset: 'assets/audio/Terlalu Lama Sendiri - Kunto Aji.mp3',
    ),
    Song(
      id: '7',
      title: 'Hilang Tanpa Bilang',
      artist: 'Meiska',
      rank: 7,
      audioAsset: 'assets/audio/Hilang Tanpa Bilang - Meiska.mp3',
    ),
    Song(
      id: '8',
      title: 'Tak Segampang Itu',
      artist: 'Anggi Marito',
      rank: 8,
      audioAsset: 'assets/audio/Tak Segampang Itu - Anggi Marito.mp3',
    ),
    Song(
      id: '9',
      title: 'Kita Ke Sana',
      artist: 'Hindia',
      rank: 9,
      audioAsset: 'assets/audio/Kita Ke Sana - Hindia.mp3',
    ),
    Song(
      id: '10',
      title: 'Rayuan Perempuan Gila',
      artist: 'Nadin Amizah',
      rank: 10,
      audioAsset: 'assets/audio/Rayuan Perempuan Gila - Nadin Amizah.mp3',
    ),
  ];
}
