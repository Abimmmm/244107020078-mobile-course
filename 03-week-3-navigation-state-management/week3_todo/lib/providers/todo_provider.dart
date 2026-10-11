import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => const [];

  void add(String title) => state = [...state, Todo(title)];

  void toggle(int index) {
    final todos = [...state];
    todos[index] = todos[index].copyWith(done: !todos[index].done);
    state = todos;
  }

  void remove(int index) => state = [...state]..removeAt(index);
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

/// Opsi filter yang tersedia di UI.
enum TodoFilter { all, active, done }

/// Notifier kecil khusus menyimpan filter yang dipilih user.
/// Dipisah dari TodoListNotifier agar tanggung jawabnya tunggal.
class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void setFilter(TodoFilter filter) => state = filter;
}

final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

/// Provider turunan: membaca todoListProvider + todoFilterProvider,
/// otomatis dihitung ulang & di-cache setiap dependency berubah.
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.active:
      return todos.where((t) => !t.done).toList();
    case TodoFilter.done:
      return todos.where((t) => t.done).toList();
    case TodoFilter.all:
      return todos;
  }
});