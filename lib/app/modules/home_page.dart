import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Screens
import 'home_today.dart';
import 'schedule_screen.dart';
import 'setting_screen.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Pages for bottom navigation
  List<Widget> get _pages => [
    HomeTodayScreen(onTabChanged: _onTabChanged),
    ScheduleScreen(onTabChanged: _onTabChanged),
    _PlaceholderScreen(title: 'AI Planner', onTabChanged: _onTabChanged, currentIndex: 2),
    SettingScreen(onTabChanged: _onTabChanged),
  ];

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
  }
}

// Placeholder screen for other tabs
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final Function(int) onTabChanged;
  final int currentIndex;

  const _PlaceholderScreen({
    required this.title,
    required this.onTabChanged,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTabChanged: onTabChanged,
      ),
    );
  }
}

/// Reusable Bottom Navigation Bar Widget
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Today',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.date_range_outlined,
                activeIcon: Icons.date_range,
                label: 'Schedule',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome,
                label: 'AI Planner',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: () => onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24.sp,
              color: color,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
