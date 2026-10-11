import 'dart:convert';

import 'local/db.dart';
import 'models/post.dart';
import 'repositories/note_repositories.dart';
import 'repositories/post_repository.dart';

Future<List<Post>> readCachedPosts() async {
  final db = await openNotesDb();

  final rows = await db.query(
    'cached_posts',
    orderBy: 'id ASC',
  );

  return rows.map((row) {
    final payload = row['payload'] as String;

    final json =
        jsonDecode(payload) as Map<String, dynamic>;

    return Post.fromJson(json);
  }).toList();
}

Future<void> savePostsToCache(
  List<Post> posts,
) async {
  final db = await openNotesDb();

  await db.transaction((txn) async {
    await txn.delete('cached_posts');

    for (final post in posts) {
      await txn.insert(
        'cached_posts',
        {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at':
              DateTime.now().toIso8601String(),
        },
      );
    }
  });
}

Future<List<Post>> loadPostsCacheFirst(
  PostRepository repository,
) async {
  final cached = await readCachedPosts();

  try {
    final fresh = await repository.fetchPosts();
    await savePostsToCache(fresh);

    if (fresh.isNotEmpty) {
      return fresh;
    }
  } catch (_) {
    // Jika jaringan gagal, gunakan cache.
  }

  return cached;
}

Future<int> syncNotes(
  NoteRepository repo,
) async {
  final dirtyCount = await repo.countDirty();

  if (dirtyCount == 0) {
    return 0;
  }

  await Future.delayed(
    const Duration(seconds: 1),
  );

  await repo.markAllSynced();

  return dirtyCount;
}