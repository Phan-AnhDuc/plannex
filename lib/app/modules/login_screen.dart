import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Components
import '../components/app_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
            _buildHeader(),

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

  /// Header with back button
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: _onBack,
            child: Container(
              width: 48.w,
              height: 48.h,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 24.sp,
                color: _isSignIn ? _textDark : _textDarkSignUp,
              ),
            ),
          ),
        ],
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
        fontWeight: FontWeight.bold,
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
                    color: _isSignIn
                        ? (_isSignIn ? _bgColorSignIn : _bgColorSignUp)
                        : Colors.transparent,
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
                    color: _isSignIn
                        ? (_isSignIn ? _textDark : _textDarkSignUp)
                        : (_isSignIn ? _textMedium : _textMediumSignUp),
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
                    color: !_isSignIn
                        ? (_isSignIn ? _bgColorSignIn : _bgColorSignUp)
                        : Colors.transparent,
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
                    color: !_isSignIn
                        ? (_isSignIn ? _textDark : _textDarkSignUp)
                        : (_isSignIn ? _textMedium : _textMediumSignUp),
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
              fontWeight: FontWeight.bold,
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
              color: hasError
                  ? (_isSignIn ? _bgColorSignIn : _bgColorSignUp)
                  : (_isSignIn ? _inputBg : _inputBgSignUp),
              borderRadius: BorderRadius.circular(12.r),
              border: hasError
                  ? Border.all(color: _borderColor, width: 1)
                  : null,
            ),
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontSize: 16.sp,
                color: _isSignIn ? _textDark : _textDarkSignUp,
              ),
              decoration: InputDecoration(
                hintText: hasError ? 'invalid-email' : 'Email',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
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
              color: _isSignIn ? _textMedium : _textMediumSignUp,
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
                color: _isSignIn ? _textDark : _textDarkSignUp,
              ),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
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
              color: _isSignIn ? _textMedium : _textMediumSignUp,
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
              color: hasError
                  ? _bgColorSignUp
                  : _inputBgSignUp,
              borderRadius: BorderRadius.circular(12.r),
              border: hasError
                  ? Border.all(color: _borderColor, width: 1)
                  : null,
            ),
            child: TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              style: TextStyle(
                fontSize: 16.sp,
                color: _textDarkSignUp,
              ),
              decoration: InputDecoration(
                hintText: 'Confirm password',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
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
              color: _textMediumSignUp,
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
            fontWeight: FontWeight.bold,
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

  /// Bottom link (switch between sign in/up)
  Widget _buildBottomLink() {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: GestureDetector(
        onTap: () => setState(() => _isSignIn = !_isSignIn),
        child: AppText(
          _isSignIn
              ? "Don't have an account? Create one"
              : 'Already have an account? Sign in',
          textType: AppTextType.s14w4,
          color: _isSignIn ? _textMedium : _textMediumSignUp,
          textAlign: TextAlign.center,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // Validation methods
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

  // Action methods
  void _onBack() {
    Navigator.of(context).pop();
  }

  void _onGoogleSignIn() {
    debugPrint('Google Sign In');
  }

  void _onAppleSignIn() {
    debugPrint('Apple Sign In');
  }

  void _onSubmit() {
    if (_isSignIn) {
      debugPrint('Sign In with email');
    } else {
      debugPrint('Sign Up with email');
    }
  }

  void _onForgotPassword() {
    debugPrint('Forgot password');
  }
}

