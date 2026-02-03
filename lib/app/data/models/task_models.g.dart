// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TasksRangeResponse _$TasksRangeResponseFromJson(Map<String, dynamic> json) =>
    TasksRangeResponse(
      range: Range.fromJson(json['range'] as Map<String, dynamic>),
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TasksRangeResponseToJson(TasksRangeResponse instance) =>
    <String, dynamic>{
      'range': instance.range,
      'tasks': instance.tasks,
    };

Range _$RangeFromJson(Map<String, dynamic> json) => Range(
      fromDate: json['fromDate'] as String,
      toDate: json['toDate'] as String,
    );

Map<String, dynamic> _$RangeToJson(Range instance) => <String, dynamic>{
      'fromDate': instance.fromDate,
      'toDate': instance.toDate,
    };

TasksCountResponse _$TasksCountResponseFromJson(Map<String, dynamic> json) =>
    TasksCountResponse(
      range: Range.fromJson(json['range'] as Map<String, dynamic>),
      counts: (json['counts'] as List<dynamic>)
          .map((e) => DateCount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TasksCountResponseToJson(TasksCountResponse instance) =>
    <String, dynamic>{
      'range': instance.range,
      'counts': instance.counts,
    };

DateCount _$DateCountFromJson(Map<String, dynamic> json) => DateCount(
      date: json['date'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$DateCountToJson(DateCount instance) => <String, dynamic>{
      'date': instance.date,
      'count': instance.count,
    };

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      cloudTaskId: json['cloudTaskId'] as String?,
      startAt: json['startAt'] as String,
      status: json['status'] as String,
      uid: json['uid'] as String,
      remindAt: json['remindAt'] as String?,
      completedAt: json['completedAt'] as String?,
      createdAt: json['createdAt'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      reminderOffsetMinutes: (json['reminderOffsetMinutes'] as num?)?.toInt(),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      source: json['source'] as String,
      allDay: json['allDay'] as bool,
      notificationSent: json['notificationSent'] as bool,
      autoScheduled: json['autoScheduled'] as bool,
      id: json['id'] as String,
      updatedAt: json['updatedAt'] as String,
      date: json['date'] as String,
      repeat: json['repeat'] == null
          ? null
          : Repeat.fromJson(json['repeat'] as Map<String, dynamic>),
      isRecurringInstance: json['isRecurringInstance'] as bool?,
      baseDate: json['baseDate'] as String?,
      priority: json['priority'] as String?,
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'cloudTaskId': instance.cloudTaskId,
      'startAt': instance.startAt,
      'status': instance.status,
      'uid': instance.uid,
      'remindAt': instance.remindAt,
      'completedAt': instance.completedAt,
      'createdAt': instance.createdAt,
      'title': instance.title,
      'description': instance.description,
      'reminderOffsetMinutes': instance.reminderOffsetMinutes,
      'durationMinutes': instance.durationMinutes,
      'source': instance.source,
      'allDay': instance.allDay,
      'notificationSent': instance.notificationSent,
      'autoScheduled': instance.autoScheduled,
      'id': instance.id,
      'updatedAt': instance.updatedAt,
      'date': instance.date,
      'repeat': instance.repeat,
      'isRecurringInstance': instance.isRecurringInstance,
      'baseDate': instance.baseDate,
      'priority': instance.priority,
    };

Repeat _$RepeatFromJson(Map<String, dynamic> json) => Repeat(
      type: json['type'] as String?,
      preset: json['preset'] as String?,
      custom: json['custom'] == null
          ? null
          : RepeatCustom.fromJson(json['custom'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RepeatToJson(Repeat instance) => <String, dynamic>{
      'type': instance.type,
      'preset': instance.preset,
      'custom': instance.custom,
    };

RepeatCustom _$RepeatCustomFromJson(Map<String, dynamic> json) => RepeatCustom(
      frequency: json['frequency'] as String,
      interval: (json['interval'] as num).toInt(),
      range: RepeatRange.fromJson(json['range'] as Map<String, dynamic>),
      weekdays: (json['weekdays'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$RepeatCustomToJson(RepeatCustom instance) =>
    <String, dynamic>{
      'frequency': instance.frequency,
      'interval': instance.interval,
      'range': instance.range,
      'weekdays': instance.weekdays,
    };

RepeatRange _$RepeatRangeFromJson(Map<String, dynamic> json) => RepeatRange(
      mode: json['mode'] as String,
      count: (json['count'] as num?)?.toInt(),
      untilDate: json['untilDate'] as String?,
    );

Map<String, dynamic> _$RepeatRangeToJson(RepeatRange instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'count': instance.count,
      'untilDate': instance.untilDate,
    };
