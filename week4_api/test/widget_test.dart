import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week4_api/data/comment_providers.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';
import 'package:week4_api/main.dart';

/// Fake repository yang sengaja TIDAK PERNAH menyelesaikan Future-nya.
/// Dipakai lewat Completer (bukan Future.delayed) supaya tidak
/// meninggalkan Timer aktif di background setelah test selesai —
/// flutter_test akan menandai test sebagai gagal kalau ada Timer yang
/// masih "bocor" (pending) saat test berakhir.
class _FakeCommentRepository implements CommentRepository {
  @override
  Future<List<Comment>> fetchComments(int postId) {
    return Completer<List<Comment>>().future;
  }
}

void main() {
  testWidgets(
    'Menampilkan indikator loading saat pertama kali dibuka',
    (WidgetTester tester) async {
      // ProviderScope WAJIB membungkus MyApp di test, persis seperti di
      // main.dart (runApp(const ProviderScope(child: MyApp()))). Tanpa
      // ini, ref.watch di dalam widget tidak punya container untuk
      // dibaca, dan Riverpod melempar StateError "No ProviderScope found".
      //
      // commentRepositoryProvider di-override dengan fake repository agar
      // test TIDAK melakukan request HTTP sungguhan ke JSONPlaceholder —
      // membuat test cepat, deterministik, dan tidak butuh koneksi internet.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commentRepositoryProvider.overrideWithValue(
              _FakeCommentRepository(),
            ),
          ],
          child: const MyApp(),
        ),
      );

      // Sengaja HANYA pump() satu frame (implisit lewat pumpWidget),
      // TIDAK pumpAndSettle(). Karena fetchComments tidak pernah selesai,
      // provider akan tetap dalam state AsyncLoading selamanya, sehingga
      // UI harus menampilkan CircularProgressIndicator.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );
}