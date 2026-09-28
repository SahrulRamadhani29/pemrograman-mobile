import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../controllers/player_controller.dart';

class LyricsPage extends StatefulWidget {
  const LyricsPage({required this.player, this.onClose, super.key});

  final PlayerController player;
  final VoidCallback? onClose;

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _followTimer;
  DateTime _lastAutoFollow = DateTime.fromMillisecondsSinceEpoch(0);
  bool _autoFollow = true;

  @override
  void initState() {
    super.initState();
    widget.player.addListener(_followPlayback);
  }

  @override
  void dispose() {
    widget.player.removeListener(_followPlayback);
    _followTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _followPlayback() {
    if (!_autoFollow ||
        !widget.player.isPlaying ||
        !_scrollController.hasClients) {
      return;
    }
    final now = DateTime.now();
    if (now.difference(_lastAutoFollow).inMilliseconds < 1100) {
      return;
    }
    _lastAutoFollow = now;
    _followTimer?.cancel();
    _followTimer = Timer(const Duration(milliseconds: 30), _moveToPlayback);
  }

  void _moveToPlayback() {
    if (!_autoFollow || !_scrollController.hasClients) return;
    final duration = widget.player.duration.inMilliseconds;
    if (duration <= 0) return;
    final progress = (widget.player.position.inMilliseconds / duration).clamp(
      0.0,
      1.0,
    );
    final target = _scrollController.position.maxScrollExtent * progress;
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.direction != ScrollDirection.idle) {
      _autoFollow = false;
    }
    return false;
  }

  void _syncLyrics() {
    _autoFollow = true;
    _lastAutoFollow = DateTime.fromMillisecondsSinceEpoch(0);
    _moveToPlayback();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.player.currentSong;
    if (song == null || !song.isLocal) {
      return _EmptyLyrics(onClose: widget.onClose, hasSong: song != null);
    }

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(onClose: widget.onClose, onSync: _syncLyrics),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
                    child: Text(
                      'Lirik Lagu',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .58),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 160),
                  sliver: SliverList.builder(
                    itemCount: song.lyrics.isEmpty ? 1 : song.lyrics.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Text(
                        song.lyrics.isEmpty
                            ? 'Lirik belum tersedia'
                            : song.lyrics[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: song.lyrics.isEmpty ? 22 : 19,
                          height: 1.42,
                          color: Colors.white.withValues(
                            alpha: song.lyrics.isEmpty ? 1 : .78,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _LyricsControls(player: widget.player),
          ),
        ],
      ),
    );
  }
}

class _LyricsControls extends StatelessWidget {
  const _LyricsControls({required this.player});

  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xF21B2433),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.music_note_rounded, color: Colors.white60),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Sedang diputar',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AnimatedBuilder(
              animation: player.playbackStatus,
              builder: (context, _) => IconButton.filled(
                onPressed: player.toggle,
                tooltip: player.isPlaying ? 'Jeda' : 'Putar',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                icon: Icon(
                  player.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.onClose, required this.onSync});
  final VoidCallback? onClose;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          tooltip: 'Kembali ke pemutar',
          icon: const Icon(Icons.arrow_back_rounded),
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
          onPressed: onSync,
          tooltip: 'Sinkronkan lirik',
          icon: const Icon(Icons.sync_rounded),
        ),
      ],
    );
  }
}

class _EmptyLyrics extends StatelessWidget {
  const _EmptyLyrics({required this.onClose, required this.hasSong});
  final VoidCallback? onClose;
  final bool hasSong;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const Spacer(),
          const Icon(Icons.lyrics_rounded, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            hasSong
                ? 'Lirik hanya tersedia untuk lagu lokal'
                : 'Belum ada lagu yang diputar',
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
