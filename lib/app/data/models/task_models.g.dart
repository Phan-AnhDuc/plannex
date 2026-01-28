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
    };

Repeat _$RepeatFromJson(Map<String, dynamic> json) => Repeat(
      preset: json['preset'] as String?,
      type: json['type'] as String?,
      custom: json['custom'],
    );

Map<String, dynamic> _$RepeatToJson(Repeat instance) => <String, dynamic>{
      'preset': instance.preset,
      'type': instance.type,
      'custom': instance.custom,
    };
