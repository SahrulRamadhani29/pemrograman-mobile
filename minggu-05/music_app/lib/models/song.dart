class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.rank,
    this.artworkAsset,
    this.artworkUrl,
    this.artworkColor = 0xFF27344F,
    this.previewUrl,
    this.spotifyUrl,
    this.audioAsset,
    this.lyrics = const [],
  });

  final String id;
  final String title;
  final String artist;
  final int rank;
  final String? artworkAsset;
  final String? artworkUrl;
  final int artworkColor;
  final String? previewUrl;
  final String? spotifyUrl;
  final String? audioAsset;
  final List<String> lyrics;
}
