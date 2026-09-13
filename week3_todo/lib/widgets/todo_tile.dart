import 'package:flutter/material.dart';
import '../models/todo.dart';

/// Widget tersendiri untuk satu baris ToDo.
/// Dipisah dari TodoPage supaya build() di TodoPage lebih pendek,
/// dan TodoTile bisa di-widget-test terisolasi tanpa merender seluruh halaman.
class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(value: todo.done, onChanged: (_) => onToggle()),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.done ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}