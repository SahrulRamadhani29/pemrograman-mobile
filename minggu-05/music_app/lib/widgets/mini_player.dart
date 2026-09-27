import 'package:flutter/material.dart';

import '../models/song.dart';
import 'song_card.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    required this.song,
    required this.isPlaying,
    required this.onPlay,
    required this.onOpen,
    super.key,
  });

  final Song song;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        height: 66,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xEE1B2433),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Artwork(song: song, size: 44),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    song.artist,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onPlay,
              icon: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
