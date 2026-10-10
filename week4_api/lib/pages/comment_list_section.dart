import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment_providers.dart';

/// Contoh pemakaian: UI hanya bicara dengan provider, tidak pernah
/// memanggil Dio atau CommentRepository secara langsung.
class CommentListSection extends ConsumerWidget {
  const CommentListSection({super.key, required this.postId});
  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // family provider dipanggil dengan argumen postId.
    final commentsAsync = ref.watch(commentListProvider(postId));

    return commentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyCommentErrorMessage(err),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref
                    .read(commentListProvider(postId).notifier)
                    .refresh(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ),
      data: (comments) {
        if (comments.isEmpty) {
          return const Center(child: Text('Belum ada komentar.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final c = comments[index];
            return ListTile(
              title: Text(c.name),
              subtitle: Text(c.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            );
          },
        );
      },
    );
  }
}