import 'package:flutter/material.dart';
import '../data/models/todo.dart';
import '../data/repositories/todo_repository.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repository = TodoRepository();
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  Future<void> loadTodos() async {
    _todos = await _repository.getTodos();
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    await _repository.addTodo(todo);
    await loadTodos();
  }

  Future<void> updateTodo(Todo todo) async {
    await _repository.updateTodo(todo);
    await loadTodos();
  }

  Future<void> deleteTodo(String id) async {
    await _repository.deleteTodo(id);
    await loadTodos();
  }

  Future<void> toggleCompleted(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    await updateTodo(todo.copyWith(isCompleted: !todo.isCompleted));
  }

  List<Todo> getTodosByFrequency(String frequency) {
    return _todos.where((t) => t.frequency == frequency).toList();
  }
} 