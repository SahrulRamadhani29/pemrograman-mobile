import 'package:flutter/material.dart';

import '../controllers/player_controller.dart';
import '../models/song.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/mini_player.dart';
import 'home_page.dart';
import 'lyrics_page.dart';
import 'trending_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final PlayerController _player = PlayerController();
  int currentIndex = 1;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      TrendingPage(onPlay: _selectSong, onSongsLoaded: _player.setQueue),
      LyricsPage(
        player: _player,
        onClose: () => setState(() => currentIndex = 1),
      ),
    ];
    return AnimatedBuilder(
      animation: _player,
      builder: (context, _) => Scaffold(
        body: IndexedStack(index: currentIndex, children: pages),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_player.currentSong != null && currentIndex != 2)
              MiniPlayer(
                song: _player.currentSong!,
                isPlaying: _player.isPlaying,
                onPlay: _player.toggle,
                onOpen: () => setState(() => currentIndex = 2),
              ),
            BottomNav(
              index: currentIndex,
              onChanged: (value) => setState(() => currentIndex = value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectSong(Song song) async {
    final available = await _player.selectSong(song);
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lagu belum tersedia di file, jadi belum bisa diputar'),
        ),
      );
    }
    if (available) setState(() => currentIndex = 2);
  }
}
