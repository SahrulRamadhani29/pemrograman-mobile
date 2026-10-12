import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';
import 'package:week5_offline_notes/providers/note_providers.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({List<Note> items = const [], this.throwError = false})
    : _items = [...items],
      super(openDb: () => throw UnimplementedError('Fake repository'));

  final List<Note> _items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw StateError('fake failure');
    return [..._items];
  }

  @override
  Future<int> countDirty() async => _items.where((note) => note.dirty).length;

  @override
  Future<List<Note>> fetchDirty() async =>
      _items.where((note) => note.dirty).toList();

  @override
  Future<void> markSynced(List<Note> notes) async {
    for (var index = 0; index < _items.length; index++) {
      if (notes.any((item) => item.id == _items[index].id)) {
        _items[index] = _items[index].copyWith(dirty: false);
      }
    }
  }
}

Note makeNote(String title, {bool dirty = false}) => Note(
  id: title.hashCode,
  title: title,
  updatedAt: DateTime(2026, 10, 5),
  dirty: dirty,
);

void main() {
  test('fromMap aman terhadap field yang hilang', () {
    final note = Note.fromMap({'title': 'Belanja'});
    expect(note.title, 'Belanja');
    expect(note.body, '');
    expect(note.dirty, isFalse);
  });

  test('flag dirty bertahan pada serialisasi', () {
    final note = makeNote('Tes', dirty: true);
    final restored = Note.fromMap(note.toMap());
    expect(restored.dirty, isTrue);
    expect(restored.updatedAt, note.updatedAt);
  });

  test('notesProvider berhasil dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(items: [makeNote('Tes')]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notes = await container.read(notesProvider.future);
    expect(notes.single.title, 'Tes');
  });

  test('notesProvider menghasilkan error dari repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(throwError: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(notesProvider.future),
      throwsA(isA<StateError>()),
    );
  });

  test('sync ditolak saat offline dan dirty tetap utuh', () async {
    final repo = FakeNoteRepository(items: [makeNote('Offline', dirty: true)]);
    await expectLater(
      syncNotes(repo, offline: true),
      throwsA(isA<OfflineException>()),
    );
    expect(await repo.countDirty(), 1);
  });

  test('sync berhasil menandai catatan bersih', () async {
    final repo = FakeNoteRepository(items: [makeNote('Online', dirty: true)]);
    expect(await syncNotes(repo, offline: false, latency: Duration.zero), 1);
    expect(await repo.countDirty(), 0);
  });

  test('conflict memilih perubahan dengan waktu terbaru', () {
    final local = Note(title: 'lokal', updatedAt: DateTime(2026, 10, 5, 10));
    final remote = Note(title: 'server', updatedAt: DateTime(2026, 10, 5, 11));
    expect(resolveConflict(local, remote).title, 'server');
  });
}
