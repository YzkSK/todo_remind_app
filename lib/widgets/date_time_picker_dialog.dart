import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../screens/weekly_repeat_config_screen.dart';

class DateTimePickerResult {
  final DateTime? dateTime;  // 1回のみの場合のみ使用
  final RepeatType repeatType;
  final WeeklyRepeatConfig? weeklyConfig;  // 毎週の場合のみ使用

  DateTimePickerResult({
    this.dateTime,
    required this.repeatType,
    this.weeklyConfig,
  });
}

class DateTimePickerDialog extends StatefulWidget {
  final DateTime? initialDateTime;
  final RepeatType initialRepeatType;
  final WeeklyRepeatConfig? initialWeeklyConfig;

  const DateTimePickerDialog({
    super.key,
    this.initialDateTime,
    this.initialRepeatType = RepeatType.once,
    this.initialWeeklyConfig,
  });

  @override
  State<DateTimePickerDialog> createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<DateTimePickerDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late RepeatType _repeatType;
  WeeklyRepeatConfig? _weeklyConfig;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDateTime ?? DateTime.now();
    _selectedDate = DateTime(initial.year, initial.month, initial.day);
    _selectedTime = TimeOfDay(hour: initial.hour, minute: initial.minute);
    _repeatType = widget.initialRepeatType;
    _weeklyConfig = widget.initialWeeklyConfig;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _configureWeeklyRepeat() async {
    final config = await Navigator.of(context).push<WeeklyRepeatConfig>(
      MaterialPageRoute(
        builder: (context) => WeeklyRepeatConfigPage(
          initialConfig: _weeklyConfig,
        ),
      ),
    );

    if (config != null) {
      setState(() {
        _weeklyConfig = config;
      });
    }
  }

  void _confirm() {
    if (_repeatType == RepeatType.weekly) {
      if (_weeklyConfig == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('繰り返し設定を行ってください')),
        );
        return;
      }
      Navigator.of(context).pop(
        DateTimePickerResult(
          repeatType: RepeatType.weekly,
          weeklyConfig: _weeklyConfig,
        ),
      );
    } else {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      Navigator.of(context).pop(
        DateTimePickerResult(
          dateTime: dateTime,
          repeatType: RepeatType.once,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('期限を設定'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 繰り返し設定
            Row(
              children: [
                Icon(Icons.repeat, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                const Text(
                  '繰り返し',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            RadioListTile<RepeatType>(
              contentPadding: EdgeInsets.zero,
              title: const Text('1回のみ'),
              value: RepeatType.once,
              groupValue: _repeatType,
              onChanged: (value) {
                setState(() {
                  _repeatType = value!;
                  _weeklyConfig = null;
                });
              },
            ),
            RadioListTile<RepeatType>(
              contentPadding: EdgeInsets.zero,
              title: const Text('毎週繰り返し'),
              value: RepeatType.weekly,
              groupValue: _repeatType,
              onChanged: (value) {
                setState(() {
                  _repeatType = value!;
                });
              },
            ),
            const Divider(),

            // 1回のみの設定
            if (_repeatType == RepeatType.once) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('日付'),
                subtitle: Text(
                  '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                ),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: _selectDate,
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: const Text('時刻'),
                subtitle: Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: _selectTime,
              ),
            ],

            // 毎週繰り返しの設定
            if (_repeatType == RepeatType.weekly) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.settings),
                title: const Text('繰り返し詳細設定'),
                subtitle: _weeklyConfig != null
                    ? Text(
                        '${_weeklyConfig!.intervalWeeks == 1 ? '毎週' : '${_weeklyConfig!.intervalWeeks}週間おき'} '
                        '${['月', '火', '水', '木', '金', '土', '日'][_weeklyConfig!.dayOfWeek - 1]}曜日 '
                        '${_weeklyConfig!.time.hour.toString().padLeft(2, '0')}:${_weeklyConfig!.time.minute.toString().padLeft(2, '0')}',
                      )
                    : const Text('タップして設定'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _configureWeeklyRepeat,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: _confirm,
          child: const Text('決定'),
        ),
      ],
    );
  }
}
