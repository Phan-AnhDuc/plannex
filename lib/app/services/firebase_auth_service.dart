import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/app_shared_pref.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Email & Password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('An unexpected error occurred');
    }
  }

  // Sign up with Email & Password
  Future<AuthResult> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('An unexpected error occurred');
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      debugPrint('===== 1. Bắt đầu quá trình đăng nhập Google =====');

      // Kiểm tra Google Play Services
      bool isPlayServicesAvailable = await _checkGooglePlayServices();
      if (!isPlayServicesAvailable) {
        return AuthResult.error(
          'Google Play Services không khả dụng hoặc cần được cập nhật',
        );
      }

      // Xóa tài khoản hiện tại (nếu có)
      try {
        await _googleSignIn.signOut();
        debugPrint('===== 2. Đã đăng xuất khỏi các phiên trước đó =====');
      } catch (e) {
        debugPrint('===== 2. Lỗi khi đăng xuất khỏi phiên trước: $e =====');
        // Không return ở đây, tiếp tục quá trình
      }

      // Bắt đầu quá trình đăng nhập
      debugPrint('===== 3. Đang gọi _googleSignIn.signIn() =====');

      // Sử dụng try-catch riêng cho bước signIn
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (signInError) {
        debugPrint('===== ERROR: Lỗi trong quá trình signIn: $signInError =====');
        return AuthResult.error('Lỗi khi đăng nhập với Google: $signInError');
      }

      debugPrint('===== 4. Kết quả _googleSignIn.signIn(): $googleUser =====');

      // Người dùng hủy đăng nhập
      if (googleUser == null) {
        debugPrint('===== 5. Người dùng đã hủy đăng nhập =====');
        return AuthResult.error('Đăng nhập Google đã bị hủy');
      }

      // Lấy thông tin xác thực
      debugPrint('===== 6. Đang lấy thông tin xác thực =====');

      GoogleSignInAuthentication? googleAuth;
      try {
        googleAuth = await googleUser.authentication;
        debugPrint(
          '===== 7. Đã nhận thông tin xác thực: accessToken=${googleAuth.accessToken != null}, idToken=${googleAuth.idToken != null} =====',
        );
      } catch (authError) {
        debugPrint('===== ERROR: Lỗi khi lấy thông tin xác thực: $authError =====');
        return AuthResult.error(
          'Không thể lấy thông tin xác thực từ Google: $authError',
        );
      }

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('===== ERROR: Token không hợp lệ =====');
        return AuthResult.error('Không thể lấy token xác thực từ Google');
      }

      debugPrint('========accessToken===========${googleAuth.accessToken}');
      debugPrint('========idToken===========${googleAuth.idToken}');

      // Tạo credential
      debugPrint('===== 8. Đang tạo credential =====');
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase
      debugPrint('===== 9. Đang đăng nhập vào Firebase =====');
      try {
        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        debugPrint(
          '===== 10. Đăng nhập Firebase thành công: ${userCredential.user?.displayName} =====',
        );
        
        // Kiểm tra user không null trước khi lấy token
        final user = userCredential.user;
        if (user == null) {
          debugPrint('===== ERROR: userCredential.user is null =====');
          return AuthResult.error('Đăng nhập Firebase thất bại: User is null');
        }

        // Lấy ID Token
        final idToken = await user.getIdToken();
        if (idToken == null || idToken.isEmpty) {
          debugPrint('===== ERROR: idToken is null or empty =====');
          return AuthResult.error('Đăng nhập Firebase thất bại: Không thể lấy ID Token');
        }
        
        debugPrint('========idToken==========$idToken');
        await AppSharedPref.setToken(idToken);

        return AuthResult.success(user);
      } catch (credentialError) {
        debugPrint(
          '===== ERROR: Lỗi khi đăng nhập với credential: $credentialError =====',
        );
        return AuthResult.error('Đăng nhập Firebase thất bại: $credentialError');
      }
    } catch (e) {
      debugPrint('===== ERROR: Lỗi đăng nhập Google: $e =====');
      // Đảm bảo đăng xuất để tránh trạng thái không nhất quán
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      return AuthResult.error('Đăng nhập Google thất bại: $e');
    }
  }

  // Kiểm tra Google Play Services
  Future<bool> _checkGooglePlayServices() async {
    try {
      // Thử kết nối với Google Play Services
      await _googleSignIn.signOut();
      return true;
    } on PlatformException catch (e) {
      debugPrint('===== ERROR: Google Play Services không khả dụng: $e =====');
      return false;
    } catch (e) {
      debugPrint('===== ERROR: Lỗi kiểm tra Google Play Services: $e =====');
      return false;
    }
  }

  // Sign in Anonymously
  Future<AuthResult> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('An unexpected error occurred');
    }
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('An unexpected error occurred');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Link anonymous account to email/password
  Future<AuthResult> linkWithEmail(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final userCredential = await _auth.currentUser?.linkWithCredential(credential);
      return AuthResult.success(userCredential?.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('An unexpected error occurred');
    }
  }

  // Link anonymous account to Google
  Future<AuthResult> linkWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.error('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.currentUser?.linkWithCredential(credential);
      return AuthResult.success(userCredential?.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('Failed to link with Google');
    }
  }

  // Get error message from Firebase error code
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'play-services-not-available':
        return 'Google Play Services không khả dụng';
      case 'google-sign-in-failed':
        return 'Đăng nhập Google thất bại';
      case 'google-auth-failed':
        return 'Không thể xác thực với Google';
      case 'firebase-auth-failed':
        return 'Đăng nhập Firebase thất bại';
      default:
        return 'An error occurred. Please try again';
    }
  }
}

// Auth result model
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;
  final String? successMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.successMessage,
  });

  factory AuthResult.success(User? user, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      successMessage: message,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}
