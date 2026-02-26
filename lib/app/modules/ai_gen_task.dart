import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../data/models/task_models.dart';
import '../repository/repository.dart';
import 'home_page.dart';

/// Screen hiển thị danh sách task gợi ý từ AI và cho phép chọn để auto-schedule.
class AiGenTaskScreen extends StatefulWidget {
  final List<Task> tasks;

  const AiGenTaskScreen({
    super.key,
    required this.tasks,
  });

  @override
  State<AiGenTaskScreen> createState() => _AiGenTaskScreenState();
}

class _AiGenTaskScreenState extends State<AiGenTaskScreen> {
  late List<bool> _selected;
  bool _submitting = false;

  static const Color _screenBg = Color(0xFFF5F5F5);
  static const Color _cardBg = Colors.white;
  static const Color _primaryBlue = Color(0xFF3A00FF);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMedium = Color(0xFF6B7280);
  static const Color _badgeBg = Color(0xFFE0E7FF);

  @override
  void initState() {
    super.initState();
    _selected = List<bool>.filled(widget.tasks.length, true);
  }

  int get _selectedCount => _selected.where((e) => e).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20.sp,
                      color: _textDark,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'AI Planner',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w), // cân khoảng trống với nút back bên trái
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Suggested tasks',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.tasks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final task = widget.tasks[index];
                    final selected = _selected[index];
                    return _buildTaskCard(task, selected, () {
                      setState(() => _selected[index] = !selected);
                    });
                  },
                ),
              ),
              SizedBox(height: 12.h),
              if (_selectedCount > 0)
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _badgeBg,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      _selectedCount == 1 ? '1 task selected' : '$_selectedCount tasks selected',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: _primaryBlue,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCount == 0 || _submitting ? null : _onAddAndAutoSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    disabledBackgroundColor: _primaryBlue.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: _submitting
                      ? SizedBox(
                          height: 22.h,
                          width: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Add & auto-schedule',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    Task task,
    bool selected,
    VoidCallback onToggle,
  ) {
    final title = task.title ?? '';
    final description = task.description;
    final dateTimeText = _formatDateTime(task);
    final durationText = _formatDuration(task.durationMinutes);
    final reminderText = _formatReminder(task.reminderOffsetMinutes);
    final repeatText = _formatRepeat(task);
    // final sourceText = _formatSource(task.source);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? _primaryBlue.withOpacity(0.7) : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24.w,
                  width: 24.w,
                  child: Checkbox(
                    value: selected,
                    onChanged: (_) => onToggle(),
                    activeColor: _primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    side: BorderSide(
                      color: selected
                          ? _primaryBlue
                          : _textMedium.withOpacity(0.4),
                      width: 1.4,
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (dateTimeText != null)
              _buildDetailRow(
                icon: Icons.calendar_today_outlined,
                text: dateTimeText,
              ),
            if (durationText != null)
              _buildDetailRow(
                icon: Icons.access_time,
                text: durationText,
              ),
            if (reminderText != null)
              _buildDetailRow(
                icon: Icons.notifications_none,
                text: reminderText,
              ),
            if (repeatText != null)
              _buildDetailRow(
                icon: Icons.repeat,
                text: repeatText,
              ),
            // if (sourceText != null)
            //   _buildDetailRow(
            //     icon: Icons.tips_and_updates_outlined,
            //     text: sourceText,
            //   ),
            // if (description != null && description.isNotEmpty)
            //   _buildDetailRow(
            //     icon: Icons.description_outlined,
            //     text: description,
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: _textMedium,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: _textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _formatDateTime(Task task) {
    final date = task.date;
    final time = task.startAt;
    final isAllDay = task.allDay == true;
    if ((date == null || date.isEmpty) && (time == null || time.isEmpty)) {
      return null;
    }
    if (date != null && time != null && time.isNotEmpty) {
      final hhmm = time.length >= 5 ? time.substring(0, 5) : time;
      return isAllDay ? '$date (all day, $hhmm)' : '$date, $hhmm';
    }
    if (date != null) {
      return isAllDay ? '$date (all day)' : date;
    }
    return time;
  }

  String? _formatDuration(int? minutes) {
    if (minutes == null) return null;
    if (minutes <= 0) return null;
    if (minutes % 60 == 0) {
      final h = minutes ~/ 60;
      return '$h hour${h > 1 ? 's' : ''}';
    }
    if (minutes > 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return '$h h $m min';
    }
    return '$minutes minutes';
  }

  String? _formatReminder(int? minutes) {
    if (minutes == null) return null;
    if (minutes <= 0) return null;
    return '$minutes minutes before';
  }

  String? _formatRepeat(Task task) {
    final repeat = task.repeat;
    if (repeat == null || repeat.type == null || repeat.type == 'NONE') {
      return null;
    }

    if (repeat.type == 'PRESET') {
      switch (repeat.preset) {
        case 'EVERY_DAY':
          return 'Repeats every day';
        case 'WEEKDAYS':
          return 'Repeats on weekdays (Mon–Fri)';
        default:
          return 'Repeats (${repeat.preset})';
      }
    }

    final custom = repeat.custom;
    if (repeat.type == 'CUSTOM' && custom != null) {
      final freq = custom.frequency; // DAILY | WEEKLY
      final interval = custom.interval;
      if (freq == 'DAILY') {
        return interval == 1 ? 'Repeats every day' : 'Repeats every $interval days';
      }
      if (freq == 'WEEKLY') {
        final days = custom.weekdays;
        String daysText;
        if (days == null || days.isEmpty) {
          daysText = '';
        } else {
          daysText = days.join(', ');
        }
        if (interval == 1) {
          return daysText.isEmpty ? 'Repeats every week' : 'Repeats every week on $daysText';
        }
        return daysText.isEmpty
            ? 'Repeats every $interval weeks'
            : 'Repeats every $interval weeks on $daysText';
      }
    }

    return 'Repeats';
  }

  String? _formatSource(String? source) {
    if (source == null || source.isEmpty) return null;
    final upper = source.toUpperCase();
    if (upper == 'AI_TEXT') {
      return 'Generated from AI text';
    }
    if (upper == 'VOICE') {
      return 'Generated from voice input';
    }
    return 'Source: $source';
  }

  List<Map<String, dynamic>> _buildSelectedTasksBody() {
    final list = <Map<String, dynamic>>[];
    for (int i = 0; i < widget.tasks.length; i++) {
      if (!_selected[i]) continue;
      final t = widget.tasks[i];
      final date = t.date ?? '';
      final startAtRaw = t.startAt;
      // Chuẩn hóa startAt về dạng "09:00:00"
      String? startAtStr;
      if (startAtRaw != null && startAtRaw.isNotEmpty) {
        if (startAtRaw.length >= 8) {
          startAtStr = startAtRaw;
        } else if (startAtRaw.length == 5) {
          startAtStr = '$startAtRaw:00';
        } else {
          startAtStr = startAtRaw;
        }
      }
      final priority = t.priority ?? 'MEDIUM';
      final taskMap = <String, dynamic>{
        'title': t.title ?? '',
        'date': date,
        'priority': priority,
      };
      if (startAtStr != null) taskMap['startAt'] = startAtStr;
      if (t.description != null && t.description!.isNotEmpty) {
        taskMap['description'] = t.description;
      }
      if (t.durationMinutes != null) taskMap['durationMinutes'] = t.durationMinutes;
      if (t.reminderOffsetMinutes != null) taskMap['reminderOffsetMinutes'] = t.reminderOffsetMinutes;
      if (t.allDay != null) taskMap['allDay'] = t.allDay;
      if (t.source != null) taskMap['source'] = t.source;
      if (t.repeat != null) taskMap['repeat'] = t.repeat!.toJson();
      list.add(taskMap);
    }
    return list;
  }

  Future<void> _onAddAndAutoSchedule() async {
    if (_selectedCount == 0 || _submitting) return;
    setState(() => _submitting = true);

    try {
      final tasksList = _buildSelectedTasksBody();
      final body = <String, dynamic>{'tasks': tasksList};

      await Api.instance.restClient.bulkCreateTasks(body);

      if (!mounted) return;
      setState(() => _submitting = false);
      EasyLoading.showSuccess('Tasks added successfully!');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage(initialIndex: 0)),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        EasyLoading.showError('Failed to add tasks: ${e.toString()}');
      }
    }
  }
}
