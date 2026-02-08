import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Components
import '../components/app_text.dart';
import '../data/app_shared_pref.dart';
import '../data/models/user_models.dart';
import '../repository/repository.dart';
import 'home_page.dart';
import 'login_screen.dart';

class SettingScreen extends StatefulWidget {
  final Function(int)? onTabChanged;

  const SettingScreen({super.key, this.onTabChanged});

  @override
  State<SettingScreen> createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  // Settings state (fill từ API users/me)
  bool _enableReminders = true;
  late String _theme;
  String _defaultTaskDuration = '30 minutes';
  String _reminderOffset = '15 minutes before';
  String _startWorkingDay = '09:00';
  String _endWorkingDay = '17:00';
  String _timezone = 'Asia/Ho_Chi_Minh';
  String _appVersion = '—'; // Lấy từ package (pubspec version) khi vào màn
  bool _settingsLoading = false;

  static String _themeDisplayFromMode(String mode) {
    switch (mode) {
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System';
      default:
        return 'Light';
    }
  }

  @override
  void initState() {
    super.initState();
    _theme = _themeDisplayFromMode(AppSharedPref.getThemeMode());
    _fetchUsersMe();
    _loadAppVersion();
  }

  /// Lấy version từ pubspec (version+buildNumber, ví dụ 1.0.1+1).
  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();

      if (mounted) {
        setState(() => _appVersion = '${info.version}+${info.buildNumber}');
      }
    } catch (_) {
      if (mounted) setState(() => _appVersion = '—');
    }
  }

  /// Chuyển defaultDurationMinutes (API) -> text hiển thị.
  static String _durationMinutesToDisplay(int minutes) {
    switch (minutes) {
      case 15:
        return '15 minutes';
      case 45:
        return '45 minutes';
      case 60:
        return '1 hour';
      case 120:
        return '2 hours';
      default:
        return '30 minutes';
    }
  }

  /// Chuyển text hiển thị -> defaultDurationMinutes (API).
  static int _displayToDurationMinutes(String display) {
    switch (display) {
      case '15 minutes':
        return 15;
      case '45 minutes':
        return 45;
      case '1 hour':
        return 60;
      case '2 hours':
        return 120;
      default:
        return 30;
    }
  }

  /// Chuyển defaultReminderOffsetMinutes (API) -> text hiển thị.
  static String _reminderMinutesToDisplay(int minutes) {
    switch (minutes) {
      case 5:
        return '5 minutes before';
      case 10:
        return '10 minutes before';
      case 30:
        return '30 minutes before';
      case 60:
        return '1 hour before';
      default:
        return '15 minutes before';
    }
  }

  /// Chuyển text hiển thị -> defaultReminderOffsetMinutes (API).
  static int _displayToReminderMinutes(String display) {
    switch (display) {
      case '5 minutes before':
        return 5;
      case '10 minutes before':
        return 10;
      case '30 minutes before':
        return 30;
      case '1 hour before':
        return 60;
      default:
        return 15;
    }
  }

  /// Gọi API users/me, parse response và fill vào các option.
  Future<void> _fetchUsersMe() async {
    if (_settingsLoading) return;
    setState(() => _settingsLoading = true);
    try {
      final res = await Api.instance.restClient.getUsersMe();
      if (!mounted) return;
      if (res is Map<String, dynamic>) {
        final user = UserMeResponse.fromJson(res);
        final s = user.settings;
        if (s != null) {
          setState(() {
            _timezone = s.timezone;
            _defaultTaskDuration = _durationMinutesToDisplay(s.defaultDurationMinutes);
            _reminderOffset = _reminderMinutesToDisplay(s.defaultReminderOffsetMinutes);
            _startWorkingDay = s.workingHoursStart;
            _endWorkingDay = s.workingHoursEnd;
          });
        }
      }
    } catch (e) {
      if (mounted) debugPrint('Setting getUsersMe error: $e');
    } finally {
      if (mounted) setState(() => _settingsLoading = false);
    }
  }

  /// Build body và gọi PATCH users/settings.
  Future<void> _updateUsersSettings() async {
    try {
      final body = <String, dynamic>{
        'timezone': _timezone,
        'defaultDurationMinutes': _displayToDurationMinutes(_defaultTaskDuration),
        'defaultReminderOffsetMinutes': _displayToReminderMinutes(_reminderOffset),
        'workingHoursStart': _startWorkingDay,
        'workingHoursEnd': _endWorkingDay,
      };
      await Api.instance.restClient.updateUsersSettings(body);
    } catch (e) {
      if (mounted) debugPrint('Setting updateUsersSettings error: $e');
    }
  }

  /// Cho HomePage gọi khi user chuyển sang tab Settings.
  void fetchUsersMe() => _fetchUsersMe();

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
          fontWeight: FontWeight.w500,
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
          fontWeight: FontWeight.w500,
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
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
            if (value != null) ...[
              AppText(
                value,
                textType: AppTextType.s16w4,
                fontWeight: FontWeight.w500,
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
              fontWeight: FontWeight.w500,
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
              fontWeight: FontWeight.w500,
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
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          AppText(
            value,
            textType: AppTextType.s16w4,
            fontWeight: FontWeight.w500,
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
      optionIcons: const [
        Icons.light_mode,
        Icons.dark_mode,
        Icons.brightness_auto,
      ],
      onSelected: (value) async {
        final mode = value.toLowerCase();
        await AppSharedPref.setThemeMode(mode);
        if (mounted) setState(() => _theme = value);
        Get.forceAppUpdate();
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
        _updateUsersSettings();
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
        _updateUsersSettings();
      },
    );
  }

  void _onStartWorkingDayTap() {
    _showTimePicker(
      title: 'Start of Working Day',
      currentValue: _startWorkingDay,
      onSelected: (value) {
        setState(() => _startWorkingDay = value);
        _updateUsersSettings();
      },
    );
  }

  void _onEndWorkingDayTap() {
    _showTimePicker(
      title: 'End of Working Day',
      currentValue: _endWorkingDay,
      onSelected: (value) {
        setState(() => _endWorkingDay = value);
        _updateUsersSettings();
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
            onPressed: () async {
              Navigator.pop(context);
              await AppSharedPref.clear();
              // Navigate to login and clear stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
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
    List<IconData>? optionIcons,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final maxH = MediaQuery.of(context).size.height * 0.5;
        return Container(
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          title,
                          textType: AppTextType.custom,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 22.sp, color: const Color(0xFF6B7280)),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: const Color(0xFFE5E7EB)),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => SizedBox(height: 4.h),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = option == currentValue || currentValue.contains(option);
                      final icon = optionIcons != null && index < optionIcons.length ? optionIcons[index] : null;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onSelected(option);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                            child: Row(
                              children: [
                                if (icon != null) ...[
                                  Icon(
                                    icon,
                                    size: 22.sp,
                                    color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
                                  ),
                                  SizedBox(width: 12.w),
                                ],
                                Expanded(
                                  child: AppText(
                                    option,
                                    textType: AppTextType.s16w4,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    size: 22.sp,
                                    color: const Color(0xFF6366F1),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Parse giờ từ string: "09:00" (24h) hoặc "09:00 AM" / "05:00 PM" (12h).
  TimeOfDay _parseTimeString(String value) {
    final trimmed = value.trim();
    if (trimmed.contains(' ')) {
      final parts = trimmed.split(':');
      if (parts.length < 2) return const TimeOfDay(hour: 9, minute: 0);
      final minutePart = parts[1].split(' ');
      final minute = int.tryParse(minutePart[0].trim()) ?? 0;
      final isPM = minutePart.length > 1 && minutePart[1].toUpperCase().startsWith('P');
      var hour = int.tryParse(parts[0].trim()) ?? 9;
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    final parts = trimmed.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 9, minute: 0);
    final hour = int.tryParse(parts[0].trim()) ?? 9;
    final minute = int.tryParse(parts[1].trim()) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _showTimePicker({
    required String title,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    final initial = _parseTimeString(currentValue);
    final initialTime = Time(hour: initial.hour, minute: initial.minute, second: 0);

    Time? finalTime;
    Navigator.of(context)
        .push(
      showPicker(
        context: context,
        value: initialTime,
        onChange: (Time time) {
          finalTime = time;
        },
        onCancel: () => Navigator.of(context).pop(),
        is24HrFormat: true,
        minuteInterval: TimePickerInterval.ONE,
        iosStylePicker: true,
        displayHeader: true,
        accentColor: const Color(0xFF6366F1),
        unselectedColor: const Color(0xFF9CA3AF),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: 16,
        elevation: 8,
        okText: 'Ok',
        cancelText: 'Cancel',
        hourLabel: 'hours',
        minuteLabel: 'minutes',
      ),
    )
        .then((_) {
      if (finalTime != null && mounted) {
        final formatted = '${finalTime!.hour.toString().padLeft(2, '0')}:${finalTime!.minute.toString().padLeft(2, '0')}';
        onSelected(formatted);
      }
    });
  }
}
