import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// Components
import '../components/app_text.dart';
import '../repository/repository.dart';
import '../data/models/task_models.dart';
import 'home_page.dart';
import 'new_task.dart';

class ScheduleScreen extends StatefulWidget {
  final Function(int)? onTabChanged;

  /// Gọi sau khi edit hoặc mark done để Home (Today) reload.
  final void Function()? onTaskUpdated;

  const ScheduleScreen({super.key, this.onTabChanged, this.onTaskUpdated});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // View mode: 0 = Day, 1 = Month
  int _viewMode = 0;

  // Selected date
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  // Day view: tasks from API
  List<ScheduleTask> _dayTasks = [];
  bool _dayLoading = false;

  // Month view: tasks của ngày đang chọn (từ getTasksRange)
  List<ScheduleTask> _monthDayTasks = [];
  bool _monthDayLoading = false;

  List<ScheduleTask> get _tasksForSelectedDay {
    if (_viewMode == 0) return _dayTasks;
    return _monthDayTasks;
  }

  @override
  void initState() {
    super.initState();
    if (_viewMode == 0) _fetchTasksForDay(_selectedDate);
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  Map<String, int> _monthDateCounts = {};
  int _monthCountsVersion = 0;

  /// Gọi getTasksRange cho ngày đang chọn ở Month view (includeDone true, includeCancelled true).
  Future<void> _fetchTasksForSelectedDayInMonth(DateTime date) async {
    setState(() => _monthDayLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final res = await Api.instance.restClient.getTasksRange(
        dateStr,
        dateStr,
        true, // includeDone
        true, // includeCancelled
      );
      final list = _tasksFromRangeResponse(res, date);
      if (mounted)
        setState(() {
          _monthDayTasks = list;
          _monthDayLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _monthDayTasks = [];
          _monthDayLoading = false;
        });
      debugPrint('Schedule getTasksRange (month day) error: $e');
    }
  }

  Future<void> _fetchTasksCountForMonth(DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);
    final fromDate = DateFormat('yyyy-MM-dd').format(startOfMonth);
    final toDate = DateFormat('yyyy-MM-dd').format(endOfMonth);
    try {
      final res = await Api.instance.restClient.getTasksCount(
        fromDate,
        toDate,
        true,
        false,
      );
      final map = <String, int>{};
      for (final c in res.counts) {
        map[c.date] = c.count;
      }
      if (mounted)
        setState(() {
          _monthDateCounts = map;
          _monthCountsVersion++;
        });
    } catch (e) {
      debugPrint('Schedule getTasksCount error: $e');
      if (mounted)
        setState(() {
          _monthDateCounts = {};
          _monthCountsVersion++;
        });
    }
  }

  /// Toàn bộ task từ API cho ngày đang chọn — dùng cho view Manage (list + timeline).
  List<Task> _unscheduledTasksFromApi = [];

  /// Gọi API getTasksRange cho một ngày. Day view: includeCancelled false; Week: includeCancelled true.
  Future<void> _fetchTasksForDay(DateTime date, {bool includeCancelled = false}) async {
    setState(() => _dayLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final res = await Api.instance.restClient.getTasksRange(
        dateStr,
        dateStr,
        true, // includeDone
        includeCancelled,
      );
      final list = _tasksFromRangeResponse(res, date);
      if (mounted)
        setState(() {
          _dayTasks = list;
          _unscheduledTasksFromApi = res.tasks;
          _dayLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _dayTasks = [];
          _unscheduledTasksFromApi = [];
          _dayLoading = false;
        });
      debugPrint('Schedule getTasksRange error: $e');
    }
  }

  /// Map Task (API) -> ScheduleTask. Bỏ qua allDay. usePriorityColor: màu theo priority (Week view).
  List<ScheduleTask> _tasksFromRangeResponse(TasksRangeResponse res, DateTime forDate, {bool usePriorityColor = false}) {
    final list = <ScheduleTask>[];
    for (final t in res.tasks) {
      if (t.allDay) continue;
      DateTime? start;
      try {
        if (t.startAt.isNotEmpty) {
          final timeOnly = RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(t.startAt.trim());
          if (timeOnly) {
            final timeParts = t.startAt.trim().split(':');
            if (timeParts.length >= 2) {
              final dateStr = t.date.isNotEmpty ? t.date : DateFormat('yyyy-MM-dd').format(forDate);
              final dateParts = dateStr.split('-');
              if (dateParts.length == 3) {
                start = DateTime(
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
            String normalized = t.startAt.trim();
            if (normalized.contains(' ') && !normalized.contains('T')) {
              normalized = normalized.replaceFirst(' ', 'T');
            }
            start = DateTime.parse(normalized);
          }
        }
      } catch (_) {}
      if (start == null) continue;
      final end = start.add(Duration(minutes: t.durationMinutes));
      final isDone = t.status == 'DONE' || t.status == 'COMPLETED';
      list.add(ScheduleTask(
        id: t.id,
        title: t.title,
        startTime: start,
        endTime: end,
        color: usePriorityColor ? _colorFromPriority(t.priority) : const Color(0xFFF3F4F6),
        dotColor: const Color(0xFFF59E0B),
        isCompleted: isDone,
        category: null,
        task: t,
      ));
    }
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  bool _showUnscheduledList = false;

  int get _unscheduledTaskCount => _unscheduledTasksFromApi.length;

  String _formatPriorityLabel(String? priority) {
    if (priority == null || priority.isEmpty) return 'Medium priority';
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return 'High priority';
      case 'LOW':
        return 'Low priority';
      default:
        return 'Medium priority';
    }
  }

  /// Màu block theo priority (Week view): HIGH vàng, MEDIUM xanh dương, LOW xanh lá.
  Color _colorFromPriority(String? priority) {
    if (priority == null || priority.isEmpty) return const Color(0xFF93C5FD);
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFDE047);
      case 'LOW':
        return const Color(0xFF86EFAC);
      default:
        return const Color(0xFF93C5FD);
    }
  }

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
              child: _viewMode == 0 ? _buildDayView() : _buildMonthView(),
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
            fontWeight: FontWeight.w500,
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
            _buildViewModeTab('Month', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeTab(String label, int index) {
    final isSelected = _viewMode == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _viewMode = index;
          });
          if (index == 0) {
            _fetchTasksForDay(_selectedDate);
          } else if (index == 1) {
            _fetchTasksCountForMonth(_focusedDate);
            _fetchTasksForSelectedDayInMonth(_selectedDate);
          }
        },
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
            color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
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

        // Timeline hoặc Unscheduled tasks view
        Expanded(
          child: _showUnscheduledList
              ? _buildUnscheduledTasksView()
              : _dayLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ))
                  : _buildDayTimeline(),
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
          final isSelected = _selectedDate.day == date.day && _selectedDate.month == date.month;
          final isToday = date.day == today.day && date.month == today.month;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              if (_viewMode == 0) _fetchTasksForDay(date);
            },
            child: Container(
              width: 64.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    isToday ? 'TODAY' : DateFormat('E').format(date).toUpperCase(),
                    textType: AppTextType.custom,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF6B7280),
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    date.day.toString(),
                    textType: AppTextType.custom,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
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
    return GestureDetector(
      onTap: () => setState(() => _showUnscheduledList = !_showUnscheduledList),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              'You have $_unscheduledTaskCount unscheduled tasks',
              textType: AppTextType.s14w4,
              color: const Color(0xFF6B7280),
            ),
            AppText(
              'Manage',
              textType: AppTextType.s14w4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnscheduledTasksView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Row(
            children: [
              AppText(
                'Unscheduled tasks ($_unscheduledTaskCount)',
                textType: AppTextType.custom,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _unscheduledTasksFromApi.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final task = _unscheduledTasksFromApi[index];
              final durationStr = task.durationMinutes >= 60 ? '${task.durationMinutes ~/ 60}h' : '${task.durationMinutes}m';
              final priorityLabel = _formatPriorityLabel(task.priority);
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            task.title,
                            textType: AppTextType.s16w4,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                          SizedBox(height: 6.h),
                          AppText(
                            '$durationStr • $priorityLabel',
                            textType: AppTextType.s14w4,
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(color: Color(0xFF6366F1)),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: AppText(
                        'Quick set time',
                        textType: AppTextType.s14w4,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static const int _dayStartHour = 0;
  static const int _dayEndHour = 24;
  static const double _rowHeight = 80;
  
  // Zoom controller cho InteractiveViewer
  final TransformationController _zoomController = TransformationController();

  Widget _buildDayTimeline() {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day;
    final currentTimeTop = isToday && now.hour >= _dayStartHour && now.hour < _dayEndHour 
        ? (now.hour - _dayStartHour) * _rowHeight.h + (now.minute + now.second / 60) / 60 * _rowHeight.h 
        : null;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Stack(
      children: [
        // InteractiveViewer: pinch-to-zoom như xem ảnh
        InteractiveViewer(
          transformationController: _zoomController,
          minScale: 0.15,  // Thu nhỏ tối đa 15% - xem cả ngày trong 1 màn hình nhỏ
          maxScale: 3.0,   // Phóng to tối đa 300%
          boundaryMargin: EdgeInsets.symmetric(
            horizontal: screenWidth,  // Cho phép kéo trái/phải
            vertical: screenHeight,   // Cho phép kéo lên/xuống
          ),
          constrained: false,
          panEnabled: true,
          scaleEnabled: true,
          child: Container(
            width: screenWidth,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: List.generate(
                    _dayEndHour - _dayStartHour,
                    (index) {
                      final hour = _dayStartHour + index;
                      final tasksAtHour = _tasksForSelectedDay.where((task) {
                        return task.startTime.hour == hour;
                      }).toList();
                      return _buildTimelineRow(hour, tasksAtHour, now: now, isToday: isToday);
                    },
                  ),
                ),
                if (currentTimeTop != null)
                  Positioned(
                    top: currentTimeTop,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineRow(
    int hour,
    List<ScheduleTask> tasks, {
    required DateTime now,
    required bool isToday,
  }) {
    return SizedBox(
      height: _rowHeight.h,
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
                    children: tasks.map((task) => _buildDayTaskCard(task, isHighlighted: isToday && _isTaskWithin30MinOfNow(task, now), onInfoTap: null)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  /// Task trùng trong khoảng 30 phút so với thời gian hiện tại (overlap với [now-30m, now+30m]).
  bool _isTaskWithin30MinOfNow(ScheduleTask task, DateTime now) {
    final window = const Duration(minutes: 30);
    final start = now.subtract(window);
    final end = now.add(window);
    return task.startTime.isBefore(end) && task.endTime.isAfter(start);
  }

  Widget _buildDayTaskCard(ScheduleTask task, {bool isHighlighted = false, VoidCallback? onInfoTap}) {
    final timeFormat = DateFormat('HH:mm');
    final bgColor = isHighlighted ? const Color(0xFFE0E4FA) : Colors.white;
    final leftBorderColor = isHighlighted ? const Color(0xFF6366F1) : null;
    final timeColor = isHighlighted ? const Color(0xFFF59E0B) : const Color(0xFF6B7280);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: leftBorderColor != null
            ? Border(
                left: BorderSide(
                  color: leftBorderColor,
                  width: 3,
                ),
              )
            : null,
        boxShadow: isHighlighted
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
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
              if (isHighlighted) ...[
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
              ],
              AppText(
                '${timeFormat.format(task.startTime)}-${timeFormat.format(task.endTime)}',
                textType: AppTextType.s14w4,
                color: timeColor,
              ),
              if (onInfoTap != null) ...[
                const Spacer(),
                GestureDetector(
                  onTap: onInfoTap,
                  child: Icon(
                    Icons.info_outline,
                    size: 20.sp,
                    color: const Color(0xFF6B7280).withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ============ WEEK VIEW ============ (hiện không dùng trong UI, giữ lại cho tương lai)
  // ignore: unused_element
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
            onTap: () {
              setState(() => _focusedDate = _focusedDate.subtract(const Duration(days: 7)));
              _fetchTasksForWeek(_focusedDate);
            },
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
            onTap: () {
              setState(() => _focusedDate = _focusedDate.add(const Duration(days: 7)));
              _fetchTasksForWeek(_focusedDate);
            },
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

  static const double _weekDayWidth = 56.0;
  static const int _weekStartHour = 8;
  static const int _weekEndHour = 18;
  static const double _weekPixelsPerHour = 48.0;
  static const double _weekTimelineHeight = (_weekEndHour - _weekStartHour) * _weekPixelsPerHour;

  List<ScheduleTask> _weekTasks = [];
  bool _weekLoading = false;

  Future<void> _fetchTasksForWeek(DateTime date) async {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final fromDate = DateFormat('yyyy-MM-dd').format(startOfWeek);
    final toDate = DateFormat('yyyy-MM-dd').format(endOfWeek);
    setState(() => _weekLoading = true);
    try {
      final res = await Api.instance.restClient.getTasksRange(
        fromDate,
        toDate,
        true,
        true,
      );
      final list = _tasksFromRangeResponse(res, startOfWeek, usePriorityColor: true);
      if (mounted)
        setState(() {
          _weekTasks = list;
          _weekLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _weekTasks = [];
          _weekLoading = false;
        });
      debugPrint('Schedule getTasksRange (week) error: $e');
    }
  }

  Future<void> _onWeekDayTapped(DateTime day) async {
    setState(() => _selectedDate = day);
    await _fetchTasksForDay(day, includeCancelled: true);
    if (mounted) setState(() => _viewMode = 0);
  }

  List<ScheduleTask> _weekTasksForDay(DateTime day) {
    return _weekTasks.where((t) => t.startTime.year == day.year && t.startTime.month == day.month && t.startTime.day == day.day).toList();
  }

  Widget _buildWeekGrid() {
    final startOfWeek = _focusedDate.subtract(
      Duration(days: _focusedDate.weekday - 1),
    );
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final now = DateTime.now();

    return _weekLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day headers (Mon-Sun)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        SizedBox(width: 40.w),
                        ...days.map((day) {
                          final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
                          return GestureDetector(
                            onTap: () => _onWeekDayTapped(day),
                            child: SizedBox(
                              width: _weekDayWidth.w,
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
                                      color: isToday ? const Color(0xFF6366F1) : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: AppText(
                                      day.day.toString(),
                                      textType: AppTextType.s14w4,
                                      fontWeight: FontWeight.w600,
                                      color: isToday ? Colors.white : const Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Timeline: time labels + day columns with task blocks
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time labels
                      SizedBox(
                        width: 40.w,
                        height: _weekTimelineHeight.h,
                        child: Column(
                          children: List.generate(
                            _weekEndHour - _weekStartHour + 1,
                            (i) => SizedBox(
                              height: _weekPixelsPerHour.h,
                              child: Padding(
                                padding: EdgeInsets.only(left: 16.w, top: 2.h),
                                child: AppText(
                                  '${_weekStartHour + i}h',
                                  textType: AppTextType.custom,
                                  fontSize: 12,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Day columns with task blocks
                      ...days.map((day) => _buildWeekDayColumn(day)),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildWeekDayColumn(DateTime day) {
    final tasks = _weekTasksForDay(day);
    return GestureDetector(
      onTap: () => _onWeekDayTapped(day),
      child: SizedBox(
        width: _weekDayWidth.w,
        height: _weekTimelineHeight.h,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: const Color(0xFFE5E7EB), width: 0.5),
            ),
          ),
          child: Stack(
            children: [
              // Hour lines
              ...List.generate(
                _weekEndHour - _weekStartHour + 1,
                (i) => Positioned(
                  top: (i * _weekPixelsPerHour).h,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
              ),
              // Task blocks
              ...tasks.map((task) {
                final minutesFromStart = (task.startTime.hour - _weekStartHour) * 60 + task.startTime.minute;
                final durationMinutes = task.endTime.difference(task.startTime).inMinutes;
                final top = minutesFromStart * (_weekPixelsPerHour / 60);
                final height = durationMinutes * (_weekPixelsPerHour / 60);
                return Positioned(
                  top: top.h,
                  left: 2.w,
                  right: 2.w,
                  height: height.h,
                  child: _buildWeekTaskBlock(task),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekTaskBlock(ScheduleTask task) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: task.color,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        task.title,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        maxLines: 3,
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

  static const Color _monthDotColor = Color(0xFF6366F1);
  static const double _monthDotSize = 4.0;

  Widget _buildMonthDayCell(DateTime day, {bool selected = false, bool isToday = false}) {
    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    final count = _monthDateCounts[dateStr] ?? 0;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: isToday ? const Color(0xFF6366F1) : (selected ? const Color(0xFF6366F1) : const Color(0xFF1F2937)),
          ),
        ),
        if (count > 0) ...[
          SizedBox(height: 2.h),
          if (count >= 4)
            Container(
              width: 12.w,
              height: 2,
              decoration: BoxDecoration(
                color: _monthDotColor,
                borderRadius: BorderRadius.circular(1),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                count,
                (_) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Container(
                    width: _monthDotSize.w,
                    height: _monthDotSize.w,
                    decoration: const BoxDecoration(
                      color: _monthDotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ],
    );

    if (selected) {
      return Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _monthDotColor, width: 2),
        ),
        alignment: Alignment.center,
        child: content,
      );
    }
    if (isToday) {
      return Container(
        margin: EdgeInsets.all(2.w),
        decoration: const BoxDecoration(
          color: Color(0xFFDBEAFE),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: content,
      );
    }
    return Center(child: content);
  }

  Widget _buildMonthCalendar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TableCalendar(
        key: ValueKey('month_$_monthCountsVersion'),
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDate,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDate = focusedDay;
          });
          _fetchTasksForSelectedDayInMonth(selectedDay);
        },
        onPageChanged: (focusedDay) {
          setState(() => _focusedDate = focusedDay);
          _fetchTasksCountForMonth(focusedDay);
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
          defaultBuilder: (context, day, focusedDay) => _buildMonthDayCell(day, selected: false),
          selectedBuilder: (context, day, focusedDay) => _buildMonthDayCell(day, selected: true),
          todayBuilder: (context, day, focusedDay) => _buildMonthDayCell(day, selected: isSameDay(day, _selectedDate), isToday: true),
          markerBuilder: (context, date, events) => const SizedBox.shrink(),
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
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        Expanded(
          child: _monthDayLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                ))
              : ListView.builder(
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

  /// Bấm checkbox: gọi API updateTask với status DONE (đánh dấu xong) hoặc PENDING (bỏ xong).
  Future<void> _toggleMonthTask(ScheduleTask task) async {
    final bool wasCompleted = task.isCompleted;
    final String newStatus = wasCompleted ? 'PENDING' : 'DONE';

    setState(() => task.isCompleted = !task.isCompleted);

    try {
      await Api.instance.restClient.updateTask(task.id, {'status': newStatus});
    } catch (e) {
      if (mounted) setState(() => task.isCompleted = wasCompleted);
      debugPrint('Error updating task status: $e');
    }
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
            onTap: () => _toggleMonthTask(task),
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: task.isCompleted ? const Color(0xFF6366F1) : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: task.isCompleted ? const Color(0xFF6366F1) : const Color(0xFFD1D5DB),
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

          // Content (tap to open detail sheet với Edit / Mark as Done)
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (task.task != null) _showTaskDetailSheet(task.task!, readOnly: false);
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: task.isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${timeFormat.format(task.startTime)} - ${timeFormat.format(task.endTime)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: task.isCompleted ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info icon (mở sheet giống tap vào content)
          if (task.task != null)
            GestureDetector(
              onTap: () => _showTaskDetailSheet(task.task!, readOnly: false),
              child: Icon(
                Icons.info_outline,
                size: 20.sp,
                color: const Color(0xFF6B7280).withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  /// Bottom sheet chi tiết task. readOnly true = chỉ xem (Day view), false = có Edit / Mark as Done (Month view).
  void _showTaskDetailSheet(Task task, {bool readOnly = false}) {
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
            final dateText = _scheduleBuildDateLabel(task.date);
            final timeRange = _scheduleFormatTime(task.startAt, task.durationMinutes, date: task.date);
            final durationText = _scheduleBuildDurationLabel(task.durationMinutes);
            final repeatText = _scheduleBuildRepeatLabel(task);
            final reminderText = _scheduleBuildReminderLabel(task);

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
                            child: _scheduleBuildPriorityTag(task.priority!),
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
                            child: _scheduleBuildDetailRow(icon: Icons.calendar_today, text: dateText),
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
                            child: _scheduleBuildDetailRow(icon: Icons.access_time, text: timeRange),
                          ),
                      ],
                    ),
                    if (durationText != null) _scheduleBuildDetailRow(icon: Icons.timer_outlined, text: durationText),
                    if (repeatText != null) _scheduleBuildDetailRow(icon: Icons.repeat, text: repeatText),
                    if (reminderText != null) _scheduleBuildDetailRow(icon: Icons.notifications_none, text: reminderText),
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
                    if (!readOnly) ...[
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _editScheduleTask(task);
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
                                _toggleScheduleTaskDone(task);
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String? _scheduleBuildDateLabel(String date) {
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

  String? _scheduleFormatTime(String? startAt, int durationMinutes, {String? date}) {
    if (startAt == null || startAt.isEmpty) return null;
    try {
      DateTime start;
      if (startAt.length <= 8 && startAt.contains(':')) {
        if (date == null || date.isEmpty) return null;
        final timeParts = startAt.split(':');
        if (timeParts.length < 2) return null;
        final dateParts = date.split('-');
        if (dateParts.length != 3) return null;
        start = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
        );
      } else {
        String normalized = startAt.trim();
        if (normalized.contains(' ') && !normalized.contains('T')) {
          normalized = normalized.replaceFirst(' ', 'T');
        }
        start = DateTime.parse(normalized);
      }
      final end = start.add(Duration(minutes: durationMinutes));
      final timeFormat = DateFormat('h:mm a');
      return '${timeFormat.format(start)} - ${timeFormat.format(end)}';
    } catch (_) {
      return null;
    }
  }

  String? _scheduleBuildDurationLabel(int minutes) {
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

  String? _scheduleBuildRepeatLabel(Task task) {
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
    if (repeat.type == 'CUSTOM') return 'Custom repeat';
    return 'Repeats';
  }

  String? _scheduleBuildReminderLabel(Task task) {
    final minutes = task.reminderOffsetMinutes;
    if (minutes == null || minutes <= 0) return 'No reminder';
    if (minutes % 60 == 0) {
      final h = minutes ~/ 60;
      return '$h hour${h > 1 ? 's' : ''} before';
    }
    return '$minutes minutes before';
  }

  Widget _scheduleBuildDetailRow({required IconData icon, required String text}) {
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

  Widget _scheduleBuildPriorityTag(String priority) {
    String displayText;
    Color backgroundColor;
    Color textColor;
    switch (priority.toUpperCase()) {
      case 'HIGH':
        displayText = 'High';
        backgroundColor = const Color(0xFFFFE5E5);
        textColor = const Color(0xFFDC2626);
        break;
      case 'MEDIUM':
        displayText = 'Medium';
        backgroundColor = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFF59E0B);
        break;
      case 'LOW':
        displayText = 'Low';
        backgroundColor = const Color(0xFFE5F9E5);
        textColor = const Color(0xFF10B981);
        break;
      default:
        displayText = priority;
        backgroundColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _editScheduleTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTaskScreen(taskToEdit: task),
      ),
    ).then((_) {
      if (!mounted) return;
      if (_viewMode == 0) {
        _fetchTasksForDay(_selectedDate);
      } else {
        _fetchTasksForSelectedDayInMonth(_selectedDate);
        _fetchTasksCountForMonth(_focusedDate);
      }
      widget.onTaskUpdated?.call();
    });
  }

  Future<void> _toggleScheduleTaskDone(Task task) async {
    final newStatus = task.status == 'DONE' || task.status == 'COMPLETED' ? 'PENDING' : 'DONE';
    try {
      await Api.instance.restClient.updateTask(task.id, {'status': newStatus});
      if (!mounted) return;
      if (_viewMode == 0) {
        _fetchTasksForDay(_selectedDate);
      } else {
        _fetchTasksForSelectedDayInMonth(_selectedDate);
        _fetchTasksCountForMonth(_focusedDate);
      }
      widget.onTaskUpdated?.call();
    } catch (e) {
      debugPrint('Error updating task status: $e');
    }
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedDate = DateTime.now();
    });
    if (_viewMode == 0) _fetchTasksForDay(_selectedDate);
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

  /// Full task from API for detail bottom sheet (edit, mark done).
  final Task? task;

  ScheduleTask({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.dotColor,
    this.isCompleted = false,
    this.category,
    this.task,
  });
}
