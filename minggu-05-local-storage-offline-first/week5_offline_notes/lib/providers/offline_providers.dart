import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sync.dart';
import 'note_providers.dart';

final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setOffline(bool value) => state = value;
}

final syncProvider = FutureProvider<int>((ref) async {
  final offline = ref.watch(forceOfflineProvider);
  return syncNotes(ref.read(noteRepositoryProvider), offline: offline);
});
