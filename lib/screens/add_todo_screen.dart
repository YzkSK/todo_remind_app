import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/date_time_picker_dialog.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  bool _hasDueDate = false;
  RepeatType _repeatType = RepeatType.once;
  WeeklyRepeatConfig? _weeklyConfig;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final result = await showDialog<DateTimePickerResult>(
      context: context,
      builder: (context) => DateTimePickerDialog(
        initialDateTime: _selectedDueDate,
        initialRepeatType: _repeatType,
        initialWeeklyConfig: _weeklyConfig,
      ),
    );

    if (result != null) {
      setState(() {
        _repeatType = result.repeatType;
        if (result.repeatType == RepeatType.once) {
          _selectedDueDate = result.dateTime;
          _weeklyConfig = null;
        } else {
          _selectedDueDate = null;
          _weeklyConfig = result.weeklyConfig;
        }
      });
    }
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final newTodo = Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        dueDate: _hasDueDate && _repeatType == RepeatType.once ? _selectedDueDate : null,
        repeatType: _hasDueDate ? _repeatType : RepeatType.once,
        weeklyConfig: _hasDueDate && _repeatType == RepeatType.weekly ? _weeklyConfig : null,
      );

      Navigator.of(context).pop(newTodo);
    }
  }

  Widget _buildDueDateSubtitle() {
    if (_repeatType == RepeatType.once) {
      if (_selectedDueDate == null) {
        return const Text('日付と時刻を設定');
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDueDate!.year}/${_selectedDueDate!.month}/${_selectedDueDate!.day} ${_selectedDueDate!.hour.toString().padLeft(2, '0')}:${_selectedDueDate!.minute.toString().padLeft(2, '0')}',
          ),
          const Row(
            children: [
              Icon(Icons.event_available, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text('1回のみ', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      );
    } else {
      if (_weeklyConfig == null) {
        return const Text('繰り返し設定を行ってください');
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_weeklyConfig!.intervalWeeks == 1 ? '毎週' : '${_weeklyConfig!.intervalWeeks}週間おき'}'
            '${['月', '火', '水', '木', '金', '土', '日'][_weeklyConfig!.dayOfWeek - 1]}曜日 '
            '${_weeklyConfig!.time.hour.toString().padLeft(2, '0')}:${_weeklyConfig!.time.minute.toString().padLeft(2, '0')}',
          ),
          const Row(
            children: [
              Icon(Icons.repeat, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text('毎週繰り返し', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('TODO追加'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTodo,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                hintText: 'TODOのタイトルを入力',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'タイトルを入力してください';
                }
                return null;
              },
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明（任意）',
                hintText: 'TODOの詳細を入力',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.event),
                title: const Text('期限を設定'),
                value: _hasDueDate,
                onChanged: (value) {
                  setState(() {
                    _hasDueDate = value;
                    if (!value) {
                      _selectedDueDate = null;
                    } else {
                      _selectedDueDate ??= DateTime.now();
                    }
                  });
                },
              ),
            ),
            if (_hasDueDate) ...[
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('期限設定'),
                  subtitle: _buildDueDateSubtitle(),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectDueDate(context),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveTodo,
              icon: const Icon(Icons.add),
              label: const Text('TODOを追加'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
