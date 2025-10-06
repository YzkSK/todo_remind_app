import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckChanged;
  final VoidCallback? onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    this.onTap,
    this.onCheckChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: onCheckChanged,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description != null && todo.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  todo.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (todo.dueDate != null || todo.weeklyConfig != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      _getNotificationIcon(),
                      size: 14,
                      color: _getNotificationColor(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatNextNotification(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getNotificationColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  IconData _getNotificationIcon() {
    if (todo.repeatType == RepeatType.weekly) {
      return Icons.repeat;
    } else {
      return Icons.notifications;
    }
  }

  Color _getNotificationColor() {
    if (todo.repeatType == RepeatType.weekly) {
      return Colors.blue;
    }

    if (todo.dueDate == null) return Colors.grey;

    final now = DateTime.now();
    final dueDate = todo.dueDate!;

    if (dueDate.isBefore(now)) {
      return Colors.red;
    } else if (dueDate.difference(now).inHours < 24) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  DateTime? _getNextNotificationDate() {
    if (todo.repeatType == RepeatType.weekly && todo.weeklyConfig != null) {
      final config = todo.weeklyConfig!;
      final now = DateTime.now();

      // 今日の曜日 (1=月曜, 7=日曜)
      int currentWeekday = now.weekday;

      // 次の通知日を計算
      int daysUntilNext = config.dayOfWeek - currentWeekday;

      // 今日より前の曜日、または同じ曜日で時刻が過ぎている場合
      DateTime nextDate;
      if (daysUntilNext < 0 ||
          (daysUntilNext == 0 &&
           (now.hour > config.time.hour ||
            (now.hour == config.time.hour && now.minute >= config.time.minute)))) {
        // 次の週の指定曜日
        daysUntilNext += 7 * config.intervalWeeks;
      }

      nextDate = DateTime(
        now.year,
        now.month,
        now.day + daysUntilNext,
        config.time.hour,
        config.time.minute,
      );

      return nextDate;
    } else if (todo.dueDate != null) {
      return todo.dueDate;
    }

    return null;
  }

  String _formatNextNotification() {
    final nextDate = _getNextNotificationDate();

    if (nextDate == null) return '通知なし';

    final now = DateTime.now();
    final difference = nextDate.difference(now);
    final weekDayNames = ['月', '火', '水', '木', '金', '土', '日'];

    String dateStr = '${nextDate.year}/${nextDate.month}/${nextDate.day}';
    String timeStr = '${nextDate.hour.toString().padLeft(2, '0')}:${nextDate.minute.toString().padLeft(2, '0')}';
    String weekDay = weekDayNames[nextDate.weekday - 1];

    if (todo.repeatType == RepeatType.weekly) {
      // 繰り返しの場合
      if (difference.inDays == 0) {
        return '今日 $timeStr に通知';
      } else if (difference.inDays == 1) {
        return '明日 $timeStr に通知';
      } else if (difference.inDays < 7) {
        return '$weekDay $timeStr に通知';
      } else {
        return '$dateStr($weekDay) $timeStr に通知';
      }
    } else {
      // 1回のみの場合
      if (nextDate.isBefore(now)) {
        return '期限切れ: $dateStr $timeStr';
      } else if (difference.inDays == 0) {
        if (difference.inHours > 0) {
          return '今日 $timeStr (あと${difference.inHours}時間)';
        } else {
          return '今日 $timeStr (あと${difference.inMinutes}分)';
        }
      } else if (difference.inDays == 1) {
        return '明日 $timeStr';
      } else {
        return '$dateStr($weekDay) $timeStr';
      }
    }
  }
}
