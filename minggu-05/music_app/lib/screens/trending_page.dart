import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/spotify_service.dart';
import '../widgets/song_card.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({required this.onPlay, this.onSongsLoaded, super.key});

  final ValueChanged<Song> onPlay;
  final ValueChanged<List<Song>>? onSongsLoaded;

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  final SpotifyService _service = SpotifyService();
  late Future<List<Song>> _songs;

  @override
  void initState() {
    super.initState();
    _songs = _service.getTrendingIndonesia();
  }

  void _retry() => setState(() => _songs = _service.getTrendingIndonesia());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: FutureBuilder<List<Song>>(
        future: _songs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }
          if (snapshot.hasError) {
            return _MessageView(
              text: 'Gagal memuat trending',
              button: 'Coba Lagi',
              onPressed: _retry,
            );
          }
          final songs = snapshot.data ?? [];
          if (songs.isNotEmpty && widget.onSongsLoaded != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onSongsLoaded!(songs);
            });
          }
          if (songs.isEmpty) {
            return const _MessageView(text: 'Belum ada lagu trending');
          }
          return CustomScrollView(
            key: const PageStorageKey('trending-scroll'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
                sliver: SliverToBoxAdapter(
                  child: _Header(onSearch: () => _showSearch(context, songs)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: _HeroSong(
                    song: songs.first,
                    onPlay: () => widget.onPlay(songs.first),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 180),
                sliver: SliverList.builder(
                  itemCount: songs.length - 1,
                  itemBuilder: (context, index) {
                    final song = songs[index + 1];
                    return SongCard(
                      song: song,
                      onPlay: () => widget.onPlay(song),
                      onMore: () => _showSongOptions(context, song),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSearch(BuildContext context, List<Song> songs) {
    showSearch(
      context: context,
      delegate: _SongSearchDelegate(songs, widget.onPlay),
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.play_arrow_rounded),
          title: Text('Putar ${song.title}'),
          onTap: () {
            Navigator.pop(context);
            widget.onPlay(song);
          },
        ),
      ),
    );
  }
}

class _SongSearchDelegate extends SearchDelegate<void> {
  _SongSearchDelegate(this.songs, this.onPlay);
  final List<Song> songs;
  final ValueChanged<Song> onPlay;

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final filtered = songs
        .where(
          (song) => '${song.title} ${song.artist}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    return ListView(
      children: filtered
          .map(
            (song) => ListTile(
              title: Text(song.title),
              subtitle: Text(song.artist),
              trailing: const Icon(Icons.play_arrow),
              onTap: () => onPlay(song),
            ),
          )
          .toList(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearch});
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trending',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Top 10 Lagu Indonesia',
                style: TextStyle(fontSize: 19, color: Colors.white70),
              ),
              const SizedBox(height: 3),
              Text(
                'Chart Indonesia, diperbarui setiap hari',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: .44),
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onSearch,
          tooltip: 'Cari lagu',
          icon: const Icon(Icons.search_rounded),
        ),
      ],
    );
  }
}

class _HeroSong extends StatelessWidget {
  const _HeroSong({required this.song, required this.onPlay});
  final Song song;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.35,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Artwork(song: song, size: 500),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xEE090C13)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${song.rank}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          song.artist,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: onPlay,
                    tooltip: 'Putar ${song.title}',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(52, 52),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      Container(
        width: 180,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      const SizedBox(height: 30),
      Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      const SizedBox(height: 14),
      ...List.generate(
        6,
        (_) => Container(
          height: 62,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ],
  );
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.text, this.button, this.onPressed});
  final String text;
  final String? button;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        if (button != null) ...[
          const SizedBox(height: 12),
          FilledButton(onPressed: onPressed, child: Text(button!)),
        ],
      ],
    ),
  );
}
