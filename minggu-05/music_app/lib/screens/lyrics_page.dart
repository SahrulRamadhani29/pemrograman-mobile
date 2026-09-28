import 'dart:ui';

import 'package:flutter/material.dart';

import '../controllers/player_controller.dart';
import '../models/song.dart';
import '../widgets/song_card.dart';

class LyricsPage extends StatefulWidget {
  const LyricsPage({required this.player, this.onClose, super.key});

  final PlayerController player;
  final VoidCallback? onClose;

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.player.addListener(_followPlayback);
  }

  @override
  void dispose() {
    widget.player.removeListener(_followPlayback);
    _scrollController.dispose();
    super.dispose();
  }

  void _followPlayback() {
    if (!widget.player.isPlaying || !_scrollController.hasClients) return;
    final duration = widget.player.duration.inMilliseconds;
    if (duration <= 0) return;
    final progress = (widget.player.position.inMilliseconds / duration).clamp(
      0.0,
      1.0,
    );
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent * progress,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final song = player.currentSong;
    if (song == null || !song.isLocal) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note_rounded, size: 64, color: Colors.white24),
              SizedBox(height: 16),
              Text(
                song == null
                    ? 'Belum ada lagu yang diputar'
                    : 'Lirik hanya tersedia untuk lagu lokal',
              ),
              SizedBox(height: 6),
              Text(
                'Putar lagu dari menu Trending',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }
    final lyrics = song.lyrics;
    return AnimatedBuilder(
      animation: player,
      builder: (context, _) => SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: song.artworkAsset != null
                  ? Image.asset(song.artworkAsset!, fit: BoxFit.cover)
                  : song.artworkUrl != null
                  ? Image.network(song.artworkUrl!, fit: BoxFit.cover)
                  : Container(color: Color(song.artworkColor)),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(color: const Color(0xD90B0F17)),
              ),
            ),
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(onClose: widget.onClose, player: player),
                ),
                SliverToBoxAdapter(child: _SongInfo(song: song)),
                SliverToBoxAdapter(child: _Controls(player: player)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(26, 24, 26, 170),
                  sliver: SliverList.builder(
                    itemCount: lyrics.isEmpty ? 1 : lyrics.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        lyrics.isEmpty ? 'Lirik belum tersedia' : lyrics[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: lyrics.isEmpty || index == 0 ? 22 : 18,
                          height: 1.35,
                          fontWeight: lyrics.isEmpty || index == 0
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: lyrics.isEmpty || index == 0
                              ? Colors.white
                              : Colors.white.withValues(alpha: .52),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.onClose, required this.player});
  final VoidCallback? onClose;
  final PlayerController player;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          tooltip: 'Kembali',
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Lirik Lagu',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        IconButton(
          onPressed: player.toggleFavorite,
          tooltip: 'Suka',
          icon: Icon(
            player.isCurrentFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
          ),
        ),
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Menu lagu dibuka'))),
          tooltip: 'Lainnya',
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ],
    );
  }
}

class _SongInfo extends StatelessWidget {
  const _SongInfo({required this.song});
  final Song song;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Artwork(song: song, size: 245),
        const SizedBox(height: 18),
        Text(
          song.title,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          song.artist,
          style: TextStyle(fontSize: 17, color: Colors.white60),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.player});
  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    final max = player.duration.inMilliseconds.toDouble();
    final value = player.position.inMilliseconds
        .clamp(0, player.duration.inMilliseconds)
        .toDouble();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Column(
        children: [
          Slider(
            value: max == 0 ? 0 : value,
            max: max == 0 ? 1 : max,
            onChanged: (v) => player.seek(Duration(milliseconds: v.round())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_time(player.position)),
              Text(_time(player.duration)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: player.toggleShuffle,
                tooltip: 'Acak',
                icon: Icon(
                  Icons.shuffle_rounded,
                  color: player.shuffleEnabled ? Colors.blueAccent : null,
                ),
              ),
              IconButton(
                onPressed: player.previous,
                tooltip: 'Sebelumnya',
                icon: const Icon(Icons.skip_previous_rounded, size: 32),
              ),
              IconButton.filled(
                onPressed: player.toggle,
                tooltip: player.isPlaying ? 'Jeda' : 'Putar',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(64, 64),
                ),
                icon: Icon(
                  player.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 34,
                ),
              ),
              IconButton(
                onPressed: player.next,
                tooltip: 'Berikutnya',
                icon: const Icon(Icons.skip_next_rounded, size: 32),
              ),
              IconButton(
                onPressed: player.toggleRepeat,
                tooltip: 'Ulangi',
                icon: Icon(
                  Icons.repeat_rounded,
                  color: player.repeatEnabled ? Colors.blueAccent : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _time(Duration d) {
    return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}
