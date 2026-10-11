import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/models/todo.dart';
import 'package:week3_todo/widgets/todo_tile.dart';

void main() {
  testWidgets('TodoTile memanggil callback saat ditekan', (tester) async {
    var toggled = false;
    var deleted = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TodoTile(
          todo: Todo('Belajar Riverpod'),
          onToggle: () => toggled = true,
          onDelete: () => deleted = true,
        ),
      ),
    ));

    expect(find.text('Belajar Riverpod'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    expect(toggled, isTrue);

    await tester.tap(find.byIcon(Icons.delete));
    expect(deleted, isTrue);
  });

  testWidgets('TodoTile mencoret teks saat done true', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TodoTile(
          todo: Todo('Sudah selesai', done: true),
          onToggle: () {},
          onDelete: () {},
        ),
      ),
    ));

    final text = tester.widget<Text>(find.text('Sudah selesai'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });
}