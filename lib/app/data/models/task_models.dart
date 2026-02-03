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
class TasksCountResponse {
  final Range range;
  final List<DateCount> counts;

  TasksCountResponse({
    required this.range,
    required this.counts,
  });

  factory TasksCountResponse.fromJson(Map<String, dynamic> json) =>
      _$TasksCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TasksCountResponseToJson(this);
}

@JsonSerializable()
class DateCount {
  final String date;
  final int count;

  DateCount({
    required this.date,
    required this.count,
  });

  factory DateCount.fromJson(Map<String, dynamic> json) =>
      _$DateCountFromJson(json);

  Map<String, dynamic> toJson() => _$DateCountToJson(this);
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
  final String? priority;

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
    this.priority,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

@JsonSerializable()
class Repeat {
  /// Type of repeat: e.g. PRESET, CUSTOM, NONE
  final String? type;

  /// Preset name when type == PRESET (e.g. EVERY_DAY, WEEKDAYS)
  final String? preset;

  /// Custom configuration when type == CUSTOM
  final RepeatCustom? custom;

  Repeat({
    this.type,
    this.preset,
    this.custom,
  });

  factory Repeat.fromJson(Map<String, dynamic> json) => _$RepeatFromJson(json);

  Map<String, dynamic> toJson() => _$RepeatToJson(this);
}

@JsonSerializable()
class RepeatCustom {
  /// Frequency: DAILY or WEEKLY
  final String frequency;

  /// Interval between repeats (e.g. every 1 week)
  final int interval;

  /// Range settings: forever / until date / count
  final RepeatRange range;

  /// Weekdays when frequency == WEEKLY, e.g. ["TUE","WED","THU","SUN"]
  final List<String>? weekdays;

  RepeatCustom({
    required this.frequency,
    required this.interval,
    required this.range,
    this.weekdays,
  });

  factory RepeatCustom.fromJson(Map<String, dynamic> json) =>
      _$RepeatCustomFromJson(json);

  Map<String, dynamic> toJson() => _$RepeatCustomToJson(this);
}

@JsonSerializable()
class RepeatRange {
  /// Mode: FOREVER, UNTIL_DATE, COUNT
  final String mode;

  /// Used when mode == COUNT
  final int? count;

  /// Used when mode == UNTIL_DATE (yyyy-MM-dd)
  final String? untilDate;

  RepeatRange({
    required this.mode,
    this.count,
    this.untilDate,
  });

  factory RepeatRange.fromJson(Map<String, dynamic> json) =>
      _$RepeatRangeFromJson(json);

  Map<String, dynamic> toJson() => _$RepeatRangeToJson(this);
}
