import 'package:firebase_auth/firebase_auth.dart';
import 'package:videocalling/core/utils/logger.dart';

/// Global Firebase helper class to access Firebase Auth throughout the app
class FirebaseHelper {
  // Singleton pattern
  static final FirebaseHelper _instance = FirebaseHelper._internal();
  factory FirebaseHelper() => _instance;
  FirebaseHelper._internal();

  /// Get Firebase Auth instance
  FirebaseAuth get auth => FirebaseAuth.instance;

  /// Get current authenticated user
  User? get currentUser => auth.currentUser;

  /// Get current user ID
  String? get currentUserId => currentUser?.uid;

  /// Get current user email
  String? get currentUserEmail => currentUser?.email;

  /// Get current user phone number
  String? get currentUserPhone => currentUser?.phoneNumber;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      loggerNoStack.i('Signing in user with email: $email');
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        loggerNoStack.i(
          '✅ User signed in successfully: ${userCredential.user!.uid}',
        );
      } else {
        loggerNoStack.w('⚠️ Sign-in response received but no user found');
      }
      return userCredential;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error signing in: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      loggerNoStack.i('Signing up user with email: $email');
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        loggerNoStack.i(
          '✅ User signed up successfully: ${userCredential.user!.uid}',
        );
      } else {
        loggerNoStack.w('⚠️ Sign-up response received but no user found');
      }
      return userCredential;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error signing up: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sign in with phone number
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      loggerNoStack.i('Signing in with phone number: $phoneNumber');
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error initiating phone auth: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Verify phone verification code
  Future<UserCredential> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      loggerNoStack.i('Verifying phone code');
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await auth.signInWithCredential(credential);
      loggerNoStack.i('✅ Phone verification successful');
      return userCredential;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error verifying phone code: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      loggerNoStack.i('Signing out user...');
      await auth.signOut();
      loggerNoStack.i('✅ User signed out successfully');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error signing out: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Get user metadata
  Map<String, dynamic>? get userMetadata {
    final user = currentUser;
    if (user != null) {
      return {
        'name': user.displayName,
        'email': user.email,
        'emailVerified': user.emailVerified,
        'phoneNumber': user.phoneNumber,
        'photoURL': user.photoURL,
      };
    }
    return null;
  }

  /// Get current user token
  Future<String?> getIdToken() async {
    try {
      return await currentUser?.getIdToken();
    } catch (e) {
      loggerNoStack.e('❌ Error getting ID token: $e');
      return null;
    }
  }

  /// Print current user info (for debugging)
  void printUserInfo() {
    final user = currentUser;
    if (user != null) {
      loggerNoStack.i('=== Current User Info ===');
      loggerNoStack.i('ID: ${user.uid}');
      loggerNoStack.i('Email: ${user.email}');
      loggerNoStack.i('Email Verified: ${user.emailVerified}');
      loggerNoStack.i('Phone: ${user.phoneNumber}');
      loggerNoStack.i('Display Name: ${user.displayName}');
      loggerNoStack.i('Created At: ${user.metadata.creationTime}');
      loggerNoStack.i('Last Sign In: ${user.metadata.lastSignInTime}');
      loggerNoStack.i('========================');
    } else {
      loggerNoStack.w('No user is currently authenticated');
    }
  }

  /// Verify and log session status
  void verifySession() {
    final user = currentUser;

    loggerNoStack.i('=== Session Verification ===');
    if (user != null) {
      loggerNoStack.i('✅ User authenticated: ${user.uid}');
      loggerNoStack.i('✅ Session active');
      loggerNoStack.i('User email verified: ${user.emailVerified}');
      loggerNoStack.i('Last login: ${user.metadata.lastSignInTime}');
    } else {
      loggerNoStack.e('❌ No active session found');
      loggerNoStack.e('  - No user');
    }
    loggerNoStack.i('===========================');
  }

  /// Re-authenticate user with email and password (required before sensitive operations)
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('No authenticated user found');
      }

      loggerNoStack.i('Re-authenticating user: ${user.email}');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      loggerNoStack.i('✅ Re-authentication successful');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error re-authenticating: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Change user password (requires recent authentication)
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      loggerNoStack.i('Changing password for user: ${user.uid}');

      // Step 1: Re-authenticate with old password
      await reauthenticateWithPassword(oldPassword);

      // Step 2: Update password
      await user.updatePassword(newPassword);

      loggerNoStack.i('✅ Password changed successfully');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error changing password: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      // Provide more specific error messages
      if (e is FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          throw Exception('The old password is incorrect');
        } else if (e.code == 'weak-password') {
          throw Exception('The new password is too weak');
        } else if (e.code == 'requires-recent-login') {
          throw Exception('Please log in again to change your password');
        }
      }
      rethrow;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      loggerNoStack.i('Sending password reset email to: $email');
      await auth.sendPasswordResetEmail(email: email);
      loggerNoStack.i('✅ Password reset email sent successfully');
      return true;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error sending password reset email: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      if (user.emailVerified) {
        loggerNoStack.i('Email already verified');
        return;
      }

      loggerNoStack.i('Sending email verification to: ${user.email}');
      await user.sendEmailVerification();
      loggerNoStack.i('✅ Email verification sent successfully');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error sending email verification: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

/// Global instance for easy access
final firebaseHelper = FirebaseHelper();
