import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// Components
import '../components/app_text.dart';
import '../repository/repository.dart';
import '../data/models/task_models.dart';
import 'home_page.dart';
import 'new_task.dart';

class HomeTodayScreen extends StatefulWidget {
  final Function(int)? onTabChanged;

  const HomeTodayScreen({super.key, this.onTabChanged});

  @override
  HomeTodayScreenState createState() => _HomeTodayScreenState();
}

/// Public state base class so parent widgets (like `HomePage`) can trigger reloads.
abstract class HomeTodayScreenState extends State<HomeTodayScreen> {
  Future<void> reload();
}

class _HomeTodayScreenState extends HomeTodayScreenState {
  // Task data from API
  List<TaskGroup> _taskGroups = [];
  bool _isLoading = false;

  int get _completedTasks => _taskGroups.expand((g) => g.tasks).where((t) => t.isCompleted).length;

  int get _totalTasks => _taskGroups.expand((g) => g.tasks).length;

  @override
  void initState() {
    super.initState();
    _getTasksRange();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  String? _formatTime(String? startAt, int durationMinutes, {String? date}) {
    if (startAt == null || startAt.isEmpty) return null;
    try {
      DateTime start;

      // Check if startAt is just time format (HH:mm:ss) or full datetime
      if (startAt.length <= 8 && startAt.contains(':')) {
        // It's just time (e.g., "21:25:00"), need to combine with date
        if (date == null || date.isEmpty) return null;
        final timeParts = startAt.split(':');
        if (timeParts.length < 2) return null;

        final dateParts = date.split('-');
        if (dateParts.length != 3) return null;

        start = DateTime(
          int.parse(dateParts[0]), // year
          int.parse(dateParts[1]), // month
          int.parse(dateParts[2]), // day
          int.parse(timeParts[0]), // hour
          int.parse(timeParts[1]), // minute
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0, // second
        );
      } else {
        // It's full datetime, normalize format
        String normalized = startAt.trim();
        if (normalized.contains(' ') && !normalized.contains('T')) {
          normalized = normalized.replaceFirst(' ', 'T');
        }
        start = DateTime.parse(normalized);
      }

      final end = start.add(Duration(minutes: durationMinutes));
      final timeFormat = DateFormat('h:mm a');
      final startTime = timeFormat.format(start);
      final endTime = timeFormat.format(end);
      return '$startTime - $endTime';
    } catch (e) {
      debugPrint('Error formatting time: $e');
      return null;
    }
  }

  String _getTimeGroup(DateTime? startAt) {
    if (startAt == null) return 'No time';
    final hour = startAt.hour;
    if (hour >= 0 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Evening';
    }
  }

  List<TaskGroup> _groupTasksByTime(List<Task> tasks) {
    final Map<String, List<TaskItem>> grouped = {};

    for (final task in tasks) {
      DateTime? startDateTime;
      try {
        if (!task.allDay && task.startAt.isNotEmpty) {
          // Check if startAt is just time format (HH:mm:ss) or full datetime
          if (task.startAt.length <= 8 && task.startAt.contains(':')) {
            // It's just time, combine with date
            final timeParts = task.startAt.split(':');
            if (timeParts.length >= 2 && task.date.isNotEmpty) {
              final dateParts = task.date.split('-');
              if (dateParts.length == 3) {
                startDateTime = DateTime(
                  int.parse(dateParts[0]),
                  int.parse(dateParts[1]),
                  int.parse(dateParts[2]),
                  int.parse(timeParts[0]),
                  int.parse(timeParts[1]),
                  timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
                );
              }
            }
          } else {
            // It's full datetime
            String normalized = task.startAt.trim();
            if (normalized.contains(' ') && !normalized.contains('T')) {
              normalized = normalized.replaceFirst(' ', 'T');
            }
            startDateTime = DateTime.parse(normalized);
          }
        }
      } catch (e) {
        // If parsing fails, treat as no time
        debugPrint('Error parsing startAt: ${task.startAt}, date: ${task.date}, error: $e');
      }

      final groupTitle = _getTimeGroup(startDateTime);
      final isCompleted = task.status == 'DONE' || task.status == 'COMPLETED';

      final List<String>? tags = [];
      if (task.autoScheduled) {
        tags?.add('AI');
        tags?.add('Auto-scheduled');
      }

      final taskItem = TaskItem(
        id: task.id,
        title: task.title,
        startAt: task.startAt,
        date: task.date,
        durationMinutes: task.durationMinutes,
        isCompleted: isCompleted,
        priority: task.priority,
        tags: tags?.isNotEmpty == true ? tags : null,
        task: task, // Store full Task object for edit
      );

      if (!grouped.containsKey(groupTitle)) {
        grouped[groupTitle] = [];
      }
      grouped[groupTitle]!.add(taskItem);
    }

    // Sort groups: Morning, Afternoon, Evening, No time
    final groupOrder = ['Morning', 'Afternoon', 'Evening', 'No time'];
    final sortedGroups = <TaskGroup>[];

    for (final title in groupOrder) {
      if (grouped.containsKey(title) && grouped[title]!.isNotEmpty) {
        sortedGroups.add(TaskGroup(
          title: title,
          tasks: grouped[title]!,
        ));
      }
    }

    return sortedGroups;
  }

  Future<void> _getTasksRange() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final response = await Api.instance.restClient.getTasksRange(
        _formatDate(now),
        _formatDate(now),
        true,
        true,
      );

      if (mounted) {
        setState(() {
          _taskGroups = _groupTasksByTime(response.tasks);
        });
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Future<void> reload() async {
    await _getTasksRange();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header
                _buildHeader(),

                // Task list
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 100.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),
                        if (_isLoading && _taskGroups.isEmpty) ..._buildShimmerTaskGroups() else if (_taskGroups.isEmpty) _buildEmptyState() else ..._taskGroups.map((group) => _buildTaskGroup(group)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom action bar
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: _buildActionBar(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.onTabChanged != null
          ? AppBottomNavBar(
              currentIndex: 0,
              onTabChanged: widget.onTabChanged!,
            )
          : null,
    );
  }

  /// Header with title, date, progress
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with title and avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Today',
                textType: AppTextType.custom,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
              // Avatar
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5E7EB),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://api.dicebear.com/7.x/avataaars/png?seed=user',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Date
          AppText(
            _formatDisplayDate(DateTime.now()),
            textType: AppTextType.s16w4,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),

          SizedBox(height: 16.h),

          // Progress text
          AppText(
            '$_completedTasks/$_totalTasks tasks done',
            textType: AppTextType.s16w4,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),

          SizedBox(height: 8.h),

          // Progress bar
          _buildProgressBar(),
        ],
      ),
    );
  }

  /// Progress bar
  Widget _buildProgressBar() {
    final progress = _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0;
    return Container(
      width: double.infinity,
      height: 8.h,
      decoration: BoxDecoration(
        color: const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  /// Task group (Morning, Afternoon, No time)
  Widget _buildTaskGroup(TaskGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: AppText(
            group.title,
            textType: AppTextType.custom,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),

        // Tasks
        ...group.tasks.map((task) => _buildTaskItem(task)),

        SizedBox(height: 8.h),
      ],
    );
  }

  /// Empty state khi không có task nào
  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 120.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80.sp,
              color: const Color(0xFF9CA3AF),
            ),
            SizedBox(height: 24.h),
            AppText(
              'No tasks yet',
              textType: AppTextType.custom,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
            SizedBox(height: 8.h),
            AppText(
              'Create your first task to get started',
              textType: AppTextType.custom,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer-style placeholders while loading
  List<Widget> _buildShimmerTaskGroups() {
    // Show a couple of generic groups with placeholder items
    return [
      _buildShimmerGroup(),
      _buildShimmerGroup(),
    ];
  }

  Widget _buildShimmerGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Container(
            width: 120.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        _buildShimmerTaskItem(),
        _buildShimmerTaskItem(),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildShimmerTaskItem() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Circle placeholder
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              SizedBox(width: 12.w),
              // Text placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16.h,
                      width: 160.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 12.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Single task item with swipe actions
  Widget _buildTaskItem(TaskItem task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Slidable(
          key: ValueKey(task.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.4,
            children: [
              // Edit action
              SlidableAction(
                onPressed: (_) => _editTask(task),
                backgroundColor: const Color(0xFF9CA3AF).withOpacity(0.5),
                foregroundColor: Colors.black,
                icon: Icons.edit,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                ),
                flex: 1,
              ),
              // Delete action
              SlidableAction(
                onPressed: (_) => _deleteTask(task),
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                flex: 1,
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _toggleTask(task),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleTask(task),
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.isCompleted ? const Color(0xFF2563EB) : Colors.transparent,
                          border: Border.all(
                            color: task.isCompleted ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
                            width: 2,
                          ),
                        ),
                        child: task.isCompleted
                            ? Icon(
                                Icons.check,
                                size: 16.sp,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Task content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: task.isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: const Color(0xFF9CA3AF),
                            ),
                          ),

                          SizedBox(height: 4.h),

                          // Priority, Time or tags
                          Row(
                            children: [
                              if (task.priority != null) _buildPriorityTag(task.priority!),
                              if (task.priority != null) SizedBox(width: 8.w),
                              Builder(
                                builder: (context) {
                                  final displayTime = _formatTime(
                                    task.startAt,
                                    task.durationMinutes,
                                    date: task.date,
                                  );
                                  if (displayTime == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return AppText(
                                    displayTime,
                                    textType: AppTextType.s14w4,
                                    color: const Color(0xFF6B7280),
                                  );
                                },
                              ),
                              if (task.tags != null && task.tags!.isNotEmpty) ...task.tags!.map((tag) => _buildTag(tag)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Info button
                    GestureDetector(
                      onTap: () => _showTaskDetailSheet(task),
                      child: Icon(
                        Icons.info_outline,
                        size: 20.sp,
                        color: const Color(0xFF6B7280).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  /// Priority tag widget
  Widget _buildPriorityTag(String priority) {
    String displayText;
    Color backgroundColor;
    Color textColor;

    switch (priority.toUpperCase()) {
      case 'HIGH':
        displayText = 'High';
        backgroundColor = const Color(0xFFFFE5E5); // Light red
        textColor = const Color(0xFFDC2626); // Dark red
        break;
      case 'MEDIUM':
        displayText = 'Medium';
        backgroundColor = const Color(0xFFFFF4E5); // Light yellow/orange
        textColor = const Color(0xFFF59E0B); // Dark yellow/orange
        break;
      case 'LOW':
        displayText = 'Low';
        backgroundColor = const Color(0xFFE5F9E5); // Light green
        textColor = const Color(0xFF10B981); // Dark green
        break;
      default:
        displayText = priority;
        backgroundColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  /// Bottom sheet hiển thị chi tiết task + actions
  void _showTaskDetailSheet(TaskItem taskItem) {
    final task = taskItem.task;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            final dateText = _buildDateLabel(task.date);
            final timeRange = _formatTime(task.startAt, task.durationMinutes, date: task.date);
            final durationText = _buildDurationLabel(task.durationMinutes);
            final repeatText = _buildRepeatLabel(task);
            final reminderText = _buildReminderLabel(task);

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h + MediaQuery.of(context).padding.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Title + priority chip
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (task.priority != null)
                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: _buildPriorityTag(task.priority!),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (dateText != null)
                          Expanded(
                            flex: 3,
                            child: _buildDetailRow(
                              icon: Icons.calendar_today,
                              text: dateText,
                            ),
                          ),
                        Container(
                          width: 1,
                          height: 16.h,
                          color: const Color(0xFF4B5563).withOpacity(0.5),
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                        ),
                        if (timeRange != null)
                          Expanded(
                            flex: 4,
                            child: _buildDetailRow(
                              icon: Icons.access_time,
                              text: timeRange,
                            ),
                          ),
                      ],
                    ),

                    if (durationText != null)
                      _buildDetailRow(
                        icon: Icons.timer_outlined,
                        text: durationText,
                      ),
                    if (repeatText != null)
                      _buildDetailRow(
                        icon: Icons.repeat,
                        text: repeatText,
                      ),
                    if (reminderText != null)
                      _buildDetailRow(
                        icon: Icons.notifications_none,
                        text: reminderText,
                      ),

                    // Notes
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],

                    SizedBox(height: 20.h),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Đợi bottom sheet đóng rồi mới mở màn edit
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _editTask(taskItem);
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              side: const BorderSide(color: Color(0xFF2563EB)),
                            ),
                            child: Text(
                              'Edit Task',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Đánh dấu hoàn thành giống như click checkbox
                              _toggleTask(taskItem);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                            ),
                            child: Text(
                              'Mark as Done',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String? _buildDateLabel(String date) {
    if (date.isEmpty) return null;
    try {
      final parts = date.split('-');
      if (parts.length != 3) return date;
      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return DateFormat('EEEE, MMM d').format(dt);
    } catch (_) {
      return date;
    }
  }

  String? _buildDurationLabel(int minutes) {
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

  String? _buildRepeatLabel(Task task) {
    final repeat = task.repeat;
    if (repeat == null || repeat.type == null || repeat.type == 'NONE') {
      return 'Does not repeat';
    }
    if (repeat.type == 'PRESET') {
      switch (repeat.preset) {
        case 'EVERY_DAY':
          return 'Every day';
        case 'WEEKDAYS':
          return 'Weekdays (Mon-Fri)';
        default:
          return 'Repeats';
      }
    }
    if (repeat.type == 'CUSTOM') {
      return 'Custom repeat';
    }
    return 'Repeats';
  }

  String? _buildReminderLabel(Task task) {
    final minutes = task.reminderOffsetMinutes;
    if (minutes == null || minutes <= 0) return 'No reminder';
    if (minutes % 60 == 0) {
      final h = minutes ~/ 60;
      return '$h hour${h > 1 ? 's' : ''} before';
    }
    return '$minutes minutes before';
  }

  /// Tag widget (AI, Auto-scheduled)
  Widget _buildTag(String tag) {
    final isAI = tag == 'AI';

    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isAI ? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isAI ? const Color(0xFFFCD34D) : const Color(0xFF93C5FD),
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isAI ? const Color(0xFFD97706) : const Color(0xFF2563EB),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: const Color(0xFF6B7280),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom action bar
  Widget _buildActionBar() {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // + Task button
          Container(
            margin: EdgeInsets.all(4.w),
            child: ElevatedButton.icon(
              onPressed: _onAddTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              icon: Icon(Icons.add, size: 20.sp),
              label: Text(
                'Task',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // AI text button
          Expanded(
            child: GestureDetector(
              onTap: _onAIText,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20.sp,
                    color: const Color(0xFFD97706),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'AI\ntext',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Voice button
          Expanded(
            child: GestureDetector(
              onTap: _onVoice,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic_outlined,
                    size: 20.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Voice',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Actions
  Future<void> _toggleTask(TaskItem task) async {
    final bool wasCompleted = task.isCompleted;
    final String newStatus = wasCompleted ? 'PENDING' : 'DONE';

    // Optimistic update UI
    setState(() {
      task.isCompleted = !task.isCompleted;
    });

    try {
      await Api.instance.restClient.updateTask(task.id, {'status': newStatus});
    } catch (e) {
      // Revert UI on error
      if (mounted) {
        setState(() {
          task.isCompleted = wasCompleted;
        });
      }
      debugPrint('Error updating task status: $e');
    }
  }

  void _onAddTask() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewTaskScreen())).then((_) {
      if (mounted) _getTasksRange();
    });
  }

  void _onAIText() {
    debugPrint('AI text');
  }

  void _onVoice() {
    debugPrint('Voice');
  }

  /// Edit task - navigate to NewTaskScreen with task data
  void _editTask(TaskItem taskItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTaskScreen(taskToEdit: taskItem.task),
      ),
    ).then((_) {
      if (mounted) _getTasksRange();
    });
  }

  /// Delete task - call deleteTask API
  Future<void> _deleteTask(TaskItem taskItem) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${taskItem.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      EasyLoading.show(status: 'Deleting task...');
      await Api.instance.restClient.deleteTask(taskItem.id);
      EasyLoading.dismiss();

      if (mounted) {
        EasyLoading.showSuccess('Task deleted successfully!');
        await _getTasksRange();
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) {
        EasyLoading.showError('Failed to delete task: ${e.toString()}');
      }
    }
  }
}

// Data models
class TaskGroup {
  final String title;
  final List<TaskItem> tasks;

  TaskGroup({
    required this.title,
    required this.tasks,
  });
}

class TaskItem {
  final String id;
  final String title;
  final String startAt;
  final String date;
  final int durationMinutes;
  bool isCompleted;
  final String? priority;
  final List<String>? tags;
  final Task task; // Full Task object for edit

  TaskItem({
    required this.id,
    required this.title,
    required this.startAt,
    required this.date,
    required this.durationMinutes,
    this.isCompleted = false,
    this.priority,
    this.tags,
    required this.task,
  });
}
