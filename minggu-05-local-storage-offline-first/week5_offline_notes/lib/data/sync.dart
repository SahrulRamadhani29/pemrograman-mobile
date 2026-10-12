import 'local/note.dart';
import 'repositories/note_repository.dart';

class OfflineException implements Exception {
  const OfflineException(this.message);
  final String message;
  @override
  String toString() => message;
}

Future<int> syncNotes(
  NoteRepository repository, {
  required bool offline,
  Duration latency = const Duration(seconds: 1),
}) async {
  if (offline) {
    throw const OfflineException('Perangkat offline, sinkronisasi ditunda.');
  }
  final dirty = await repository.fetchDirty();
  if (dirty.isEmpty) return 0;
  await Future<void>.delayed(latency);
  await repository.markSynced(dirty);
  return dirty.length;
}

Note resolveConflict(Note local, Note remote) =>
    remote.updatedAt.isAfter(local.updatedAt) ? remote : local;
