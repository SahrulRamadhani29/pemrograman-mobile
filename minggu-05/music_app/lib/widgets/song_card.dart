import 'package:flutter/material.dart';

import '../models/song.dart';

class Artwork extends StatelessWidget {
  const Artwork({required this.song, this.size = 56, super.key});

  final Song song;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size > 100 ? 22 : 12),
      child: song.artworkAsset != null
          ? Image.asset(
              song.artworkAsset!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : song.artworkUrl != null
          ? Image.network(
              song.artworkUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Color(song.artworkColor),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(song.artworkColor), Colors.black87],
                ),
              ),
              child: Icon(
                Icons.music_note_rounded,
                color: Colors.white.withValues(alpha: .55),
                size: size * .42,
              ),
            ),
    );
  }
}

class SongCard extends StatelessWidget {
  const SongCard({
    required this.song,
    required this.onPlay,
    this.isCurrent = false,
    this.isPlaying = false,
    this.onMore,
    super.key,
  });

  final Song song;
  final VoidCallback onPlay;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? Colors.white.withValues(alpha: .08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${song.rank}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
          Artwork(song: song),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCurrent ? const Color(0xFF76A4FF) : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onPlay,
            tooltip: 'Putar ${song.title}',
            icon: Icon(
              isCurrent && isPlaying
                  ? Icons.graphic_eq_rounded
                  : Icons.play_arrow_rounded,
              size: 27,
              color: isCurrent ? const Color(0xFF76A4FF) : Colors.white70,
            ),
          ),
          IconButton(
            onPressed: onMore,
            tooltip: 'Opsi lagu',
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
