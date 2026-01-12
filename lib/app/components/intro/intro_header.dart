import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable header widget for intro/onboarding screens
/// Displays a leading icon, centered title, and optional trailing widget
class IntroHeader extends StatelessWidget {
  final String title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;

  const IntroHeader({
    super.key,
    required this.title,
    this.leadingIcon,
    this.onLeadingTap,
    this.trailing,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Leading icon
          GestureDetector(
            onTap: onLeadingTap,
            child: Container(
              width: 48.w,
              height: 48.h,
              alignment: Alignment.center,
              child: leadingIcon != null
                  ? Icon(
                      leadingIcon,
                      size: 24.sp,
                      color: iconColor ?? const Color(0xFF111318),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // Title
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: titleColor ?? const Color(0xFF111318),
                letterSpacing: -0.015,
              ),
            ),
          ),
          // Trailing widget or spacer
          SizedBox(
            width: 48.w,
            child: trailing ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
