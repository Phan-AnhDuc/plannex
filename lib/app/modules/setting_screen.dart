import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Components
import '../components/app_text.dart';
import 'home_page.dart';

class SettingScreen extends StatefulWidget {
  final Function(int)? onTabChanged;

  const SettingScreen({super.key, this.onTabChanged});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // Settings state
  bool _enableReminders = true;
  String _theme = 'Light / Dark';
  String _defaultTaskDuration = '30 minutes';
  String _reminderOffset = '15 minutes before';
  String _startWorkingDay = '09:00 AM';
  String _endWorkingDay = '05:00 PM';
  final String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Divider
            Container(
              height: 1,
              color: const Color(0xFFE5E7EB),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // General Section
                    _buildSection(
                      title: 'General',
                      children: [
                        _buildSettingItem(
                          title: 'Theme',
                          value: _theme,
                          onTap: _onThemeTap,
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          title: 'Default Task Duration',
                          value: _defaultTaskDuration,
                          onTap: _onDefaultTaskDurationTap,
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Notifications Section
                    _buildSection(
                      title: 'Notifications',
                      children: [
                        _buildSwitchItem(
                          title: 'Enable Reminders',
                          value: _enableReminders,
                          onChanged: (value) {
                            setState(() => _enableReminders = value);
                          },
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          title: 'Reminder Offset',
                          value: _reminderOffset,
                          onTap: _onReminderOffsetTap,
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Working Hours Section
                    _buildSection(
                      title: 'Working Hours',
                      children: [
                        _buildSettingItem(
                          title: 'Start of Working Day',
                          value: _startWorkingDay,
                          onTap: _onStartWorkingDayTap,
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          title: 'End of Working Day',
                          value: _endWorkingDay,
                          onTap: _onEndWorkingDayTap,
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Account Section
                    _buildSection(
                      title: 'Account',
                      children: [
                        _buildSettingItem(
                          title: 'Manage Account',
                          onTap: _onManageAccountTap,
                        ),
                        _buildDivider(),
                        _buildActionItem(
                          title: 'Log Out',
                          color: const Color(0xFFEF4444),
                          onTap: _onLogOutTap,
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // About Section
                    _buildSection(
                      title: 'About',
                      children: [
                        _buildSettingItem(
                          title: 'Privacy Policy',
                          onTap: _onPrivacyPolicyTap,
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          title: 'Terms of Service',
                          onTap: _onTermsOfServiceTap,
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          title: 'App Version',
                          value: _appVersion,
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.onTabChanged != null
          ? AppBottomNavBar(
              currentIndex: 3,
              onTabChanged: widget.onTabChanged!,
            )
          : null,
    );
  }

  /// Header
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: AppText(
          'Settings',
          textType: AppTextType.custom,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
      ),
    );
  }

  /// Section with title and content
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        AppText(
          title,
          textType: AppTextType.s16w4,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),

        SizedBox(height: 12.h),

        // Section content card
        Container(
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
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// Divider inside card
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      color: const Color(0xFFF3F4F6),
    );
  }

  /// Setting item with value and arrow
  Widget _buildSettingItem({
    required String title,
    String? value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                title,
                textType: AppTextType.s16w4,
                color: const Color(0xFF1F2937),
              ),
            ),
            if (value != null) ...[
              AppText(
                value,
                textType: AppTextType.s16w4,
                color: const Color(0xFF6B7280),
              ),
              SizedBox(width: 8.w),
            ],
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

  /// Switch item
  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              title,
              textType: AppTextType.s16w4,
              color: const Color(0xFF1F2937),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF6366F1),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DB),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  /// Action item (like Log Out)
  Widget _buildActionItem({
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            AppText(
              title,
              textType: AppTextType.s16w4,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  /// Info item (no arrow, just label and value)
  Widget _buildInfoItem({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              title,
              textType: AppTextType.s16w4,
              color: const Color(0xFF1F2937),
            ),
          ),
          AppText(
            value,
            textType: AppTextType.s16w4,
            color: const Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }

  // ============ Actions ============

  void _onThemeTap() {
    _showOptionPicker(
      title: 'Theme',
      options: ['Light', 'Dark', 'System'],
      currentValue: _theme,
      onSelected: (value) {
        setState(() => _theme = value);
      },
    );
  }

  void _onDefaultTaskDurationTap() {
    _showOptionPicker(
      title: 'Default Task Duration',
      options: ['15 minutes', '30 minutes', '45 minutes', '1 hour', '2 hours'],
      currentValue: _defaultTaskDuration,
      onSelected: (value) {
        setState(() => _defaultTaskDuration = value);
      },
    );
  }

  void _onReminderOffsetTap() {
    _showOptionPicker(
      title: 'Reminder Offset',
      options: [
        '5 minutes before',
        '10 minutes before',
        '15 minutes before',
        '30 minutes before',
        '1 hour before',
      ],
      currentValue: _reminderOffset,
      onSelected: (value) {
        setState(() => _reminderOffset = value);
      },
    );
  }

  void _onStartWorkingDayTap() {
    _showTimePicker(
      title: 'Start of Working Day',
      currentValue: _startWorkingDay,
      onSelected: (value) {
        setState(() => _startWorkingDay = value);
      },
    );
  }

  void _onEndWorkingDayTap() {
    _showTimePicker(
      title: 'End of Working Day',
      currentValue: _endWorkingDay,
      onSelected: (value) {
        setState(() => _endWorkingDay = value);
      },
    );
  }

  void _onManageAccountTap() {
    debugPrint('Manage Account');
  }

  void _onLogOutTap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              debugPrint('Logged out');
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _onPrivacyPolicyTap() {
    debugPrint('Privacy Policy');
  }

  void _onTermsOfServiceTap() {
    debugPrint('Terms of Service');
  }

  // ============ Helpers ============

  void _showOptionPicker({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: AppText(
                  title,
                  textType: AppTextType.custom,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Divider(height: 1, color: const Color(0xFFE5E7EB)),
              ...options.map((option) {
                final isSelected = option == currentValue ||
                    currentValue.contains(option);
                return InkWell(
                  onTap: () {
                    onSelected(option);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText(
                            option,
                            textType: AppTextType.s16w4,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            size: 20.sp,
                            color: const Color(0xFF6366F1),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  void _showTimePicker({
    required String title,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) async {
    // Parse current time
    final parts = currentValue.split(':');
    final hourPart = parts[0];
    final minuteAndPeriod = parts[1].split(' ');
    final minute = int.parse(minuteAndPeriod[0]);
    final isPM = minuteAndPeriod[1] == 'PM';
    var hour = int.parse(hourPart);
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final period = picked.hour >= 12 ? 'PM' : 'AM';
      final displayHour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final formattedTime =
          '${displayHour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
      onSelected(formattedTime);
    }
  }
}
