import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../data/sync.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _addNote(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Catatan'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Judul',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                final repo = ref.read(noteRepositoryProvider);
                await repo.addNote(title: controller.text.trim());

                ref.invalidate(notesProvider);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final offline = ref.read(forceOfflineProvider);

              if (offline) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Force Offline aktif.'),
                  ),
                );
                return;
              }

              final repo = ref.read(noteRepositoryProvider);
              final total = await syncNotes(repo);

              ref.invalidate(notesProvider);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$total catatan disinkronkan'),
                ),
              );
            },
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan'),
            );
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              return NoteTile(
                note: note,
                onTap: () {},
                onDelete: () async {
                  if (note.id == null) return;

                  final repo = ref.read(noteRepositoryProvider);
                  await repo.deleteNote(note.id!);

                  ref.invalidate(notesProvider);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNote(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}