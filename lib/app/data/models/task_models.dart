import 'package:json_annotation/json_annotation.dart';

part 'task_models.g.dart';

@JsonSerializable()
class TasksRangeResponse {
  final Range range;
  final List<Task> tasks;

  TasksRangeResponse({
    required this.range,
    required this.tasks,
  });

  factory TasksRangeResponse.fromJson(Map<String, dynamic> json) =>
      _$TasksRangeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TasksRangeResponseToJson(this);
}

@JsonSerializable()
class Range {
  final String fromDate;
  final String toDate;

  Range({
    required this.fromDate,
    required this.toDate,
  });

  factory Range.fromJson(Map<String, dynamic> json) => _$RangeFromJson(json);

  Map<String, dynamic> toJson() => _$RangeToJson(this);
}

@JsonSerializable()
class Task {
  final String? cloudTaskId;
  final String startAt;
  final String status;
  final String uid;
  final String? remindAt;
  final String? completedAt;
  final String createdAt;
  final String title;
  final String? description;
  final int? reminderOffsetMinutes;
  final int durationMinutes;
  final String source;
  final bool allDay;
  final bool notificationSent;
  final bool autoScheduled;
  final String id;
  final String updatedAt;
  final String date;
  final Repeat? repeat;
  final bool? isRecurringInstance;
  final String? baseDate;

  Task({
    this.cloudTaskId,
    required this.startAt,
    required this.status,
    required this.uid,
    this.remindAt,
    this.completedAt,
    required this.createdAt,
    required this.title,
    this.description,
    this.reminderOffsetMinutes,
    required this.durationMinutes,
    required this.source,
    required this.allDay,
    required this.notificationSent,
    required this.autoScheduled,
    required this.id,
    required this.updatedAt,
    required this.date,
    this.repeat,
    this.isRecurringInstance,
    this.baseDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

@JsonSerializable()
class Repeat {
  final String? preset;
  final String? type;
  final dynamic custom;

  Repeat({
    this.preset,
    this.type,
    this.custom,
  });

  factory Repeat.fromJson(Map<String, dynamic> json) => _$RepeatFromJson(json);

  Map<String, dynamic> toJson() => _$RepeatToJson(this);
}
