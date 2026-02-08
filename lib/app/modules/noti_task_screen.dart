import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibration/vibration.dart';

import '../data/models/task_models.dart';
import '../repository/repository.dart';
import 'home_page.dart';
import 'new_task.dart';

class NotiTaskScreen extends StatefulWidget {
  final String? taskId;
  final Task? task;
  final String taskTitle;
  final String timeRange;
  final int startsInMinutes;

  const NotiTaskScreen({
    super.key,
    this.taskId,
    this.task,
    required this.taskTitle,
    required this.timeRange,
    this.startsInMinutes = 15,
  });

  @override
  State<NotiTaskScreen> createState() => _NotiTaskScreenState();
}

class _NotiTaskScreenState extends State<NotiTaskScreen> {
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _bgLight = Color(0xFFF8F9FC);

  @override
  void initState() {
    super.initState();
    _triggerAlarm();
  }

  Future<void> _triggerAlarm() async {
    // Rung liên tục: pattern lặp cho đến khi gọi _stopAlarm (Vibration.cancel)
    try {
      final hasVibrator = await Vibration.hasVibrator();
      debugPrint('NotiTaskScreen vibration: hasVibrator=$hasVibrator');
      if (hasVibrator != false) {
        try {
          // pattern: [chờ, rung, chờ, rung] (ms). repeat: 0 = lặp từ đầu pattern.
          await Vibration.vibrate(
            pattern: [0, 400, 200, 400],
            repeat: 0,
          );
        } catch (e) {
          debugPrint('NotiTaskScreen vibration pattern failed: $e');
          HapticFeedback.heavyImpact();
        }
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      debugPrint('NotiTaskScreen vibration failed: $e');
      HapticFeedback.heavyImpact();
    }
    try {
      FlutterRingtonePlayer().playAlarm(asAlarm: true);
    } catch (_) {}
  }

  void _stopAlarm() {
    try {
      Vibration.cancel();
    } catch (_) {}
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _stopAlarm();
      },
      child: Scaffold(
        backgroundColor: _bgLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 32.h),
                      _AnimatedAlarmIcon(primaryBlue: _primaryBlue),
                      SizedBox(height: 24.h),
                      Text(
                        widget.taskTitle,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.timeRange,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: _textDark,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _startsInText(widget.startsInMinutes),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 200.h),
                    // Spacer(),
                    _buildMarkAsDoneButton(context),
                    SizedBox(height: 24.h),
                    Text(
                      'Snooze for:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _textGrey,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildSnoozeButtons(context),
                    // SizedBox(height: 32.h),
                    // _buildEditTaskLink(context),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 8.h,left: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Task Reminder',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ),
          ),
          SizedBox(width: 24.w),
        ],
      ),
    );
  }

  String _startsInText(int minutes) {
    if (minutes <= 0) return 'Starting now';
    if (minutes == 1) return 'Starts in 1 minute';
    return 'Starts in $minutes minutes';
  }

  Widget _buildMarkAsDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _onMarkAsDone(context),
        icon: Icon(Icons.check, size: 22.sp, color: Colors.white),
        label: Text(
          'Mark as done',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildSnoozeButtons(BuildContext context) {
    final options = [
      ('5 min', 5),
      ('10 min', 10),
      ('30 min', 30),
    ];
    return Row(
      children: options.map((e) {
        final (label, minutes) = e;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: OutlinedButton(
              onPressed: () => _onSnooze(context, minutes),
              style: OutlinedButton.styleFrom(
                foregroundColor: _textGrey,
                side: BorderSide(color: _primaryBlue.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),

                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: _primaryBlue,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEditTaskLink(BuildContext context) {
    return GestureDetector(
      onTap: () => _onEditTask(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_outlined,
            size: 20.sp,
            color: _textDark,
          ),
          SizedBox(width: 8.w),
          Text(
            'Edit Task Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _goToHome(BuildContext context) {
    if (!context.mounted) return;
    _stopAlarm();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage(initialIndex: 0)),
      (route) => false,
    );
  }

  Future<void> _onMarkAsDone(BuildContext context) async {
    if (widget.task == null) return;
    try {
      await Api.instance.restClient.updateTask(widget.task!.id, {'status': 'DONE'});
    } catch (e) {
      debugPrint('Error updating task status: $e');
    }
    _goToHome(context);
  }

  Future<void> _onSnooze(BuildContext context, int minutes) async {
    if (widget.task == null) return;
    final currentOffset = widget.task!.reminderOffsetMinutes ?? 0;
    final newOffset = currentOffset + minutes;
    try {
      await Api.instance.restClient.updateTask(
        widget.task!.id,
        {'reminderOffsetMinutes': newOffset},
      );
    } catch (e) {
      debugPrint('Error updating task snooze: $e');
    }
    _goToHome(context);
  }

  void _onEditTask(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NewTaskScreen(),
      ),
    );
  }
}

/// Đồng hồ alarm có animation pulse + vòng sáng lan ra.
class _AnimatedAlarmIcon extends StatefulWidget {
  final Color primaryBlue;

  const _AnimatedAlarmIcon({required this.primaryBlue});

  @override
  State<_AnimatedAlarmIcon> createState() => _AnimatedAlarmIconState();
}

class _AnimatedAlarmIconState extends State<_AnimatedAlarmIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Kích thước cố định để animation không làm thay đổi height của màn.
  static double get _fixedSize => 112.w;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _fixedSize,
      height: _fixedSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.hardEdge,
            children: [
              // Vòng sáng lan ra (pulse ring) — bị clip trong SizedBox, không đẩy layout
              ...List.generate(2, (i) {
                final t = (_controller.value + i * 0.5) % 1.0;
                final scale = 1.0 + t * 0.35;
                final opacity = (1.0 - t) * 0.4;
                return Center(
                  child: Container(
                    width: 80.w * scale,
                    height: 80.w * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.primaryBlue.withOpacity(opacity),
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
              // Nền tròn + icon (scale nhẹ) — Transform.scale không ảnh hưởng layout
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: widget.primaryBlue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.alarm,
                    size: 44.sp,
                    color: widget.primaryBlue,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
