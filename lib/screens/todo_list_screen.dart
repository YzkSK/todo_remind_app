import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/todo_list.dart';
import '../services/todo_storage.dart';
import 'add_todo_screen.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todos = [];
  final TodoStorage _storage = TodoStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final loadedTodos = await _storage.loadTodos();
    setState(() {
      todos = loadedTodos;
      _isLoading = false;
    });
  }

  Future<void> _saveTodos() async {
    await _storage.saveTodos(todos);
  }

  Future<void> _handleCheckChanged(Todo todo, bool isCompleted) async {
    setState(() {
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        todos[index] = todo.copyWith(isCompleted: isCompleted);
      }
    });
    await _saveTodos();
  }

  Future<void> _handleDelete(Todo todo) async {
    setState(() {
      todos.removeWhere((t) => t.id == todo.id);
    });
    await _saveTodos();
  }

  void _handleTodoTap(Todo todo) {
    // TODO詳細画面への遷移などを実装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('タップ: ${todo.title}')),
    );
  }

  Future<void> _addTodo() async {
    final newTodo = await Navigator.of(context).push<Todo>(
      MaterialPageRoute(
        builder: (context) => const AddTodoPage(),
      ),
    );

    if (newTodo != null) {
      setState(() {
        todos.insert(0, newTodo);
      });
      await _saveTodos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TODOを追加しました')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('TODO Reminder'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TodoList(
              todos: todos,
              onTodoTap: _handleTodoTap,
              onCheckChanged: _handleCheckChanged,
              onDelete: _handleDelete,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
