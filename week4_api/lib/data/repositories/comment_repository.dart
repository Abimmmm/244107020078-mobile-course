import 'package:dio/dio.dart';
import '../models/comment.dart';

class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  /// Mengambil komentar untuk satu post tertentu lewat query parameter
  /// ?postId={id}, sesuai kontrak JSONPlaceholder untuk endpoint /comments.
  ///
  /// Timeout tidak diatur di sini karena sudah didefinisikan sekali di
  /// createDio() (connectTimeout & receiveTimeout 10 detik) — setiap
  /// request lewat Dio ini otomatis mewarisi timeout tersebut, tidak
  /// perlu diulang per-method.
  ///
  /// Exception TIDAK ditangkap di sini (tidak ada try/catch). Ini
  /// disengaja: repository hanya bertugas mengambil & memetakan data,
  /// sedangkan keputusan "bagaimana menampilkan error ke pengguna"
  /// adalah tanggung jawab layer provider/UI. Kalau di-catch di sini,
  /// provider tidak akan pernah menerima AsyncError.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>() // buang elemen yang bukan objek
        .map(Comment.fromJson)
        .toList();
  }
}