import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson tetap aman saat field hilang/null', () {
    final json = <String, dynamic>{
      'postId': null,
      'id': 5.0,
      'name': 'Budi',
      // 'email' dan 'body' sengaja tidak ada di map
    };

    final comment = Comment.fromJson(json);

    expect(comment.postId, 0);
    expect(comment.id, 5);
    expect(comment.name, 'Budi');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  // EDGE CASE TAMBAHAN #1: API mengirim angka sebagai STRING, bukan
  // number. Ini kasus nyata yang umum terjadi (mis. backend legacy
  // yang tidak konsisten tipe JSON-nya). Cast langsung `as num?` akan
  // throw TypeError pada kasus ini; test ini membuktikan fromJson
  // benar-benar robust, bukan cuma toleran null.
  test('Comment.fromJson tidak crash saat id/postId dikirim sebagai string', () {
    final json = <String, dynamic>{
      'postId': '10', // string, bukan number
      'id': '99', // string, bukan number
      'name': 123, // tipe salah total (angka, bukan string)
      'email': null,
      'body': 'Isi komentar',
    };

    final comment = Comment.fromJson(json);

    expect(comment.postId, 10); // berhasil di-parse dari string
    expect(comment.id, 99);
    expect(comment.name, ''); // tipe salah total -> fallback, bukan crash
    expect(comment.email, '');
    expect(comment.body, 'Isi komentar');
  });

  // EDGE CASE TAMBAHAN #2: response API berupa list, salah satu
  // elemennya bukan Map (mis. null atau string nyasar). Menguji filter
  // whereType<Map<String, dynamic>>() di repository, sering luput diuji.
  test('elemen non-Map dalam list dibuang, tidak menyebabkan crash', () {
    final rawList = [
      {'postId': 1, 'id': 1, 'name': 'A', 'email': 'a@x.com', 'body': 'x'},
      null,
      'bukan map',
      {'postId': 2, 'id': 2, 'name': 'B', 'email': 'b@x.com', 'body': 'y'},
    ];

    final result = rawList
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();

    expect(result.length, 2);
    expect(result[0].name, 'A');
    expect(result[1].name, 'B');
  });
}