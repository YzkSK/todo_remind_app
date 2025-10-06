import 'package:flutter/material.dart';

enum RepeatType {
  once,    // 1回のみ
  weekly,  // 毎週
}

class WeeklyRepeatConfig {
  final int intervalWeeks;  // 何週間おきか (1 = 毎週, 2 = 隔週, etc.)
  final int dayOfWeek;      // 曜日 (1-7: 月曜=1, 日曜=7)
  final TimeOfDay time;     // 時刻

  WeeklyRepeatConfig({
    required this.intervalWeeks,
    required this.dayOfWeek,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'intervalWeeks': intervalWeeks,
      'dayOfWeek': dayOfWeek,
      'hour': time.hour,
      'minute': time.minute,
    };
  }

  factory WeeklyRepeatConfig.fromJson(Map<String, dynamic> json) {
    return WeeklyRepeatConfig(
      intervalWeeks: json['intervalWeeks'] as int,
      dayOfWeek: json['dayOfWeek'] as int,
      time: TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
    );
  }
}

class Todo {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? dueDate;  // 1回のみの期限用
  final bool isCompleted;
  final RepeatType repeatType;
  final WeeklyRepeatConfig? weeklyConfig;  // 毎週繰り返し設定

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    this.isCompleted = false,
    this.repeatType = RepeatType.once,
    this.weeklyConfig,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
    RepeatType? repeatType,
    WeeklyRepeatConfig? weeklyConfig,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatType: repeatType ?? this.repeatType,
      weeklyConfig: weeklyConfig ?? this.weeklyConfig,
    );
  }

  // JSONへの変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'repeatType': repeatType.name,
      'weeklyConfig': weeklyConfig?.toJson(),
    };
  }

  // JSONからの変換
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      repeatType: json['repeatType'] != null
          ? RepeatType.values.firstWhere(
              (e) => e.name == json['repeatType'],
              orElse: () => RepeatType.once,
            )
          : RepeatType.once,
      weeklyConfig: json['weeklyConfig'] != null
          ? WeeklyRepeatConfig.fromJson(json['weeklyConfig'] as Map<String, dynamic>)
          : null,
    );
  }
}
