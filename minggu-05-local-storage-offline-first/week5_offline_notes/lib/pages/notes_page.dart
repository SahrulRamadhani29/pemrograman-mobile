import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/note.dart';
import '../providers/note_providers.dart';
import '../providers/offline_providers.dart';
import '../widgets/note_form_dialog.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, [
    Note? note,
  ]) async {
    final result = await showDialog<NoteFormResult>(
      context: context,
      builder: (_) => NoteFormDialog(initial: note),
    );
    if (result == null || !context.mounted) return;
    final actions = ref.read(noteActionsProvider);
    if (note == null) {
      await actions.add(result.title, result.body);
    } else {
      await actions.update(
        note.copyWith(title: result.title, body: result.body),
      );
    }
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final offline = ref.read(forceOfflineProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await ref.read(noteActionsProvider).sync(offline: offline);
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              count == 0
                  ? 'Semua catatan sudah tersinkron'
                  : '$count catatan berhasil disinkronkan',
            ),
          ),
        );
      }
    } on Exception catch (error) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider).value ?? 0;
    final offline = ref.watch(forceOfflineProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          if (offline)
            const Tooltip(
              message: 'Mode offline aktif',
              child: Icon(Icons.airplanemode_active),
            ),
          Badge(
            isLabelVisible: dirty > 0,
            label: Text('$dirty'),
            child: IconButton(
              onPressed: () => _sync(context, ref),
              tooltip: 'Sinkronkan',
              icon: const Icon(Icons.sync),
            ),
          ),
          IconButton(
            onPressed: () => context.push('/posts'),
            tooltip: 'Posts cache-first',
            icon: const Icon(Icons.article_outlined),
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _MessageView(
          message: 'Gagal memuat catatan: $error',
          action: () => ref.invalidate(notesProvider),
        ),
        data: (notes) => notes.isEmpty
            ? const _EmptyView()
            : RefreshIndicator(
                onRefresh: () async => ref.refresh(notesProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteTile(
                      note: note,
                      onTap: () => context.push('/note/${note.id}'),
                      onDelete: () =>
                          ref.read(noteActionsProvider).delete(note.id!),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.note_alt_outlined, size: 64),
        const SizedBox(height: 12),
        const Text('Belum ada catatan'),
        const SizedBox(height: 6),
        Text(
          'Tekan tombol Catatan untuk menambah',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message, required this.action});
  final String message;
  final VoidCallback action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: action, child: const Text('Coba lagi')),
        ],
      ),
    ),
  );
}
