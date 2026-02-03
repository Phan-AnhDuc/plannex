import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

// Components
import '../components/app_text.dart';
// Services
import '../services/firebase_auth_service.dart';
// Repository & data
import '../repository/repository.dart';
import '../data/app_shared_pref.dart';
// Pages
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Auth service
  final FirebaseAuthService _authService = FirebaseAuthService();

  // State
  bool _isSignIn = true;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Validation state
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Colors
  static const Color _bgColorSignIn = Colors.white;
  static const Color _bgColorSignUp = Color(0xFFF8F9FC);
  static const Color _textDark = Color(0xFF111318);
  static const Color _textDarkSignUp = Color(0xFF0C121D);
  static const Color _textMedium = Color(0xFF637088);
  static const Color _textMediumSignUp = Color(0xFF4568A1);
  static const Color _inputBg = Color(0xFFF0F2F4);
  static const Color _inputBgSignUp = Color(0xFFE6EBF4);
  static const Color _buttonBlue = Color(0xFF6494ED);
  static const Color _buttonBlueSignUp = Color(0xFF9EC3FF);
  static const Color _borderColor = Color(0xFFCDD8EA);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isSignIn ? _bgColorSignIn : _bgColorSignUp,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            // _buildHeader(),
            SizedBox(height: 40.h),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Title
                    _buildTitle(),

                    SizedBox(height: 12.h),

                    // Tab switcher
                    _buildTabSwitcher(),

                    SizedBox(height: 12.h),

                    // Social buttons
                    _buildSocialButtons(),

                    SizedBox(height: 4.h),

                    // "or use email" text
                    _buildOrEmailText(),

                    SizedBox(height: 4.h),

                    // Email input
                    _buildEmailInput(),

                    // Password input
                    _buildPasswordInput(),

                    // Confirm password (Sign up only)
                    if (!_isSignIn) _buildConfirmPasswordInput(),

                    SizedBox(height: 4.h),

                    // Submit button
                    _buildSubmitButton(),

                    // Forgot password (Sign in only)
                    if (_isSignIn) _buildForgotPassword(),

                    SizedBox(height: 16.h),

                    // Anonymous sign in
                    _buildAnonymousButton(),
                  ],
                ),
              ),
            ),

            // Bottom link
            _buildBottomLink(),
          ],
        ),
      ),
    );
  }

  /// Title
  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AppText(
        _isSignIn ? 'Welcome back' : 'Create your account',
        textType: AppTextType.custom,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: _isSignIn ? _textDark : _textDarkSignUp,
        textAlign: TextAlign.center,
        letterSpacing: -0.015,
      ),
    );
  }

  /// Tab switcher (Sign in / Sign up)
  Widget _buildTabSwitcher() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: _isSignIn ? _inputBg : _inputBgSignUp,
          borderRadius: BorderRadius.circular(999.r),
        ),
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            // Sign in tab
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isSignIn = true),
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: _isSignIn ? (_isSignIn ? _bgColorSignIn : _bgColorSignUp) : Colors.transparent,
                    borderRadius: BorderRadius.circular(999.r),
                    boxShadow: _isSignIn
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: AppText(
                    'Sign in',
                    textType: AppTextType.s14w4,
                    fontWeight: FontWeight.w500,
                    color: _isSignIn ? (_isSignIn ? _textDark : _textDarkSignUp) : (_isSignIn ? _textMedium : _textMediumSignUp),
                  ),
                ),
              ),
            ),

            // Sign up tab
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isSignIn = false),
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: !_isSignIn ? (_isSignIn ? _bgColorSignIn : _bgColorSignUp) : Colors.transparent,
                    borderRadius: BorderRadius.circular(999.r),
                    boxShadow: !_isSignIn
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: AppText(
                    'Sign up',
                    textType: AppTextType.s14w4,
                    fontWeight: FontWeight.w500,
                    color: !_isSignIn ? (_isSignIn ? _textDark : _textDarkSignUp) : (_isSignIn ? _textMedium : _textMediumSignUp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Social login buttons (Google & Apple)
  Widget _buildSocialButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Google button
          _buildSocialButton(
            icon: Icons.g_mobiledata,
            text: 'Continue with Google',
            backgroundColor: _isSignIn ? _inputBg : _inputBgSignUp,
            onPressed: _onGoogleSignIn,
          ),

          SizedBox(height: 12.h),

          // Apple button
          _buildSocialButton(
            icon: Icons.apple,
            text: 'Continue with Apple',
            backgroundColor: _isSignIn ? _buttonBlue : _buttonBlueSignUp,
            onPressed: _onAppleSignIn,
          ),
        ],
      ),
    );
  }

  /// Single social button
  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: _isSignIn ? _textDark : _textDarkSignUp,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999.r),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: _isSignIn ? _textDark : _textDarkSignUp,
            ),
            SizedBox(width: 8.w),
            AppText(
              text,
              textType: AppTextType.s16w4,
              fontWeight: FontWeight.w500,
              color: _isSignIn ? _textDark : _textDarkSignUp,
            ),
          ],
        ),
      ),
    );
  }

  /// "or use email" divider text
  Widget _buildOrEmailText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: AppText(
        'or use email',
        textType: AppTextType.s14w4,
        color: _isSignIn ? _textMedium : _textMediumSignUp,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Email input field
  Widget _buildEmailInput() {
    final hasError = _emailError != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: hasError ? (_isSignIn ? _bgColorSignIn : _bgColorSignUp) : (_isSignIn ? _inputBg : _inputBgSignUp),
              borderRadius: BorderRadius.circular(12.r),
              border: hasError ? Border.all(color: _borderColor, width: 1) : null,
            ),
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: _isSignIn ? _textDark : _textDarkSignUp,
              ),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: _isSignIn ? _textMedium : _textMediumSignUp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              onChanged: (_) => _validateEmail(),
            ),
          ),
          if (hasError) ...[
            SizedBox(height: 4.h),
            AppText(
              _emailError!,
              textType: AppTextType.s14w4,
              color: const Color(0xFFEF4444),
            ),
          ],
        ],
      ),
    );
  }

  /// Password input field
  Widget _buildPasswordInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: _isSignIn ? _inputBg : _inputBgSignUp,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: _isSignIn ? _textDark : _textDarkSignUp,
              ),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: _isSignIn ? _textMedium : _textMediumSignUp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              onChanged: (_) => _validatePassword(),
            ),
          ),
          if (!_isSignIn && _passwordError != null) ...[
            SizedBox(height: 4.h),
            AppText(
              _passwordError!,
              textType: AppTextType.s14w4,
              color: const Color(0xFFEF4444),
            ),
          ],
        ],
      ),
    );
  }

  /// Confirm password input (Sign up only)
  Widget _buildConfirmPasswordInput() {
    final hasError = _confirmPasswordError != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: hasError ? _bgColorSignUp : _inputBgSignUp,
              borderRadius: BorderRadius.circular(12.r),
              border: hasError ? Border.all(color: _borderColor, width: 1) : null,
            ),
            child: TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: _textDarkSignUp,
              ),
              decoration: InputDecoration(
                hintText: 'Confirm password',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: _textMediumSignUp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              onChanged: (_) => _validateConfirmPassword(),
            ),
          ),
          if (hasError) ...[
            SizedBox(height: 4.h),
            AppText(
              _confirmPasswordError!,
              textType: AppTextType.s14w4,
              color: const Color(0xFFEF4444),
            ),
          ],
        ],
      ),
    );
  }

  /// Submit button
  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: _onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSignIn ? _buttonBlue : _buttonBlueSignUp,
            foregroundColor: _isSignIn ? _textDark : _textDarkSignUp,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999.r),
            ),
            elevation: 0,
          ),
          child: AppText(
            _isSignIn ? 'Sign in with email' : 'Sign up with email',
            textType: AppTextType.s16w4,
            fontWeight: FontWeight.w500,
            color: _isSignIn ? _textDark : _textDarkSignUp,
          ),
        ),
      ),
    );
  }

  /// Forgot password link (Sign in only)
  Widget _buildForgotPassword() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: GestureDetector(
        onTap: _onForgotPassword,
        child: AppText(
          'Forgot password?',
          textType: AppTextType.s14w4,
          color: _textMedium,
          textAlign: TextAlign.center,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  /// Anonymous sign in button
  Widget _buildAnonymousButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: _onAnonymousSignIn,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 20.sp,
                color: _isSignIn ? _textMedium : _textMediumSignUp,
              ),
              SizedBox(width: 8.w),
              AppText(
                'Continue without account',
                textType: AppTextType.s14w4,
                fontWeight: FontWeight.w500,
                color: _isSignIn ? _textMedium : _textMediumSignUp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom link (switch between sign in/up)
  Widget _buildBottomLink() {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: GestureDetector(
        onTap: () => setState(() => _isSignIn = !_isSignIn),
        child: AppText(
          _isSignIn ? "Don't have an account? Create one" : 'Already have an account? Sign in',
          textType: AppTextType.s14w4,
          color: _isSignIn ? _textMedium : _textMediumSignUp,
          textAlign: TextAlign.center,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // ============ Validation methods ============

  void _validateEmail() {
    final email = _emailController.text;
    if (email.isNotEmpty && !_isValidEmail(email)) {
      setState(() => _emailError = 'Please enter a valid email address.');
    } else {
      setState(() => _emailError = null);
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;
    if (!_isSignIn && password.isNotEmpty && password.length < 8) {
      setState(() => _passwordError = 'Password must be at least 8 characters.');
    } else {
      setState(() => _passwordError = null);
    }
  }

  void _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isNotEmpty && password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match.');
    } else {
      setState(() => _confirmPasswordError = null);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _validateForm() {
    _validateEmail();
    _validatePassword();
    if (!_isSignIn) {
      _validateConfirmPassword();
    }

    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return false;
    }

    return _emailError == null && _passwordError == null && (_isSignIn || _confirmPasswordError == null);
  }

  // ============ Action methods ============

  Future<void> _onGoogleSignIn() async {
    EasyLoading.show(status: 'Signing in...');

    final result = await _authService.signInWithGoogle();

    EasyLoading.dismiss();

    if (result.isSuccess && result.user != null) {
      _showSuccess('Signed in successfully!');
      await _onLoginSuccess(result.user!);
    } else {
      _showError(result.errorMessage ?? 'Failed to sign in with Google');
    }
  }

  Future<void> _onAppleSignIn() async {
    // Apple Sign In requires additional setup
    _showError('Apple Sign In is not configured yet');
  }

  Future<void> _onSubmit() async {
    if (!_validateForm()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    EasyLoading.show(status: _isSignIn ? 'Signing in...' : 'Creating account...');

    AuthResult result;
    if (_isSignIn) {
      result = await _authService.signInWithEmail(email, password);
    } else {
      result = await _authService.signUpWithEmail(email, password);
    }

    EasyLoading.dismiss();

    if (result.isSuccess && result.user != null) {
      _showSuccess(_isSignIn ? 'Signed in successfully!' : 'Account created successfully!');
      await _onLoginSuccess(result.user!);
    } else {
      _showError(result.errorMessage ?? 'An error occurred');
    }
  }

  Future<void> _onForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !_isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    EasyLoading.show(status: 'Sending reset email...');

    final result = await _authService.sendPasswordResetEmail(email);

    EasyLoading.dismiss();

    if (result.isSuccess) {
      _showSuccess('Password reset email sent!');
    } else {
      _showError(result.errorMessage ?? 'Failed to send reset email');
    }
  }

  Future<void> _onAnonymousSignIn() async {
    EasyLoading.show(status: 'Continuing...');

    final result = await _authService.signInAnonymously();

    EasyLoading.dismiss();

    if (result.isSuccess && result.user != null) {
      _showSuccess('Welcome!');
      await _onLoginSuccess(result.user!);
    } else {
      _showError(result.errorMessage ?? 'Failed to continue');
    }
  }

  /// Lấy timezone local dạng IANA (ví dụ Asia/Ho_Chi_Minh).
  String _getLocalTimezone() {
    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    const ianaByOffset = {
      7: 'Asia/Ho_Chi_Minh',
      8: 'Asia/Singapore',
      9: 'Asia/Tokyo',
      0: 'UTC',
      -5: 'America/New_York',
      -8: 'America/Los_Angeles',
    };
    return ianaByOffset[offsetHours] ?? 'UTC';
  }

  /// Sau khi đăng nhập thành công: lưu token (nếu cần), gọi API login với timezone, rồi vào Home.
  Future<void> _onLoginSuccess(User user) async {
    final token = await user.getIdToken();
    if (token != null && token.isNotEmpty) {
      await AppSharedPref.setToken(token);
    }
    final timezone = _getLocalTimezone();
    try {
      await Api.instance.restClient.login(timezone);
    } catch (_) {
      // Vẫn vào Home dù API login lỗi (mạng, backend...)
    }
    if (!mounted) return;
    _navigateToHome();
  }

  void _navigateToHome() {
    Get.offAll(() => const HomePage());
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  // Future<void> _saveTokens(dynamic user) async {
  //   try {
  //     final idToken = await user.getIdToken();
  //     print('========idToken==========$idToken');
  //     if (idToken != null && idToken.isNotEmpty) {
  //       await PrefUtils.setToken(idToken);
  //       print('ID Token saved successfully');
  //     }
  //     if (idToken != null && idToken.isNotEmpty) {
  //       await PrefUtils.setRefreshToken(idToken);
  //       print('Refresh Token reference saved (using idToken as reference)');
  //     }
  //   } catch (e) {
  //     print('Error saving tokens: $e');
  //   }
  // }
}
