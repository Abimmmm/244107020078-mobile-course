import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class NoteDetailPage
    extends ConsumerWidget {
  const NoteDetailPage({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final repo =
        ref.watch(noteRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Detail Catatan'),
      ),
      body: FutureBuilder(
        future: repo.getNoteById(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final note = snapshot.data;

          if (note == null) {
            return const Center(
              child: Text(
                'Catatan tidak ditemukan',
              ),
            );
          }

          return Padding(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(note.body),
                const SizedBox(height: 16),
                Text(
                  note.dirty
                      ? 'Belum tersinkron'
                      : 'Sudah tersinkron',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}