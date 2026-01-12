import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable secondary/text button widget
/// Commonly used for skip, cancel, or secondary actions
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? height;
  final double? borderRadius;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 40.h,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: textColor ?? const Color(0xFF111318),
            letterSpacing: 0.015,
          ),
        ),
      ),
    );
  }
}
