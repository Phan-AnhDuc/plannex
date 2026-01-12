import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Components
import '../components/app_text.dart';

class LoginIntroScreen extends StatefulWidget {
  const LoginIntroScreen({super.key});

  @override
  State<LoginIntroScreen> createState() => _LoginIntroScreenState();
}

class _LoginIntroScreenState extends State<LoginIntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              // Header section
              Padding(
                padding: EdgeInsets.only(top: 48.h),
                child: Column(
                  children: [
                    // Title
                    AppText(
                      'Smart Time',
                      textType: AppTextType.custom,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF222222),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 16.h),

                    // Subtitle
                    AppText(
                      'Plan your day in minutes. AI helps you block time, not just list tasks.',
                      textType: AppTextType.custom,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF4B5563),
                      textAlign: TextAlign.center,
                      height: 1.5,
                    ),
                  ],
                ),
              ),

              // Center icon section
              Expanded(
                child: Center(
                  child: _buildCenterIcon(),
                ),
              ),

              // Bottom buttons section
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Calendar icon with mic badge
  Widget _buildCenterIcon() {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDBEAFE), // blue-100
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Calendar icon
          Center(
            child: Icon(
              Icons.calendar_month_outlined,
              size: 56.sp,
              color: const Color(0xFF2563EB),
            ),
          ),

          // Mic badge
          Positioned(
            bottom: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFDBEAFE),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.mic,
                size: 20.sp,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom section with buttons and footer
  Widget _buildBottomSection() {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        children: [
          // Primary button - Continue without account
          _buildPrimaryButton(
            text: 'Continue without account',
            onPressed: _onContinueWithoutAccount,
          ),

          SizedBox(height: 8.h),

          // Description for primary button
          AppText(
            'Your tasks are stored on this device. Sign in later to sync across devices.',
            textType: AppTextType.custom,
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF9CA3AF),
            textAlign: TextAlign.center,
            height: 1.4,
          ),

          SizedBox(height: 16.h),

          // Secondary button - Sign in or create account
          _buildSecondaryButton(
            text: 'Sign in or create account',
            onPressed: _onSignIn,
          ),

          SizedBox(height: 8.h),

          // Description for secondary button
          AppText(
            'Unlock sync, backup and premium features.',
            textType: AppTextType.custom,
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF9CA3AF),
            textAlign: TextAlign.center,
            height: 1.4,
          ),

          SizedBox(height: 24.h),

          // Terms and Privacy Policy
          _buildTermsText(),
        ],
      ),
    );
  }

  /// Primary button (blue background)
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999.r),
          ),
          elevation: 1,
        ),
        child: AppText(
          text,
          textType: AppTextType.custom,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Secondary button (white background, blue border)
  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2563EB),
          side: const BorderSide(
            color: Color(0xFF2563EB),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999.r),
          ),
        ),
        child: AppText(
          text,
          textType: AppTextType.custom,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2563EB),
        ),
      ),
    );
  }

  /// Terms and Privacy Policy text with links
  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF9CA3AF),
          height: 1.4,
        ),
        children: [
          const TextSpan(text: 'By continuing, you agree to the '),
          TextSpan(
            text: 'Terms',
            style: const TextStyle(color: Color(0xFF2563EB)),
            recognizer: TapGestureRecognizer()..onTap = _onTermsTap,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(color: Color(0xFF2563EB)),
            recognizer: TapGestureRecognizer()..onTap = _onPrivacyTap,
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  // Actions
  void _onContinueWithoutAccount() {
    // Navigate to main screen
    debugPrint('Continue without account');
  }

  void _onSignIn() {
    // Navigate to sign in screen
    debugPrint('Sign in or create account');
  }

  void _onTermsTap() {
    // Open Terms page
    debugPrint('Terms tapped');
  }

  void _onPrivacyTap() {
    // Open Privacy Policy page
    debugPrint('Privacy Policy tapped');
  }
}

