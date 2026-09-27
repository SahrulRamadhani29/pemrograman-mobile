import '../models/song.dart';

class SpotifyService {
  static const bool useMockData = true;

  Future<List<Song>> getTrendingIndonesia() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const [
      Song(id: '1', title: 'Satu Bulan', artist: 'Bernadya', rank: 1, artworkAsset: 'assets/images/cover.jpg', artworkColor: 0xFF5A4262),
      Song(id: '2', title: 'Untungnya, Hidup Masih Berjalan', artist: 'Bernadya', rank: 2, artworkColor: 0xFF77756E),
      Song(id: '3', title: 'Mati-Matian', artist: 'Mahalini', rank: 3, artworkColor: 0xFF3C687F),
      Song(id: '4', title: 'Bila Nanti', artist: 'Nadin Amizah', rank: 4, artworkColor: 0xFF754E59),
      Song(id: '5', title: 'Penjaga Hati', artist: 'Nadhif Basalamah', rank: 5, artworkColor: 0xFF7A91B3),
      Song(id: '6', title: 'Rumah', artist: 'Sal Priadi', rank: 6, artworkColor: 0xFF70845B),
      Song(id: '7', title: 'Terlalu Lama Sendiri', artist: 'Kunto Aji', rank: 7, artworkColor: 0xFF8B7A5B),
      Song(id: '8', title: 'Hilang Tanpa Bilang', artist: 'Meiska', rank: 8, artworkColor: 0xFF334F81),
      Song(id: '9', title: 'Tak Segampang Itu', artist: 'Anggi Marito', rank: 9, artworkColor: 0xFFB39C83),
      Song(id: '10', title: 'Semua Akan Baik Saja', artist: 'Hindia', rank: 10, artworkColor: 0xFF273D68),
    ];
  }
}
