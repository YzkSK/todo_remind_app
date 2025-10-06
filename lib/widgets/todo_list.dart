import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(Todo)? onTodoTap;
  final Function(Todo, bool)? onCheckChanged;
  final Function(Todo)? onDelete;

  const TodoList({
    super.key,
    required this.todos,
    this.onTodoTap,
    this.onCheckChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'TODOはありません',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(
          todo: todo,
          onTap: onTodoTap != null ? () => onTodoTap!(todo) : null,
          onCheckChanged: onCheckChanged != null
              ? (value) => onCheckChanged!(todo, value ?? false)
              : null,
          onDelete: onDelete != null ? () => onDelete!(todo) : null,
        );
      },
    );
  }
}
