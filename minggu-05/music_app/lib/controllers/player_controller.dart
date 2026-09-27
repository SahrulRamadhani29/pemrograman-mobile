import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';

class PlayerController extends ChangeNotifier {
  PlayerController() {
    _initialize();
  }

  final AudioPlayer _player = AudioPlayer();
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
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed &&
          !repeatEnabled) {
        next();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  Future<bool> selectSong(Song song) async {
    if (song.audioAsset == null) return false;
    try {
      duration = await _player.setAsset(song.audioAsset!) ?? duration;
    } catch (_) {
      return false;
    }
    currentSong = song;
    currentIndex = queue.indexWhere((item) => item.id == song.id);
    await _player.play();
    notifyListeners();
    return true;
  }

  Future<void> toggle() => isPlaying ? _player.pause() : _player.play();

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
    notifyListeners();
  }

  bool get isCurrentFavorite =>
      currentSong != null && favoriteIds.contains(currentSong!.id);

  void setQueue(List<Song> songs) {
    queue = List.unmodifiable(songs);
    if (currentSong != null) {
      currentIndex = queue.indexWhere((item) => item.id == currentSong!.id);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}
