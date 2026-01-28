import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// Components
import '../components/app_text.dart';
import '../repository/repository.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customDurationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  String _repeatOption = 'Does not repeat';
  String _selectedDuration = '30m';
  int _customDurationMinutes = 30; // Default custom duration in minutes
  bool _reminderEnabled = true;

  // Priority & reminder
  String _selectedPriority = 'MEDIUM'; // HIGH, MEDIUM, LOW
  String _selectedReminderOption = '15m'; // 15m, 30m, 1h, 1.5h, 2h, Custom, Off
  int? _customReminderMinutes;

  // Custom repeat settings
  String _customFrequency = 'Daily'; // Daily or Weekly
  int _customInterval = 1;
  String _customIntervalUnit = 'day(s)'; // day(s) or week(s)
  List<bool> _selectedDays = [false, false, false, false, false, false, false]; // Mon-Sun
  String _customRange = 'Forever'; // Forever, Until date, For
  DateTime? _customUntilDate;
  int _customForTimes = 7;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          'New Task',
          textType: AppTextType.s17w7,
          color: const Color(0xFF1F2937),
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined, color: Color(0xFF1F2937)),
            onPressed: () {
              // Handle delete
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Title Input
              _buildSectionTitle('Title'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: _titleController,
                hintText: 'Task name (e.g., Meeting with Team A)',
              ),
              SizedBox(height: 24.h),

              // Description Input
              _buildSectionTitle('Description / Note (optional)'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Add more details here...',
                maxLines: 4,
              ),
              SizedBox(height: 24.h),

              // Date, Time, Repeat Options
              _buildOptionRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: _formatDate(_selectedDate),
                onTap: _selectDate,
              ),
              SizedBox(height: 12.h),
              _buildOptionRow(
                icon: Icons.access_time,
                label: 'Time',
                value: _selectedTime != null ? _formatTime(_selectedTime!) : 'No time',
                onTap: _selectTime,
              ),
              SizedBox(height: 12.h),
              _buildOptionRow(
                icon: Icons.repeat,
                label: 'Repeat',
                value: _getRepeatDisplayText(),
                onTap: _selectRepeat,
              ),
              SizedBox(height: 12.h),

              // Priority
              _buildOptionRow(
                icon: Icons.flag_outlined,
                label: 'Priority',
                value: _getPriorityDisplayText(),
                onTap: _selectPriority,
              ),
              SizedBox(height: 12.h),

              // Reminder
              _buildOptionRow(
                icon: Icons.notifications_none_outlined,
                label: 'Reminder',
                value: _getReminderDisplayText(),
                onTap: _selectReminder,
              ),
              SizedBox(height: 24.h),

              // AI Scheduling Suggestion
              // _buildAISuggestionButton(),
              // SizedBox(height: 24.h),

              // Duration Section
              _buildSectionTitle('Duration'),
              SizedBox(height: 12.h),
              _buildDurationButtons(),
              // Show custom duration input if Custom is selected
              if (_selectedDuration == 'Custom') ...[
                SizedBox(height: 12.h),
                _buildCustomDurationInput(),
              ],
              SizedBox(height: 24.h),

              // Save Button
              _buildSaveButton(),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      textType: AppTextType.s16w7,
      color: const Color(0xFF1F2937),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        autofocus: false,
        style: TextStyle(
          fontSize: 16.sp,
          color: const Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 233, 252).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18.sp, color: Colors.black),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AppText(
                label,
                textType: AppTextType.s16w4,
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w400,
              ),
            ),
            AppText(
              value,
              textType: AppTextType.s16w4,
              color: const Color(0xFF1E40AF),
              fontWeight: FontWeight.w500,
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationButtons() {
    final durations = ['30m', '1h', '2h', 'Custom'];

    return Row(
      children: durations.map((duration) {
        final isSelected = _selectedDuration == duration;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: duration != 'Custom' ? 8.w : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDuration = duration;
                  if (duration == 'Custom') {
                    // Initialize custom duration controller with current value
                    _customDurationController.text = _customDurationMinutes.toString();
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE0E7FF) : Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Center(
                  child: AppText(
                    duration,
                    textType: AppTextType.s16w4,
                    color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1F2937),
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomDurationInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _customDurationController,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 16.sp,
          color: const Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Enter minutes (e.g., 45)',
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
          suffixText: 'minutes',
          suffixStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF6B7280),
          ),
        ),
        onChanged: (value) {
          final intValue = int.tryParse(value);
          if (intValue != null && intValue > 0) {
            setState(() {
              _customDurationMinutes = intValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _createTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E40AF),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 0,
        ),
        child: AppText(
          'Save',
          textType: AppTextType.s16w7,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today, ${DateFormat('MMM d').format(date)}';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _getRepeatDisplayText() {
    if (_repeatOption == 'Does not repeat') {
      return 'None';
    } else if (_repeatOption == 'Custom') {
      if (_customFrequency == 'Daily') {
        return 'Every $_customInterval ${_customIntervalUnit}';
      } else {
        final selectedDaysCount = _selectedDays.where((d) => d).length;
        if (selectedDaysCount == 0) {
          return 'Custom';
        } else if (selectedDaysCount == 1) {
          final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final dayIndex = _selectedDays.indexWhere((d) => d);
          return 'Every week on ${dayNames[dayIndex]}';
        } else {
          return 'Custom';
        }
      }
    }
    return _repeatOption;
  }

  String _getRepeatInfoText() {
    if (_repeatOption == 'Does not repeat') {
      return '';
    } else if (_repeatOption == 'Every day') {
      return 'Repeats every day, starting ${DateFormat('EEE, MMM d').format(_selectedDate)}.';
    } else if (_repeatOption == 'Weekdays (Mon-Fri)') {
      return 'Repeats every weekday, starting ${DateFormat('EEE, MMM d').format(_selectedDate)}.';
    } else if (_repeatOption == 'Every week on Tuesday') {
      return 'Repeats every week on Tuesday, starting ${DateFormat('EEE, MMM d').format(_selectedDate)}.';
    } else if (_repeatOption == 'Custom') {
      if (_customFrequency == 'Daily') {
        return 'Repeats every $_customInterval ${_customIntervalUnit}, starting ${DateFormat('EEE, MMM d').format(_selectedDate)}.';
      } else {
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final selectedDayNames = <String>[];
        for (int i = 0; i < _selectedDays.length; i++) {
          if (_selectedDays[i]) {
            selectedDayNames.add(dayNames[i]);
          }
        }
        if (selectedDayNames.isEmpty) {
          return 'Repeats every $_customInterval week(s), starting ${DateFormat('EEE, MMM d').format(_selectedDate)}.';
        } else {
          return 'Repeats every $_customInterval week(s) on ${selectedDayNames.join(', ')}, starting ${DateFormat('EEE, MMM d').format(_selectedDate)}.';
        }
      }
    }
    return '';
  }

  String _getPriorityDisplayText() {
    switch (_selectedPriority) {
      case 'HIGH':
        return 'High';
      case 'LOW':
        return 'Low';
      case 'MEDIUM':
      default:
        return 'Medium';
    }
  }

  String _getReminderDisplayText() {
    if (!_reminderEnabled || _selectedReminderOption == 'Off') {
      return 'Off';
    }

    switch (_selectedReminderOption) {
      case '15m':
        return '15 minutes before';
      case '30m':
        return '30 minutes before';
      case '1h':
        return '1 hour before';
      case '1.5h':
        return '1.5 hours before';
      case '2h':
        return '2 hours before';
      case 'Custom':
        final minutes = _customReminderMinutes ?? 15;
        return '$minutes minutes before';
      default:
        return '15 minutes before';
    }
  }

  Future<void> _selectRepeat() async {
    final taskTitle = _titleController.text.isEmpty ? 'New Task' : _titleController.text;
    final taskDuration = _selectedDuration;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Title centered
                    Column(
                      children: [
                        AppText(
                          'Repeat',
                          textType: AppTextType.s20w7,
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                        AppText(
                          'Set how this task repeats over time.',
                          textType: AppTextType.s14w4,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    // Close button aligned to right
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Task summary
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          '$taskTitle · $taskDuration',
                          textType: AppTextType.s14w4,
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Quick presets section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    'Quick presets',
                    textType: AppTextType.s16w7,
                    color: const Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // Preset options
              _buildRepeatOption(
                'Does not repeat',
                isSelected: _repeatOption == 'Does not repeat',
                onTap: () {
                  setState(() {
                    _repeatOption = 'Does not repeat';
                  });
                  Navigator.pop(context);
                },
              ),
              _buildRepeatOption(
                'Every day',
                isSelected: _repeatOption == 'Every day',
                onTap: () {
                  setState(() {
                    _repeatOption = 'Every day';
                  });
                  Navigator.pop(context);
                },
              ),
              _buildRepeatOption(
                'Weekdays (Mon-Fri)',
                isSelected: _repeatOption == 'Weekdays (Mon-Fri)',
                onTap: () {
                  setState(() {
                    _repeatOption = 'Weekdays (Mon-Fri)';
                  });
                  Navigator.pop(context);
                },
              ),
              _buildRepeatOption(
                'Every week on Tuesday',
                isSelected: _repeatOption == 'Every week on Tuesday',
                onTap: () {
                  setState(() {
                    _repeatOption = 'Every week on Tuesday';
                  });
                  Navigator.pop(context);
                },
              ),
              _buildRepeatOption(
                'Custom...',
                isSelected: _repeatOption == 'Custom',
                onTap: () {
                  Navigator.pop(context);
                  _showCustomRepeatSheet();
                },
              ),

              SizedBox(height: 16.h),

              // Info text
              if (_getRepeatInfoText().isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: AppText(
                    _getRepeatInfoText(),
                    textType: AppTextType.s14w4,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),

              SizedBox(height: 16.h),

              // Footer buttons
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _repeatOption = 'Does not repeat';
                          });
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: AppText(
                          'Clear repeat',
                          textType: AppTextType.s16w4,
                          color: const Color(0xFF3B82F6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          elevation: 0,
                        ),
                        child: AppText(
                          'Save',
                          textType: AppTextType.s16w7,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectPriority() async {
    const options = ['HIGH', 'MEDIUM', 'LOW'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      'Priority',
                      textType: AppTextType.s20w7,
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.w600,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              ...options.map((opt) {
                final isSelected = _selectedPriority == opt;
                return ListTile(
                  onTap: () {
                    setState(() {
                      _selectedPriority = opt;
                    });
                    Navigator.pop(context);
                  },
                  leading: Icon(
                    Icons.flag,
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                  ),
                  title: AppText(
                    opt[0] + opt.substring(1).toLowerCase(),
                    textType: AppTextType.s16w4,
                    color: const Color(0xFF1F2937),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: const Color(0xFF2563EB), size: 20.sp)
                      : null,
                );
              }).toList(),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectReminder() async {
    const options = ['Off', '15m', '30m', '1h', '1.5h', '2h', 'Custom'];

    String tempSelected = _selectedReminderOption;
    int? tempCustomMinutes = _customReminderMinutes ?? 15;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final mediaQuery = MediaQuery.of(context);
            final bottomInset = mediaQuery.viewInsets.bottom;

            return SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.only(bottom: bottomInset),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: mediaQuery.size.height * 0.9,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 12.h),
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                'Reminder',
                                textType: AppTextType.s20w7,
                                color: const Color(0xFF1F2937),
                                fontWeight: FontWeight.w600,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        ...options.map((opt) {
                          final isSelected = tempSelected == opt;
                          return ListTile(
                            onTap: () {
                              setModalState(() {
                                tempSelected = opt;
                              });
                            },
                            title: AppText(
                              opt == 'Off'
                                  ? 'Off'
                                  : opt == '15m'
                                      ? '15 minutes before'
                                      : opt == '30m'
                                          ? '30 minutes before'
                                          : opt == '1h'
                                              ? '1 hour before'
                                              : opt == '1.5h'
                                                  ? '1.5 hours before'
                                                  : opt == '2h'
                                                      ? '2 hours before'
                                                      : 'Custom',
                              textType: AppTextType.s16w4,
                              color: const Color(0xFF1F2937),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check, color: const Color(0xFF2563EB), size: 20.sp)
                                : null,
                          );
                        }).toList(),
                        if (tempSelected == 'Custom') ...[
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16.w),
                                  hintText: 'Enter minutes before (e.g., 45)',
                                  suffixText: 'minutes',
                                ),
                                controller: TextEditingController(
                                  text: (tempCustomMinutes ?? 15).toString(),
                                ),
                                onChanged: (value) {
                                  final intValue = int.tryParse(value);
                                  if (intValue != null && intValue > 0) {
                                    setModalState(() {
                                      tempCustomMinutes = intValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: AppText(
                                    'Cancel',
                                    textType: AppTextType.s16w4,
                                    color: const Color(0xFF1F2937),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedReminderOption = tempSelected;
                                      _customReminderMinutes = tempCustomMinutes;
                                      _reminderEnabled = tempSelected != 'Off';
                                    });
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    padding: EdgeInsets.symmetric(vertical: 14.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: AppText(
                                    'Apply',
                                    textType: AppTextType.s16w7,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRepeatOption(String text, {required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AppText(
                text,
                textType: AppTextType.s16w4,
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomRepeatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      margin: EdgeInsets.only(top: 12.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  'Custom repeat',
                                  textType: AppTextType.s20w7,
                                  color: const Color(0xFF1F2937),
                                  fontWeight: FontWeight.w600,
                                ),
                                SizedBox(height: 4.h),
                                AppText(
                                  'Fine-tune how often this task repeats.',
                                  textType: AppTextType.s14w4,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Frequency Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Frequency',
                            textType: AppTextType.s16w7,
                            color: const Color(0xFF1F2937),
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        _customFrequency = 'Daily';
                                        _customIntervalUnit = 'day(s)';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: _customFrequency == 'Daily' ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(24.r),
                                        border: Border.all(
                                          color: _customFrequency == 'Daily' ? const Color(0xFFE5E7EB) : Colors.transparent,
                                        ),
                                      ),
                                      child: Center(
                                        child: AppText(
                                          'Daily',
                                          textType: AppTextType.s16w4,
                                          color: const Color(0xFF1F2937),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        _customFrequency = 'Weekly';
                                        _customIntervalUnit = 'week(s)';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: _customFrequency == 'Weekly' ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(24.r),
                                        border: Border.all(
                                          color: _customFrequency == 'Weekly' ? const Color(0xFFE5E7EB) : Colors.transparent,
                                        ),
                                      ),
                                      child: Center(
                                        child: AppText(
                                          'Weekly',
                                          textType: AppTextType.s16w4,
                                          color: const Color(0xFF1F2937),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Interval Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Interval',
                            textType: AppTextType.s16w7,
                            color: const Color(0xFF1F2937),
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              AppText(
                                'Every',
                                textType: AppTextType.s16w4,
                                color: const Color(0xFF1F2937),
                                fontWeight: FontWeight.w400,
                              ),
                              SizedBox(width: 12.w),
                              Container(
                                width: 80.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: TextField(
                                  autofocus: false,
                                  controller: TextEditingController(text: _customInterval.toString()),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: const Color(0xFF1F2937),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                                  ),
                                  onChanged: (value) {
                                    final intValue = int.tryParse(value);
                                    if (intValue != null && intValue > 0) {
                                      setModalState(() {
                                        _customInterval = intValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText(
                                        _customIntervalUnit,
                                        textType: AppTextType.s16w4,
                                        color: const Color(0xFF1F2937),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Repeat on Section (only for Weekly)
                    if (_customFrequency == 'Weekly') ...[
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Repeat on',
                              textType: AppTextType.s16w7,
                              color: const Color(0xFF1F2937),
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: List.generate(7, (index) {
                                final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                final isSelected = _selectedDays[index];
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: index < 6 ? 8.w : 0,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          _selectedDays[index] = !_selectedDays[index];
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                                          borderRadius: BorderRadius.circular(24.r),
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        child: Center(
                                          child: AppText(
                                            dayNames[index],
                                            textType: AppTextType.s14w4,
                                            color: isSelected ? Colors.white : const Color(0xFF1F2937),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),

                    // Range Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Range',
                            textType: AppTextType.s16w7,
                            color: const Color(0xFF1F2937),
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 12.h),
                          _buildRangeOption(
                            'Forever',
                            isSelected: _customRange == 'Forever',
                            onTap: () {
                              setModalState(() {
                                _customRange = 'Forever';
                              });
                            },
                          ),
                          SizedBox(height: 8.h),
                          _buildRangeOption(
                            'Until date',
                            isSelected: _customRange == 'Until date',
                            onTap: () {
                              setModalState(() {
                                _customRange = 'Until date';
                              });
                            },
                            trailing: Row(
                              children: [
                                AppText(
                                  _customUntilDate != null ? DateFormat('MMM d, yyyy').format(_customUntilDate!) : 'Dec 31, 2024',
                                  textType: AppTextType.s14w4,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: _customUntilDate ?? DateTime.now().add(const Duration(days: 30)),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                                    );
                                    if (picked != null) {
                                      setModalState(() {
                                        _customUntilDate = picked;
                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.calendar_today,
                                    size: 18.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _buildRangeOption(
                            'For',
                            isSelected: _customRange == 'For',
                            onTap: () {
                              setModalState(() {
                                _customRange = 'For';
                              });
                            },
                            trailing: Row(
                              children: [
                                Container(
                                  width: 60.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: TextField(
                                    autofocus: false,
                                    controller: TextEditingController(text: _customForTimes.toString()),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF1F2937),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                                    ),
                                    onChanged: (value) {
                                      final intValue = int.tryParse(value);
                                      if (intValue != null && intValue > 0) {
                                        setModalState(() {
                                          _customForTimes = intValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                AppText(
                                  'times',
                                  textType: AppTextType.s14w4,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Footer buttons
                    Container(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF3F4F6),
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                elevation: 0,
                              ),
                              child: AppText(
                                'Cancel',
                                textType: AppTextType.s16w4,
                                color: const Color(0xFF1F2937),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _repeatOption = 'Custom';
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                elevation: 0,
                              ),
                              child: AppText(
                                'Apply',
                                textType: AppTextType.s16w7,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildRangeOption(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AppText(
                label,
                textType: AppTextType.s16w4,
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w400,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // Parse duration string to minutes
  int _parseDurationToMinutes(String duration) {
    if (duration == '30m') return 30;
    if (duration == '1h') return 60;
    if (duration == '2h') return 120;
    if (duration == 'Custom') return _customDurationMinutes;
    return 30; // Default
  }

  int? _getReminderOffsetMinutes() {
    if (!_reminderEnabled || _selectedReminderOption == 'Off') return null;

    switch (_selectedReminderOption) {
      case '15m':
        return 15;
      case '30m':
        return 30;
      case '1h':
        return 60;
      case '1.5h':
        return 90;
      case '2h':
        return 120;
      case 'Custom':
        return _customReminderMinutes ?? 15;
      default:
        return 15;
    }
  }

  // Build request body from current state
  Map<String, dynamic> _buildRequestBody() {
    // Format date as yyyy-MM-dd
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Build startAt: combine date + time, format as ISO 8601 with timezone +07:00
    DateTime startDateTime;
    if (_selectedTime != null) {
      startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    } else {
      // If no time selected, use start of day
      startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
    }
    final startAtStr = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startDateTime);

    // Build repeat object
    Map<String, dynamic> repeatObj = {};
    
    if (_repeatOption == 'Does not repeat') {
      repeatObj['type'] = 'NONE';
    } else if (_repeatOption == 'Custom') {
      repeatObj['type'] = 'CUSTOM';
      
      // Build custom repeat object
      Map<String, dynamic> customObj = {};
      customObj['frequency'] = _customFrequency.toUpperCase(); // DAILY or WEEKLY
      customObj['interval'] = _customInterval;
      
      // Build range object
      Map<String, dynamic> rangeObj = {};
      if (_customRange == 'Forever') {
        rangeObj['mode'] = 'FOREVER';
      } else if (_customRange == 'Until date') {
        rangeObj['mode'] = 'UNTIL_DATE';
        rangeObj['untilDate'] = _customUntilDate != null
            ? DateFormat('yyyy-MM-dd').format(_customUntilDate!)
            : null;
      } else if (_customRange == 'For') {
        rangeObj['mode'] = 'COUNT';
        rangeObj['count'] = _customForTimes;
      }
      customObj['range'] = rangeObj;
      
      // Add weekdays if frequency is WEEKLY
      if (_customFrequency == 'Weekly') {
        final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
        final selectedWeekdays = <String>[];
        for (int i = 0; i < _selectedDays.length; i++) {
          if (_selectedDays[i]) {
            selectedWeekdays.add(dayNames[i]);
          }
        }
        customObj['weekdays'] = selectedWeekdays.isNotEmpty ? selectedWeekdays : null;
      } else {
        
      }
      
      repeatObj['custom'] = customObj;
    } else {
      // Preset options
      repeatObj['type'] = 'PRESET';
  
      
      if (_repeatOption == 'Every day') {
        repeatObj['preset'] = 'EVERY_DAY';
      } else if (_repeatOption == 'Weekdays (Mon-Fri)') {
        repeatObj['preset'] = 'WEEKDAYS';
      } else if (_repeatOption == 'Every week on Tuesday') {
        repeatObj['preset'] = 'EVERY_WEEK_ON_X';
        // Note: You might need to add a field for which day of week
      } else {
        repeatObj['preset'] = 'EVERY_DAY'; // Default
      }
    }

    // Build main body
    final body = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'date': dateStr,
      'startAt': startAtStr,
      'durationMinutes': _parseDurationToMinutes(_selectedDuration),
      'repeat': repeatObj,
      'status': 'PENDING',
      'source': 'MANUAL',
      'priority': _selectedPriority,
    };

    final reminderOffset = _getReminderOffsetMinutes();
    if (reminderOffset != null) {
      body['reminderOffsetMinutes'] = reminderOffset;
    }

    return body;
  }

  // Create task API call
  Future<void> _createTask() async {
    // Validate title
    if (_titleController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter a task title');
      return;
    }

    try {
      EasyLoading.show(status: 'Creating task...');

      final body = _buildRequestBody();
      
      print('Request body: $body'); // Debug print

      await Api.instance.restClient.createTask(body);

      EasyLoading.dismiss();
      
      if (mounted) {
        EasyLoading.showSuccess('Task created successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) {
        EasyLoading.showError('Failed to create task: ${e.toString()}');
      }
    }
  }
}
