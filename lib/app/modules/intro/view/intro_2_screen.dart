import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Controller
import '../controllers/intro_controller.dart';
// Components
import '../../../components/intro/intro_components.dart';
import '../../../components/app_text.dart';

class Intro2Screen extends GetView<IntroController> {
  const Intro2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            _buildHeader(),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 12.h),

                    // Avatar/Profile image
                    _buildAvatar(),

                    SizedBox(height: 24.h),

                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AppText(
                        'Allow reminders before due?',
                        textType: AppTextType.custom,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111318),
                        textAlign: TextAlign.center,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Description
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AppText(
                        'The app will send notifications 15 minutes before to ensure you don\'t miss important tasks.',
                        textType: AppTextType.s16w4,
                        color: const Color(0xFF111318),
                        textAlign: TextAlign.center,
                        height: 1.5,
                      ),
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
                  // Enable notifications button
                  PrimaryButton(
                    text: 'Enable notifications',
                    onPressed: () => controller.onGetStarted(context),
                  ),

                  SizedBox(height: 12.h),

                  // Not now button
                  SecondaryButton(
                    text: 'Not now',
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

  /// Header with close button on the right
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Close button
          GestureDetector(
            onTap: controller.skipIntro,
            child: Container(
              width: 48.w,
              height: 48.h,
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                size: 24.sp,
                color: const Color(0xFF111318),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Circular avatar with notification bell icon
  Widget _buildAvatar() {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F4),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 4.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.notifications_outlined,
          size: 22.sp,
          color: const Color(0xFF616E89),
        ),
      ),
    );
  }
}

