import 'package:flutter/material.dart';

import '../controllers/player_controller.dart';
import '../models/song.dart';
import '../services/spotify_service.dart';
import '../widgets/song_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onPlay, required this.player, super.key});

  final ValueChanged<Song> onPlay;
  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    final songs = SpotifyService().getDownloadedSongs();
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(22, 24, 22, 6),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Koleksi Lokal',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 18),
            sliver: SliverToBoxAdapter(
              child: Text(
                '10 lagu yang tersedia di perangkat ini',
                style: TextStyle(color: Colors.white60),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: player.playbackStatus,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                child: Column(
                  children: songs
                      .map(
                        (song) => SongCard(
                          song: song,
                          onPlay: () => onPlay(song),
                          isCurrent: player.currentSong?.id == song.id,
                          isPlaying:
                              player.currentSong?.id == song.id &&
                              player.isPlaying,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
