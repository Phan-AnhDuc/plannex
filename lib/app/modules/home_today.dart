import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Components
import '../components/app_text.dart';
import 'home_page.dart';

class HomeTodayScreen extends StatefulWidget {
  final Function(int)? onTabChanged;

  const HomeTodayScreen({super.key, this.onTabChanged});

  @override
  State<HomeTodayScreen> createState() => _HomeTodayScreenState();
}

class _HomeTodayScreenState extends State<HomeTodayScreen> {
  // Sample task data
  final List<TaskGroup> _taskGroups = [
    TaskGroup(
      title: 'Morning',
      tasks: [
        TaskItem(
          id: '1',
          title: 'Design review meeting',
          time: '10:00 - 11:00 AM',
          isCompleted: true,
        ),
        TaskItem(
          id: '2',
          title: 'Finalize Q4 report',
          time: '11:00 AM - 12:00 PM',
          isCompleted: false,
        ),
      ],
    ),
    TaskGroup(
      title: 'Afternoon',
      tasks: [
        TaskItem(
          id: '3',
          title: 'Lunch with the team',
          time: '1:00 PM',
          isCompleted: false,
        ),
        TaskItem(
          id: '4',
          title: 'Code user authentication flow',
          time: '2:00 PM - 4:00 PM',
          isCompleted: false,
        ),
      ],
    ),
    TaskGroup(
      title: 'No time',
      tasks: [
        TaskItem(
          id: '5',
          title: 'Buy groceries for the week',
          time: null,
          isCompleted: false,
          tags: ['AI', 'Auto-scheduled'],
        ),
      ],
    ),
  ];

  int get _completedTasks =>
      _taskGroups.expand((g) => g.tasks).where((t) => t.isCompleted).length;

  int get _totalTasks =>
      _taskGroups.expand((g) => g.tasks).length;

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
                        ..._taskGroups.map((group) => _buildTaskGroup(group)),
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
                fontSize: 32,
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
            'Fri, Nov 28',
            textType: AppTextType.s16w4,
            color: const Color(0xFF6B7280),
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
      height: 8.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
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
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),

        // Tasks
        ...group.tasks.map((task) => _buildTaskItem(task)),

        SizedBox(height: 8.h),
      ],
    );
  }

  /// Single task item
  Widget _buildTaskItem(TaskItem task) {
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
              // Checkbox
              GestureDetector(
                onTap: () => _toggleTask(task),
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? const Color(0xFF2563EB)
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFD1D5DB),
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
                        color: task.isCompleted
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF1F2937),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: const Color(0xFF9CA3AF),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Time or tags
                    Row(
                      children: [
                        if (task.time != null)
                          AppText(
                            task.time!,
                            textType: AppTextType.s14w4,
                            color: const Color(0xFF6B7280),
                          ),
                        if (task.tags != null && task.tags!.isNotEmpty)
                          ...task.tags!.map((tag) => _buildTag(tag)),
                      ],
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

  /// Tag widget (AI, Auto-scheduled)
  Widget _buildTag(String tag) {
    final isAI = tag == 'AI';

    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isAI
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isAI
              ? const Color(0xFFFCD34D)
              : const Color(0xFF93C5FD),
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isAI
              ? const Color(0xFFD97706)
              : const Color(0xFF2563EB),
        ),
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
  void _toggleTask(TaskItem task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _onAddTask() {
    debugPrint('Add task');
  }

  void _onAIText() {
    debugPrint('AI text');
  }

  void _onVoice() {
    debugPrint('Voice');
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
  final String? time;
  bool isCompleted;
  final List<String>? tags;

  TaskItem({
    required this.id,
    required this.title,
    this.time,
    this.isCompleted = false,
    this.tags,
  });
}
