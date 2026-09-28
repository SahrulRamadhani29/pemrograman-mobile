import 'package:flutter/material.dart';

import '../controllers/player_controller.dart';
import '../models/song.dart';
import '../services/spotify_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/mini_player.dart';
import 'home_page.dart';
import 'lyrics_page.dart';
import 'player_page.dart';
import 'trending_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final PlayerController _player = PlayerController();
  int currentIndex = 0;
  int _lastMenuIndex = 0;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onPlay: _selectLocalSong, player: _player),
      TrendingPage(
        onPlay: _selectSong,
        onSongsLoaded: _player.setQueue,
        player: _player,
      ),
      LyricsPage(
        player: _player,
        onClose: () => setState(() => currentIndex = 3),
      ),
      PlayerPage(
        player: _player,
        onClose: () => setState(() => currentIndex = _lastMenuIndex),
        onOpenLyrics: () => setState(() => currentIndex = 2),
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: currentIndex >= 2
          ? null
          : AnimatedBuilder(
              animation: _player.playbackStatus,
              builder: (context, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_player.currentSong != null)
                    MiniPlayer(
                      song: _player.currentSong!,
                      isPlaying: _player.isPlaying,
                      onPlay: _player.toggle,
                      onOpen: () => setState(() => currentIndex = 3),
                    ),
                  BottomNav(
                    index: currentIndex,
                    onChanged: (value) {
                      if (value == 2) {
                        setState(() => currentIndex = 2);
                        return;
                      }
                      setState(() {
                        currentIndex = value;
                        _lastMenuIndex = value;
                      });
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _selectSong(Song song) async {
    if (_player.currentSong?.id == song.id) {
      await _player.toggle();
      if (mounted) setState(() => currentIndex = 3);
      return;
    }
    final available = await _player.selectSong(song);
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lagu belum tersedia di file, jadi belum bisa diputar'),
        ),
      );
    }
    if (available && mounted) setState(() => currentIndex = 3);
  }

  Future<void> _selectLocalSong(Song song) async {
    if (_player.currentSong?.id == song.id) {
      await _player.toggle();
      if (mounted) setState(() => currentIndex = 3);
      return;
    }
    _player.setQueue(SpotifyService().getDownloadedSongs());
    final available = await _player.selectSong(song);
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File audio lokal belum tersedia')),
      );
      return;
    }
    if (mounted) setState(() => currentIndex = 3);
  }
}
