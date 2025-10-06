import 'package:flutter/material.dart';
import '../models/todo.dart';

class WeeklyRepeatConfigPage extends StatefulWidget {
  final WeeklyRepeatConfig? initialConfig;

  const WeeklyRepeatConfigPage({
    super.key,
    this.initialConfig,
  });

  @override
  State<WeeklyRepeatConfigPage> createState() => _WeeklyRepeatConfigPageState();
}

class _WeeklyRepeatConfigPageState extends State<WeeklyRepeatConfigPage> {
  late int _intervalWeeks;
  late int _dayOfWeek;
  late TimeOfDay _time;

  final List<String> _weekDayNames = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      _intervalWeeks = widget.initialConfig!.intervalWeeks;
      _dayOfWeek = widget.initialConfig!.dayOfWeek;
      _time = widget.initialConfig!.time;
    } else {
      _intervalWeeks = 1;
      _dayOfWeek = DateTime.now().weekday;
      _time = TimeOfDay.now();
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _time = picked;
      });
    }
  }

  void _save() {
    final config = WeeklyRepeatConfig(
      intervalWeeks: _intervalWeeks,
      dayOfWeek: _dayOfWeek,
      time: _time,
    );
    Navigator.of(context).pop(config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('繰り返し設定'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 間隔設定
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_repeat, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 16),
                      const Text(
                        '繰り返し間隔',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _intervalWeeks > 1
                            ? () => setState(() => _intervalWeeks--)
                            : null,
                      ),
                      Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: Text(
                          '$_intervalWeeks',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _intervalWeeks++),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      _intervalWeeks == 1 ? '毎週' : '$_intervalWeeks週間おき',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 曜日選択
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.today, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 16),
                      const Text(
                        '曜日',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final dayValue = index + 1;
                      final isSelected = _dayOfWeek == dayValue;
                      return ChoiceChip(
                        label: Text(_weekDayNames[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _dayOfWeek = dayValue);
                          }
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 時刻設定
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('時刻'),
              subtitle: Text(
                '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit),
              onTap: _selectTime,
            ),
          ),
          const SizedBox(height: 24),

          // プレビュー
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '設定内容',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _intervalWeeks == 1
                        ? '毎週${_weekDayNames[_dayOfWeek - 1]}曜日 ${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'
                        : '$_intervalWeeks週間おきの${_weekDayNames[_dayOfWeek - 1]}曜日 ${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('設定を保存'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
