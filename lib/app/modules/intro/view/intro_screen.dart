import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Controller
import '../controllers/intro_controller.dart';
// Components
import '../../../components/intro/intro_components.dart';
import '../../../components/app_text.dart';
import '../../../components/app_icon.dart';

class IntroScreen extends GetView<IntroController> {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with checkmark and title
            const IntroHeader(
              title: 'SmartTask AI',
              leadingIcon: Icons.check,
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    
                    // Circular graphic with checklist icon
                    const ChecklistGraphic(
                      backgroundColor: Color(0xFFB8A5D8), // Light purple matching design
                    ),

                    SizedBox(height: 20.h),

                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AppText(
                        'Transform tasks into smart schedules.',
                        textType: AppTextType.custom,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111318),
                        textAlign: TextAlign.center,
                        letterSpacing: -0.015,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Feature items
                    _buildFeatureItem(
                      iconPath: AppIcon.ic_add_svg,
                      text: 'Add tasks in seconds.',
                    ),
                    _buildFeatureItem(
                      iconPath: AppIcon.ic_suggets_svg,
                      text: 'AI suggests optimal free time.',
                    ),
                    _buildFeatureItem(
                      iconPath: AppIcon.ic_noti_svg,
                      text: 'Get reminded 15 minutes before due.',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                children: [
                  // Get started button
                  PrimaryButton(
                    text: 'Get started',
                    onPressed: () => controller.onGetStarted(context),
                  ),

                  SizedBox(height: 12.h),

                  // Skip button
                  SecondaryButton(
                    text: 'Skip',
                    onPressed: controller.skipIntro,
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Feature item widget with SVG icon
  Widget _buildFeatureItem({
    required String iconPath,
    required String text,
    Color? iconColor,
    Color? backgroundColor,
    Color? textColor,
    double? iconSize,
    double? containerSize,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // Icon container with SVG
          Container(
            width: containerSize ?? 40.w,
            height: containerSize ?? 40.h,
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0xFFF0F1F4),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: iconSize ?? 24.w,
                height: iconSize ?? 24.h,
                colorFilter: iconColor != null
                    ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                    : const ColorFilter.mode(Color(0xFF111318), BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Text using AppText
          Expanded(
            child: AppText(
              text,
              textType: AppTextType.s16w4,
              color: textColor ?? const Color(0xFF111318),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
