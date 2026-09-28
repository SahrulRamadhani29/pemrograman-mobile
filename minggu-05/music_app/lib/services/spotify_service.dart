import 'dart:convert';

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
            previewUrl: await _findPreview(title, artist),
            // Trending is preview-only. Local assets belong to the Home list.
            audioAsset: null,
            lyrics: const [],
          );
        }),
      );
    } catch (_) {
      throw Exception('Gagal memuat chart');
    }
  }

  Future<String?> _findPreview(String title, String artist) async {
    try {
      final term = Uri.encodeQueryComponent('$title $artist');
      final response = await http.get(
        Uri.parse(
          'https://itunes.apple.com/search?term=$term&country=id&media=music&entity=song&limit=1',
        ),
      );
      if (response.statusCode != 200) return null;
      final results = jsonDecode(response.body)['results'] as List<dynamic>;
      return results.isEmpty ? null : results.first['previewUrl'] as String?;
    } catch (_) {
      return null;
    }
  }

  List<Song> getDownloadedSongs() => _fallback();

  List<Song> _fallback() => const [
    Song(
      id: '1',
      title: 'Satu Bulan',
      artist: 'Bernadya',
      rank: 1,
      artworkAsset: 'assets/images/cover.jpg',
      audioAsset: 'assets/audio/Satu Bulan - Bernadya.mp3',
      isLocal: true,
    ),
    Song(
      id: '2',
      title: 'Untungnya, Hidup Masih Berjalan',
      artist: 'Bernadya',
      rank: 2,
      audioAsset:
          'assets/audio/Untungnya, Hidup Harus Tetap Berjalan - Bernadya.mp3',
      isLocal: true,
    ),
    Song(
      id: '3',
      title: 'Mati-Matian',
      artist: 'Mahalini',
      rank: 3,
      audioAsset: 'assets/audio/Mati-Matian - Mahalini.mp3',
      isLocal: true,
    ),
    Song(
      id: '4',
      title: 'Penjaga Hati',
      artist: 'Nadhif Basalamah',
      rank: 4,
      audioAsset: 'assets/audio/penjaga hati - Nadhif Basalamah.mp3',
      isLocal: true,
    ),
    Song(
      id: '5',
      title: 'Kita usahakan rumah itu',
      artist: 'Sal Priadi',
      rank: 5,
      audioAsset: 'assets/audio/Kita usahakan rumah itu - Sal Priadi.mp3',
      isLocal: true,
    ),
    Song(
      id: '6',
      title: 'Terlalu Lama Sendiri',
      artist: 'Kunto Aji',
      rank: 6,
      audioAsset: 'assets/audio/Terlalu Lama Sendiri - Kunto Aji.mp3',
      isLocal: true,
    ),
    Song(
      id: '7',
      title: 'Hilang Tanpa Bilang',
      artist: 'Meiska',
      rank: 7,
      audioAsset: 'assets/audio/Hilang Tanpa Bilang - Meiska.mp3',
      isLocal: true,
    ),
    Song(
      id: '8',
      title: 'Tak Segampang Itu',
      artist: 'Anggi Marito',
      rank: 8,
      audioAsset: 'assets/audio/Tak Segampang Itu - Anggi Marito.mp3',
      isLocal: true,
    ),
    Song(
      id: '9',
      title: 'Kita Ke Sana',
      artist: 'Hindia',
      rank: 9,
      audioAsset: 'assets/audio/Kita Ke Sana - Hindia.mp3',
      isLocal: true,
    ),
    Song(
      id: '10',
      title: 'Rayuan Perempuan Gila',
      artist: 'Nadin Amizah',
      rank: 10,
      audioAsset: 'assets/audio/Rayuan Perempuan Gila - Nadin Amizah.mp3',
      isLocal: true,
    ),
  ];
}
