import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoStorage {
  static const String _todosKey = 'todos';

  // TODOリストを保存
  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = todos.map((todo) => todo.toJson()).toList();
    final todosString = jsonEncode(todosJson);
    await prefs.setString(_todosKey, todosString);
  }

  // TODOリストを読み込み
  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosString = prefs.getString(_todosKey);

    if (todosString == null) {
      return [];
    }

    try {
      final List<dynamic> todosJson = jsonDecode(todosString);
      return todosJson
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // エラーが発生した場合は空のリストを返す
      return [];
    }
  }

  // すべてのTODOを削除
  Future<void> clearTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todosKey);
  }
}
