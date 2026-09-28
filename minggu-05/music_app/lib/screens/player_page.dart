import 'dart:ui';

import 'package:flutter/material.dart';

import '../controllers/player_controller.dart';
import '../models/song.dart';
import '../widgets/song_card.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({
    required this.player,
    this.onClose,
    this.onOpenLyrics,
    super.key,
  });

  final PlayerController player;
  final VoidCallback? onClose;
  final VoidCallback? onOpenLyrics;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: player.playbackStatus,
      builder: (context, _) => _buildPage(),
    );
  }

  Widget _buildPage() {
    final song = player.currentSong;
    if (song == null) {
      return const Center(child: Text('Pilih lagu untuk mulai memutar'));
    }

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned.fill(child: _Background(song: song)),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: player.playbackStatus,
                  builder: (context, _) =>
                      _Header(onClose: onClose, player: player),
                ),
              ),
              SliverToBoxAdapter(child: _SongInfo(song: song)),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: player,
                  builder: (context, _) => _Controls(player: player),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 150),
                  child: song.isLocal && song.lyrics.isNotEmpty
                      ? FilledButton.icon(
                          onPressed: onOpenLyrics,
                          icon: const Icon(Icons.lyrics_rounded),
                          label: const Text('Buka lirik'),
                        )
                      : const _PreviewNotice(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({required this.song});
  final Song song;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (song.artworkAsset != null)
          Image.asset(song.artworkAsset!, fit: BoxFit.cover)
        else if (song.artworkUrl != null)
          Image.network(song.artworkUrl!, fit: BoxFit.cover)
        else
          ColoredBox(color: Color(song.artworkColor)),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(color: const Color(0xE60B0F17)),
        ),
      ],
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
              'Sedang diputar',
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
        const SizedBox(height: 24),
        Artwork(song: song, size: 280),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            song.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          song.artist,
          style: const TextStyle(fontSize: 17, color: Colors.white60),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
          const SizedBox(height: 12),
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
                  minimumSize: const Size(68, 68),
                ),
                icon: Icon(
                  player.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 36,
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

  String _time(Duration value) =>
      '${value.inMinutes}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';
}

class _PreviewNotice extends StatelessWidget {
  const _PreviewNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.white60),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ini hanya preview dari Trending. Lirik tidak tersedia untuk lagu API.',
            ),
          ),
        ],
      ),
    );
  }
}
