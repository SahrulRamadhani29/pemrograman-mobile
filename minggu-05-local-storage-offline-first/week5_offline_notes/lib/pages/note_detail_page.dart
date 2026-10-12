import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/note_providers.dart';
import '../widgets/note_form_dialog.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({required this.id, super.key});
  final int id;

  Future<void> _edit(BuildContext context, WidgetRef ref, note) async {
    final result = await showDialog<NoteFormResult>(
      context: context,
      builder: (_) => NoteFormDialog(initial: note),
    );
    if (result == null || !context.mounted) return;
    await ref
        .read(noteActionsProvider)
        .update(note.copyWith(title: result.title, body: result.body));
    if (context.mounted) ref.invalidate(noteByIdProvider(id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal memuat: $error')),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                note.title,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Diperbarui ${note.updatedAt.toLocal()}'),
              if (note.dirty) ...[
                const SizedBox(height: 12),
                const Chip(
                  avatar: Icon(Icons.cloud_upload_outlined),
                  label: Text('Belum tersinkron'),
                ),
              ],
              const Divider(height: 32),
              Text(
                note.body.isEmpty ? '(tanpa isi)' : note.body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _edit(context, ref, note),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(noteActionsProvider).delete(id);
                  if (context.mounted) context.pop();
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus'),
              ),
            ],
          );
        },
      ),
    );
  }
}
