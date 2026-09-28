import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';

class PlayerController extends ChangeNotifier {
  PlayerController() {
    _initialize();
  }

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<int> playbackStatus = ValueNotifier<int>(0);
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;

  Song? currentSong;
  Duration position = Duration.zero;
  Duration duration = const Duration(minutes: 4, seconds: 2);
  bool isPlaying = false;
  bool shuffleEnabled = false;
  bool repeatEnabled = false;
  final Set<String> favoriteIds = {};
  List<Song> queue = const [];
  int currentIndex = -1;

  Future<void> _initialize() async {
    _positionSubscription = _player.positionStream.listen((value) {
      position = value;
      notifyListeners();
    });
    _stateSubscription = _player.playerStateStream.listen((state) {
      final wasPlaying = isPlaying;
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed &&
          !repeatEnabled) {
        next();
      }
      if (wasPlaying != isPlaying) _notifyPlaybackStatus();
      notifyListeners();
    });
    notifyListeners();
  }

  Future<bool> selectSong(Song song) async {
    if (song.audioAsset == null && song.previewUrl == null) return false;
    try {
      duration = song.audioAsset != null
          ? await _player.setAsset(song.audioAsset!) ?? duration
          : await _player.setUrl(song.previewUrl!) ??
                const Duration(seconds: 30);
    } catch (_) {
      return false;
    }
    final lyrics = song.isLocal
        ? await _loadLyrics(song.title)
        : const <String>[];
    currentSong = Song(
      id: song.id,
      title: song.title,
      artist: song.artist,
      rank: song.rank,
      artworkAsset: song.artworkAsset,
      artworkUrl: song.artworkUrl,
      artworkColor: song.artworkColor,
      previewUrl: song.previewUrl,
      audioAsset: song.audioAsset,
      lyrics: lyrics,
      isLocal: song.isLocal,
    );
    currentIndex = queue.indexWhere((item) => item.id == song.id);
    _setPlaying(true);
    unawaited(_player.play().catchError((Object _) => _setPlaying(false)));
    return true;
  }

  Future<void> toggle() async {
    if (isPlaying) {
      _setPlaying(false);
      await _player.pause();
      return;
    }

    _setPlaying(true);
    unawaited(_player.play().catchError((Object _) => _setPlaying(false)));
  }

  Future<void> seek(Duration value) => _player.seek(value);

  Future<void> previous() async {
    if (position > const Duration(seconds: 4)) {
      await seek(Duration.zero);
    } else if (currentIndex > 0) {
      await selectSong(queue[currentIndex - 1]);
    }
  }

  Future<void> next() async {
    if (queue.isEmpty) return;
    if (shuffleEnabled) {
      await selectSong(queue[Random().nextInt(queue.length)]);
    } else if (currentIndex >= 0 && currentIndex < queue.length - 1) {
      await selectSong(queue[currentIndex + 1]);
    }
  }

  Future<void> toggleRepeat() async {
    repeatEnabled = !repeatEnabled;
    await _player.setLoopMode(repeatEnabled ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  void toggleShuffle() {
    shuffleEnabled = !shuffleEnabled;
    notifyListeners();
  }

  void toggleFavorite() {
    final id = currentSong?.id;
    if (id == null) return;
    favoriteIds.contains(id) ? favoriteIds.remove(id) : favoriteIds.add(id);
    _notifyPlaybackStatus();
    notifyListeners();
  }

  bool get isCurrentFavorite =>
      currentSong != null && favoriteIds.contains(currentSong!.id);

  Future<List<String>> _loadLyrics(String title) async {
    try {
      final source = await rootBundle.loadString('assets/lyrics/top10.txt');
      final section = source
          .split(RegExp(r'\r?\n\s*={3,}\s*\r?\n'))
          .firstWhere(
            (part) => part.toLowerCase().contains(title.toLowerCase()),
            orElse: () => '',
          );
      return section
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .where(
            (line) =>
                !line.startsWith('Lagu ') &&
                !line.startsWith('Lirik Lagu ') &&
                line != 'Informasi umum' &&
                line != 'Lirik' &&
                line != 'Share' &&
                !RegExp(r'^=+$').hasMatch(line),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void setQueue(List<Song> songs) {
    queue = List.unmodifiable(songs);
    if (currentSong != null) {
      currentIndex = queue.indexWhere((item) => item.id == currentSong!.id);
    }
  }

  void _notifyPlaybackStatus() {
    playbackStatus.value++;
  }

  void _setPlaying(bool value) {
    if (isPlaying == value) return;
    isPlaying = value;
    _notifyPlaybackStatus();
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    playbackStatus.dispose();
    _player.dispose();
    super.dispose();
  }
}
