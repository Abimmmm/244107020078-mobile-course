import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart'; // wajib: file ini memakai tipe Comment langsung
import 'providers.dart'; // reuse dioProvider yang sudah ada
import 'repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// AsyncNotifierProvider.family: karena comments bergantung pada postId,
/// kita butuh satu instance provider per-postId, bukan satu provider
/// global seperti postListProvider. `family` menyediakan argumen
/// (postId) yang otomatis dipakai sebagai bagian dari key cache provider.
///
/// CATATAN MIGRASI RIVERPOD 3.0: sejak versi 3.0, kelas family
/// (FamilyNotifier/FamilyAsyncNotifier/FamilyStreamNotifier) DIHAPUS.
/// Sekarang cukup extends `AsyncNotifier<State>` biasa, dan argumen family
/// (postId) diterima lewat CONSTRUCTOR, bukan lewat parameter build(arg)
/// seperti di Riverpod 2.x. `.family<..., int>(CommentListNotifier.new)`
/// otomatis memanggil constructor ini dengan postId setiap kali provider
/// dibaca dengan argumen postId yang berbeda.
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  CommentListNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() async {
    // Melempar exception dari repository di sini otomatis dikonversi
    // Riverpod menjadi AsyncError — inilah "penanganan error otomatis"
    // yang diminta, tanpa perlu try/catch manual.
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final commentListProvider =
    AsyncNotifierProvider.family<CommentListNotifier, List<Comment>, int>(
  CommentListNotifier.new,
  // retry: null menonaktifkan retry otomatis Riverpod 3, supaya error
  // langsung final — penting untuk unit test agar tidak menggantung
  // menunggu retry, dan supaya tombol "Coba lagi" benar-benar memicu
  // percobaan baru, bukan bentrok dengan retry internal.
  retry: (retryCount, error) => null,
);

/// Mengubah DioException teknis menjadi pesan yang aman ditampilkan ke
/// pengguna. Mencakup semua tipe DioExceptionType, termasuk yang jarang
/// terjadi (cancel, badCertificate, unknown) agar tidak ada kasus yang
/// jatuh diam-diam ke pesan generik tanpa disengaja.
String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        // transformTimeout: versi dio terbaru menambahkan nilai enum ini
        // untuk timeout saat memproses (transform) response. Dikelompokkan
        // bersama timeout lain karena pesan ke pengguna sama relevannya.
        return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';

      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';

      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) {
          return 'Komentar tidak ditemukan untuk post ini (404).';
        }
        if (code != null && code >= 500) {
          return 'Server sedang bermasalah ($code). Coba lagi nanti.';
        }
        return 'Terjadi kesalahan pada permintaan ($code).';

      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';

      case DioExceptionType.badCertificate:
        return 'Sertifikat keamanan server tidak valid.';

      case DioExceptionType.unknown:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  // Fallback untuk exception non-Dio (mis. error parsing di luar dugaan).
  return 'Terjadi kesalahan tak terduga: $error';
}