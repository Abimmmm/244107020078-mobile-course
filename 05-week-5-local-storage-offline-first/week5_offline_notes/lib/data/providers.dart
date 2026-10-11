import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'local/note.dart';
import 'models/post.dart';
import 'repositories/note_repositories.dart';
import 'repositories/post_repository.dart';
import 'sync.dart';

final dioProvider = Provider<Dio>(
  (ref) => createDio(),
);

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(
    ref.watch(dioProvider),
  ),
);

final notesProvider = FutureProvider<List<Note>>(
  (ref) async {
    final repo = ref.watch(noteRepositoryProvider);
    return repo.fetchNotes();
  },

  // Matikan retry otomatis agar error langsung diteruskan ke test.
  retry: (retryCount, error) => null,
);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setOffline(bool value) {
    state = value;
  }
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);

final postsProvider = FutureProvider<List<Post>>((ref) async {
  final repo = ref.watch(postRepositoryProvider);
  final offline = ref.watch(forceOfflineProvider);

  if (offline) {
    return readCachedPosts();
  }

  return loadPostsCacheFirst(repo);
});