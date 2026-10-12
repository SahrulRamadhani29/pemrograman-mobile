import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

final notesProvider = FutureProvider<List<Note>>(
  (ref) => ref.watch(noteRepositoryProvider).fetchNotes(),
);

final dirtyCountProvider = FutureProvider<int>(
  (ref) => ref.watch(noteRepositoryProvider).countDirty(),
);

final noteByIdProvider = FutureProvider.family<Note?, int>(
  (ref, id) => ref.watch(noteRepositoryProvider).getNoteById(id),
);

final noteActionsProvider = Provider<NoteActions>((ref) => NoteActions(ref));

class NoteActions {
  NoteActions(this.ref);
  final Ref ref;

  Future<void> add(String title, String body) async {
    await ref.read(noteRepositoryProvider).insertNote(title: title, body: body);
    _invalidate();
  }

  Future<void> update(Note note) async {
    await ref.read(noteRepositoryProvider).updateNote(note);
    _invalidate();
    if (note.id != null) ref.invalidate(noteByIdProvider(note.id!));
  }

  Future<void> delete(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    _invalidate();
    ref.invalidate(noteByIdProvider(id));
  }

  Future<int> sync({required bool offline}) async {
    final count = await syncNotes(
      ref.read(noteRepositoryProvider),
      offline: offline,
    );
    _invalidate();
    return count;
  }

  void _invalidate() {
    ref.invalidate(notesProvider);
    ref.invalidate(dirtyCountProvider);
  }
}
