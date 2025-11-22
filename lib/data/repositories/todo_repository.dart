import 'package:hive/hive.dart';
import '../models/todo.dart';

class TodoRepository {
  static const String boxName = 'todos';

  Future<List<Todo>> getTodos() async {
    final box = await Hive.openBox<Todo>(boxName);
    return box.values.toList();
  }

  Future<void> addTodo(Todo todo) async {
    final box = await Hive.openBox<Todo>(boxName);
    await box.put(todo.id, todo);
  }

  Future<void> updateTodo(Todo todo) async {
    final box = await Hive.openBox<Todo>(boxName);
    await box.put(todo.id, todo);
  }

  Future<void> deleteTodo(String id) async {
    final box = await Hive.openBox<Todo>(boxName);
    await box.delete(id);
  }
} 