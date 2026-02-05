import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../repository/repository.dart';
import 'home_page.dart';
import 'home_today.dart';

/// Screen hiển thị danh sách task gợi ý từ AI và cho phép chọn để auto-schedule.
class AiGenTaskScreen extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;

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
    Map<String, dynamic> task,
    bool selected,
    VoidCallback onToggle,
  ) {
    final title = (task['title'] ?? '') as String;
    final description = task['description'] as String?;
    final dateTimeText = _formatDateTime(task);
    final durationText = _formatDuration(task['durationMinutes']);
    final reminderText = _formatReminder(task['reminderOffsetMinutes']);

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
            if (description != null && description.isNotEmpty)
              _buildDetailRow(
                icon: Icons.description_outlined,
                text: description,
              ),
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

  String? _formatDateTime(Map<String, dynamic> task) {
    final date = task['date'] as String?;
    final time = task['startAt'] as String?;
    if ((date == null || date.isEmpty) && (time == null || time.isEmpty)) {
      return null;
    }
    if (date != null && time != null && time.isNotEmpty) {
      final hhmm = time.length >= 5 ? time.substring(0, 5) : time;
      return '$date, $hhmm';
    }
    return date ?? time;
  }

  String? _formatDuration(dynamic value) {
    if (value == null) return null;
    final minutes = value is int ? value : int.tryParse(value.toString()) ?? 0;
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

  String? _formatReminder(dynamic value) {
    if (value == null) return null;
    final minutes = value is int ? value : int.tryParse(value.toString()) ?? 0;
    if (minutes <= 0) return null;
    return '$minutes minutes before';
  }

  List<Map<String, dynamic>> _buildSelectedTasksBody() {
    final list = <Map<String, dynamic>>[];
    for (int i = 0; i < widget.tasks.length; i++) {
      if (!_selected[i]) continue;
      final t = widget.tasks[i];
      final date = t['date'] as String? ?? '';
      final startAtRaw = t['startAt'] as String?;
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
      final priority = t['priority'] as String? ?? 'MEDIUM';
      final taskMap = <String, dynamic>{
        'title': t['title'] ?? '',
        'date': date,
        'priority': priority,
      };
      if (startAtStr != null) taskMap['startAt'] = startAtStr;
      if (t['description'] != null && (t['description'] as String).isNotEmpty) {
        taskMap['description'] = t['description'];
      }
      if (t['durationMinutes'] != null) taskMap['durationMinutes'] = t['durationMinutes'];
      if (t['reminderOffsetMinutes'] != null) taskMap['reminderOffsetMinutes'] = t['reminderOffsetMinutes'];
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
      // Điều hướng về HomePage với tab Today (HomeTodayScreen)
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
