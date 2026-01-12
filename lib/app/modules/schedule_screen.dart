import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// Components
import '../components/app_text.dart';
import 'home_page.dart';

class ScheduleScreen extends StatefulWidget {
  final Function(int)? onTabChanged;

  const ScheduleScreen({super.key, this.onTabChanged});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // View mode: 0 = Day, 1 = Week, 2 = Month
  int _viewMode = 0;

  // Selected date
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  // Sample tasks data
  final List<ScheduleTask> _tasks = [
    ScheduleTask(
      id: '1',
      title: 'Draft Q1 marketing plan',
      startTime: DateTime(2025, 11, 28, 9, 0),
      endTime: DateTime(2025, 11, 28, 9, 30),
      color: const Color(0xFFDBEAFE),
      dotColor: const Color(0xFFF59E0B),
      category: 'Work',
    ),
    ScheduleTask(
      id: '2',
      title: 'Review new design mockups',
      startTime: DateTime(2025, 11, 28, 10, 0),
      endTime: DateTime(2025, 11, 28, 11, 0),
      color: const Color(0xFFF3F4F6),
      isCompleted: true,
      category: 'Work',
    ),
    ScheduleTask(
      id: '3',
      title: 'Prepare for client call',
      startTime: DateTime(2025, 11, 28, 11, 15),
      endTime: DateTime(2025, 11, 28, 12, 0),
      color: const Color(0xFFF3F4F6),
      category: 'Personal',
    ),
    ScheduleTask(
      id: '4',
      title: 'Team Standup',
      startTime: DateTime(2025, 11, 28, 11, 30),
      endTime: DateTime(2025, 11, 28, 12, 30),
      color: const Color(0xFFF3F4F6),
      category: 'Work',
    ),
    // Week view tasks
    ScheduleTask(
      id: '5',
      title: 'Project Kick-off',
      startTime: DateTime(2025, 11, 24, 10, 0),
      endTime: DateTime(2025, 11, 24, 11, 0),
      color: const Color(0xFFFDE047),
      category: 'Work',
    ),
    ScheduleTask(
      id: '6',
      title: 'Design Review\nDiscuss new mockups',
      startTime: DateTime(2025, 11, 26, 9, 0),
      endTime: DateTime(2025, 11, 26, 11, 30),
      color: const Color(0xFF93C5FD),
      category: 'Work',
    ),
    ScheduleTask(
      id: '7',
      title: 'Team Sync',
      startTime: DateTime(2025, 11, 25, 14, 0),
      endTime: DateTime(2025, 11, 25, 15, 0),
      color: const Color(0xFF86EFAC),
      category: 'Work',
    ),
    ScheduleTask(
      id: '8',
      title: '1:1 with Manager',
      startTime: DateTime(2025, 11, 28, 22, 0),
      endTime: DateTime(2025, 11, 28, 23, 0),
      color: const Color(0xFFD8B4FE),
      category: 'Work',
    ),
    ScheduleTask(
      id: '9',
      title: 'Client Call',
      startTime: DateTime(2025, 11, 26, 23, 30),
      endTime: DateTime(2025, 11, 27, 0, 30),
      color: const Color(0xFFFDE047),
      category: 'Work',
    ),
  ];

  List<ScheduleTask> get _tasksForSelectedDay {
    return _tasks.where((task) {
      return task.startTime.year == _selectedDate.year &&
          task.startTime.month == _selectedDate.month &&
          task.startTime.day == _selectedDate.day;
    }).toList();
  }

  int get _unscheduledTaskCount => 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tab switcher
            _buildViewModeTabs(),

            // Content based on view mode
            Expanded(
              child: _viewMode == 0
                  ? _buildDayView()
                  : _viewMode == 1
                      ? _buildWeekView()
                      : _buildMonthView(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.onTabChanged != null
          ? AppBottomNavBar(
              currentIndex: 1,
              onTabChanged: widget.onTabChanged!,
            )
          : null,
    );
  }

  /// Header with title and today button
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            'Schedule',
            textType: AppTextType.custom,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
          // Today button
          GestureDetector(
            onTap: _goToToday,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  SizedBox(width: 6.w),
                  AppText(
                    'Today',
                    textType: AppTextType.s14w4,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// View mode tabs (Day, Week, Month)
  Widget _buildViewModeTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(22.r),
        ),
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            _buildViewModeTab('Day', 0),
            _buildViewModeTab('Week', 1),
            _buildViewModeTab('Month', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeTab(String label, int index) {
    final isSelected = _viewMode == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = index),
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: AppText(
            label,
            textType: AppTextType.s14w4,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF1F2937)
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  // ============ DAY VIEW ============
  Widget _buildDayView() {
    return Column(
      children: [
        SizedBox(height: 16.h),

        // Horizontal date picker
        _buildHorizontalDatePicker(),

        SizedBox(height: 16.h),

        // Unscheduled tasks banner
        _buildUnscheduledBanner(),

        // Timeline
        Expanded(
          child: _buildDayTimeline(),
        ),
      ],
    );
  }

  Widget _buildHorizontalDatePicker() {
    final today = DateTime.now();
    final dates = List.generate(7, (i) => today.add(Duration(days: i)));

    return SizedBox(
      height: 80.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _selectedDate.day == date.day &&
              _selectedDate.month == date.month;
          final isToday = date.day == today.day && date.month == today.month;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 64.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    isToday
                        ? 'TODAY'
                        : DateFormat('E').format(date).toUpperCase(),
                    textType: AppTextType.custom,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF6B7280),
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    date.day.toString(),
                    textType: AppTextType.custom,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF1F2937),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnscheduledBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            'You have $_unscheduledTaskCount unscheduled tasks',
            textType: AppTextType.s14w4,
            color: const Color(0xFF6B7280),
          ),
          GestureDetector(
            onTap: () {},
            child: AppText(
              'Manage',
              textType: AppTextType.s14w4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTimeline() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: List.generate(12, (index) {
          final hour = 8 + index;
          final tasksAtHour = _tasksForSelectedDay.where((task) {
            return task.startTime.hour == hour;
          }).toList();

          return _buildTimelineRow(hour, tasksAtHour);
        }),
      ),
    );
  }

  Widget _buildTimelineRow(int hour, List<ScheduleTask> tasks) {
    return SizedBox(
      height: 80.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 50.w,
            child: AppText(
              '${hour.toString().padLeft(2, '0')}:00',
              textType: AppTextType.s14w4,
              color: const Color(0xFF9CA3AF),
            ),
          ),

          // Vertical line
          Container(
            width: 1,
            color: const Color(0xFFE5E7EB),
          ),

          SizedBox(width: 16.w),

          // Tasks
          Expanded(
            child: tasks.isEmpty
                ? const SizedBox.shrink()
                : Wrap(
                    spacing: 8.w,
                    children: tasks.map((task) => _buildDayTaskCard(task)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTaskCard(ScheduleTask task) {
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: task.color,
        borderRadius: BorderRadius.circular(12.r),
        border: task.dotColor != null
            ? Border(
                left: BorderSide(
                  color: task.dotColor!,
                  width: 3,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            task.title,
            textType: AppTextType.s16w4,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              if (task.dotColor != null) ...[
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: task.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
              ],
              AppText(
                '${timeFormat.format(task.startTime)}-${timeFormat.format(task.endTime)}',
                textType: AppTextType.s14w4,
                color: task.dotColor ?? const Color(0xFF6B7280),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ WEEK VIEW ============
  Widget _buildWeekView() {
    return Column(
      children: [
        SizedBox(height: 16.h),

        // Week navigation
        _buildWeekNavigation(),

        SizedBox(height: 16.h),

        // Week grid
        Expanded(
          child: _buildWeekGrid(),
        ),
      ],
    );
  }

  Widget _buildWeekNavigation() {
    final startOfWeek = _focusedDate.subtract(
      Duration(days: _focusedDate.weekday - 1),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _focusedDate = _focusedDate.subtract(const Duration(days: 7));
            }),
            child: Icon(
              Icons.chevron_left,
              size: 24.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          AppText(
            'Week of ${DateFormat('MMM d').format(startOfWeek)}-${endOfWeek.day}',
            textType: AppTextType.s16w4,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _focusedDate = _focusedDate.add(const Duration(days: 7));
            }),
            child: Icon(
              Icons.chevron_right,
              size: 24.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekGrid() {
    final startOfWeek = _focusedDate.subtract(
      Duration(days: _focusedDate.weekday - 1),
    );
    final days = List.generate(5, (i) => startOfWeek.add(Duration(days: i)));

    return SingleChildScrollView(
      child: Column(
        children: [
          // Day headers
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                SizedBox(width: 40.w),
                ...days.map((day) {
                  final isToday = day.day == DateTime.now().day &&
                      day.month == DateTime.now().month;
                  return Expanded(
                    child: Column(
                      children: [
                        AppText(
                          DateFormat('E').format(day).toUpperCase(),
                          textType: AppTextType.custom,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: isToday
                                ? const Color(0xFF6366F1)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: AppText(
                            day.day.toString(),
                            textType: AppTextType.s14w4,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Time grid
          ...List.generate(9, (index) {
            final hour = 8 + (index * 2);
            return _buildWeekTimeRow(hour, days);
          }),
        ],
      ),
    );
  }

  Widget _buildWeekTimeRow(int hour, List<DateTime> days) {
    return SizedBox(
      height: 60.h,
      child: Row(
        children: [
          // Time label
          SizedBox(
            width: 40.w,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: AppText(
                '${hour}h',
                textType: AppTextType.custom,
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),

          // Grid cells
          ...days.map((day) {
            final tasksForCell = _tasks.where((task) {
              return task.startTime.day == day.day &&
                  task.startTime.month == day.month &&
                  task.startTime.hour >= hour &&
                  task.startTime.hour < hour + 2;
            }).toList();

            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: const Color(0xFFE5E7EB), width: 0.5),
                    left: BorderSide(color: const Color(0xFFE5E7EB), width: 0.5),
                  ),
                ),
                child: tasksForCell.isEmpty
                    ? const SizedBox.shrink()
                    : _buildWeekTaskCell(tasksForCell.first),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeekTaskCell(ScheduleTask task) {
    return Container(
      margin: EdgeInsets.all(2.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: task.color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        task.title.split('\n').first,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ============ MONTH VIEW ============
  Widget _buildMonthView() {
    return Column(
      children: [
        SizedBox(height: 8.h),

        // Calendar
        _buildMonthCalendar(),

        // Divider
        Divider(color: const Color(0xFFE5E7EB), height: 1),

        // Tasks for selected day
        Expanded(
          child: _buildMonthTasksList(),
        ),
      ],
    );
  }

  Widget _buildMonthCalendar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDate,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDate = focusedDay;
          });
        },
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: const Color(0xFF6B7280),
            size: 24.sp,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: const Color(0xFF6B7280),
            size: 24.sp,
          ),
          titleTextStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
          weekendStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6366F1),
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF6366F1),
              width: 2,
            ),
          ),
          selectedTextStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6366F1),
          ),
          defaultTextStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF1F2937),
          ),
          weekendTextStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF1F2937),
          ),
          outsideTextStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final hasTasks = _tasks.any((task) =>
                task.startTime.day == date.day &&
                task.startTime.month == date.month &&
                task.startTime.year == date.year);

            if (hasTasks) {
              return Positioned(
                bottom: 4,
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildMonthTasksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: AppText(
            'Tasks on ${DateFormat('MMM d').format(_selectedDate)}',
            textType: AppTextType.custom,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _tasksForSelectedDay.length,
            itemBuilder: (context, index) {
              return _buildMonthTaskItem(_tasksForSelectedDay[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthTaskItem(ScheduleTask task) {
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => setState(() => task.isCompleted = !task.isCompleted),
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? const Color(0xFF6366F1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: task.isCompleted
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 14.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),

          SizedBox(width: 12.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${timeFormat.format(task.startTime)} - ${timeFormat.format(task.endTime)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: task.isCompleted
                        ? const Color(0xFFD1D5DB)
                        : const Color(0xFF6B7280),
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // Category tag
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: task.category == 'Work'
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFFCE7F3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              task.category ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: task.category == 'Work'
                    ? const Color(0xFFD97706)
                    : const Color(0xFFEC4899),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedDate = DateTime.now();
    });
  }
}

// Data model
class ScheduleTask {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final Color? dotColor;
  bool isCompleted;
  final String? category;

  ScheduleTask({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.dotColor,
    this.isCompleted = false,
    this.category,
  });
}
