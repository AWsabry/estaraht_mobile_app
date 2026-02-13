import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class RegisterPatientController extends GetxController {
  // Instance du client Supabase
  final supabase = supabaseHelper;

  // Added gender options
  final genderOptions = ["male", "female"].obs;

  // Form fields
  RxString name = "".obs;
  RxString phoneNumber = "".obs;
  RxString email = "".obs;
  RxString emailOrPhone = "".obs; // Combined email or phone field
  RxString password = "".obs;
  RxString confirmPassword = "".obs;
  RxString age = "".obs;
  RxString gender = "".obs;

  // Error states
  RxString phnNumberError = "".obs;
  RxBool isPhoneNumberError = false.obs;
  RxBool isNameError = false.obs;
  RxBool isEmailError = false.obs;
  RxBool isEmailOrPhoneError = false.obs; // Combined email or phone error
  RxString emailOrPhoneError = "".obs; // Error message for combined field
  RxBool isPassError = false.obs;
  RxBool isAgeError = false.obs;
  RxBool isGenderError = false.obs;
  RxString token = "".obs;
  RxString error = "".obs;
  RxBool passwordVisible = true.obs;
  RxBool passwordVisible1 = true.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    getToken();
  }

  // Get FCM token
  getToken() async {
    final fcmToken = await firebaseMessaging.getToken();
    if (fcmToken != null) {
      token.value = fcmToken;
      print("FCM Token obtained: ${token.value}");
    }
  }

  // Validate form
  bool validateForm() {
    bool isValid = true;

    // Reset all error states
    isNameError.value = false;
    isEmailOrPhoneError.value = false; // Use combined field validation
    isPassError.value = false;
    isAgeError.value = false;
    isGenderError.value = false;

    // Validate name
    if (name.value.isEmpty) {
      isNameError.value = true;
      isValid = false;
    }

    // Validate combined email or phone field
    if (emailOrPhone.value.isEmpty) {
      isEmailOrPhoneError.value = true;
      emailOrPhoneError.value = 'email_or_phone_required'.tr;
      isValid = false;
    } else {
      // Check if it's a valid email
      bool isEmail = GetUtils.isEmail(emailOrPhone.value);

      if (!isEmail) {
        isEmailOrPhoneError.value = true;
        emailOrPhoneError.value = 'enter_valid_email'.tr;
        isValid = false;
      } else {
        email.value = emailOrPhone.value;
        phoneNumber.value = "";
      }
    }

    // Validate password
    if (password.value.isEmpty || password.value.length < 8) {
      isPassError.value = true;
      isValid = false;
    }

    // Validate age
    if (age.value.isEmpty) {
      isAgeError.value = true;
      isValid = false;
    }

    // Validate gender
    if (gender.value.isEmpty) {
      isGenderError.value = true;
      isValid = false;
    }

    return isValid;
  }

  // التحقق من عدم وجود البريد في Supabase
  Future<bool> _isEmailAlreadyUsed(String email) async {
    final result = await supabaseHelper.client
        .from('patients')
        .select('email')
        .eq('email', email)
        .maybeSingle();
    return result != null;
  }

  // STEP 1: Register user with Supabase and send OTP
  Future<void> registerUser() async {
    if (!validateForm()) {
      return;
    }

    customDialog1(s1: 'creating_account'.tr, s2: 'creating_account1'.tr);

    try {
      if (token.value.isEmpty) {
        await getToken();
      }

      // التحقق من عدم وجود البريد في Supabase قبل إنشاء حساب Firebase
      if (email.value.isNotEmpty) {
        final emailExists = await _isEmailAlreadyUsed(email.value);
        if (emailExists) {
          Get.back();
          customDialog(s1: 'error'.tr, s2: 'email_already_exists'.tr);
          return;
        }
      }

      // Generate a 6-digit OTP code
      final otpCode = _generateOTP();

      // Print OTP code to console log
      print('🔐 Generated OTP Code: $otpCode');
      print('📧 Sending OTP to: ${email.value}');

      // Register with Firebase Auth
      final authResponse = await firebaseHelper.signUp(
        email: email.value,
        password: password.value,
      );

      if (authResponse.user != null) {
        print('✅ User registered successfully: ${authResponse.user!.uid}');

        // insert into patients table
        try {
          await supabaseHelper.client.from('patients').insert({
            'id': authResponse.user!.uid,
            'name': name.value,
            'email': email.value,
            'phone': phoneNumber.value.isNotEmpty
                ? "+20${phoneNumber.value}"
                : null,
            'age': int.tryParse(age.value),
            'gender': gender.value,
            'fcm_token': token.value,
            'login_id':
                '${email.value.split('@')[0]}_${TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch}',
            'sessions_available': 0,
            'sessions_pending': 0,
            'subscribed': false,
            'subscribed_before': false,
            'timezone_offset_hours': DateTime.now().timeZoneOffset.inHours,
          });
          print(
            '✅ Patient profile created in Supabase for user ID: ${authResponse.user!.uid}',
          );
        } catch (supabaseError) {
          // فشل إدراج البيانات في Supabase - حذف حساب Firebase
          print('❌ Failed to insert patient in Supabase: $supabaseError');
          try {
            await authResponse.user!.delete();
            print('🗑️ Firebase account deleted due to Supabase failure');
          } catch (deleteError) {
            print('❌ Failed to delete Firebase account: $deleteError');
          }
          Get.back();
          customDialog(s1: 'error'.tr, s2: 'registration_failed'.tr);
          return;
        }

        // Save OTP to Supabase table with expiration (5 minutes from now)
        try {
          final otpRecord = await supabaseHelper.client
              .from('otp_codes')
              .insert({
                'user_id': authResponse.user!.uid,
                'email': email.value,
                'otp_code': otpCode,
                'expires_at': TimezoneService.getCurrentMauritaniaTime()
                    .add(const Duration(minutes: 5))
                    .toIso8601String(),
                'is_used': false,
              })
              .select()
              .single();

          final otpId = otpRecord['id'];
          print('💾 OTP saved to database with ID: $otpId');
          print('📋 User ID: ${authResponse.user!.uid}');
          print('📧 Email: ${email.value}');
          print('🔐 OTP Code: $otpCode');

          Get.back(); // Close loading dialog

          // Send welcome/OTP email via Gmail SMTP with the actual OTP code
          try {
            await EmailService.sendOtpEmail(
              to: email.value,
              otpCode:
                  otpCode, // Use the generated OTP code instead of hardcoded value
              userName: name.value,
            );
            print('✅ OTP email sent successfully with code: $otpCode');
          } catch (e) {
            print('⚠️ Gmail notification failed but Supabase OTP was sent: $e');
          }

          // Navigate to OTP screen with database validation
          Get.toNamed(
            Routes.otpScreen,
            arguments: {
              'email': email.value,
              'phone': null,
              'otpPurpose': OtpType.signup,
              'isPatient': true, // Flag to identify patient registration
              'otpId': otpId, // Pass OTP record ID for validation
              'userId': authResponse.user!.uid, // Pass user ID
              'expectedOtp': otpCode, // Also pass as fallback
            },
          );
        } catch (otpSaveError) {
          print('❌ Failed to save OTP to database: $otpSaveError');
          print('🔄 Falling back to console-only OTP validation');

          Get.back(); // Close loading dialog

          // Send email anyway
          try {
            await EmailService.sendOtpEmail(
              to: email.value,
              otpCode: otpCode,
              userName: name.value,
            );
            print('✅ OTP email sent successfully with code: $otpCode');
          } catch (e) {
            print('⚠️ Gmail notification failed: $e');
          }

          // Navigate to OTP screen with fallback validation
          Get.toNamed(
            Routes.otpScreen,
            arguments: {
              'email': email.value,
              'phone': null,
              'otpPurpose': OtpType.signup,
              'isPatient': true,
              'expectedOtp': otpCode, // Use fallback validation
              'userId': authResponse.user!.uid,
            },
          );
        }
      } else {
        Get.back();
        customDialog(s1: 'error'.tr, s2: 'registration_failed_user_exists'.tr);
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      print("Firebase Auth Error Code: ${e.code}");
      print("Firebase Auth Error Message: ${e.message}");

      // Handle Firebase Auth errors using error codes (more reliable than message strings)
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'email_already_exists'.tr;
          break;
        case 'weak-password':
          errorMessage = 'password_invalid'.tr; // Password is too weak
          break;
        case 'invalid-email':
          errorMessage = 'enter_email_error'.tr;
          break;
        case 'operation-not-allowed':
          errorMessage =
              'registration_failed_user_exists'.tr; // Registration not allowed
          break;
        case 'too-many-requests':
          errorMessage = 'error2'.tr; // Too many requests, please try again
          break;
        case 'network-request-failed':
        case 'network-error':
          errorMessage = 'error2'.tr; // Network error, please try again
          break;
        case 'user-disabled':
          errorMessage =
              'registration_failed_user_exists'.tr; // Account disabled
          break;
        default:
          // Fallback to checking message for other errors
          if (e.message != null) {
            final message = e.message!.toLowerCase();
            if (message.contains('email') && message.contains('already')) {
              errorMessage = 'email_already_exists'.tr;
            } else if (message.contains('password') &&
                (message.contains('weak') || message.contains('short'))) {
              errorMessage = 'password_invalid'.tr;
            } else if (message.contains('password')) {
              errorMessage = 'invalid_password'.tr;
            } else if (message.contains('phone') &&
                message.contains('already')) {
              errorMessage = 'phone_number_already_exists'.tr;
            } else {
              errorMessage = 'registration_failed_user_exists'.tr;
            }
          } else {
            errorMessage = 'an_unexpected_error_occurred'.tr;
          }
      }

      customDialog(s1: 'error'.tr, s2: errorMessage);
    } catch (e) {
      Get.back();
      print("An unexpected error occurred: $e");
      customDialog(s1: 'error'.tr, s2: 'an_unexpected_error_occurred'.tr);
    }
  }

  // Helper method to generate 6-digit OTP
  String _generateOTP() {
    final random = math.Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  // STEP 2: Finalize registration after OTP verification
  Future<void> finalizeRegistration(User user) async {
    print('🔧 finalizeRegistration called with user: ${user.uid}');

    customDialog1(s1: 'finalizing_setup'.tr, s2: 'please_wait'.tr);

    try {
      final String userId = user.uid;

      print(
        '📝 Patient record already exists in Supabase (created during registration)',
      );
      print('📝 Updating Firebase Realtime Database...');

      print('📝 Saving data to local storage...');
      // 2. Save data to local storage
      StorageService.writeBoolData(
        key: LocalStorageKeys.isLoggedIn,
        value: true,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.userId,
        value: userId,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.name,
        value: name.value,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.email,
        value: email.value,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.phone,
        value: phoneNumber.value.isNotEmpty ? "+20${phoneNumber.value}" : "",
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.age,
        value: age.value,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.gender,
        value: gender.value,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.userIdWithAscii,
        value: '117$userId',
      );
      print("✅ User data saved to local storage");

      // Sync user profile to Firebase Realtime Database for chat
      try {
        await FirebaseDatabase.instance.ref('117$userId').update({
          'name': name.value,
          'image': '', // Empty for new registrations
          'phone': phoneNumber.value.isNotEmpty ? "+20${phoneNumber.value}" : "",
          'email': email.value,
        });
        print('✅ Patient profile synced to Firebase Realtime Database');
      } catch (e) {
        print('❌ Failed to sync patient profile to Firebase: $e');
      }

      print('📧 Sending welcome email (async)...');
      // Send welcome email (don't wait for it)
      EmailService.sendWelcomeEmail(
            to: email.value,
            userName: name.value,
            userType: 'patient',
          )
          .then((_) {
            print('✅ Welcome email sent successfully');
          })
          .catchError((e) {
            print('⚠️ Welcome email failed but registration successful: $e');
          });

      print('🔙 Closing loading dialog...');
      Get.back(); // Close loading dialog

      print(
        "🎉 Registration completed successfully! Navigating to home screen...",
      );
      print("🔄 Calling Get.offAllNamed(Routes.userTabScreen)...");

      // Navigate directly to patient home screen
      Get.offAllNamed(Routes.userTabScreen);

      print("✅ Navigation call executed");
    } catch (e, stackTrace) {
      print("❌ Final registration error: $e");
      print("❌ Stack trace: $stackTrace");
      Get.back();
      customDialog(s1: 'error'.tr, s2: 'registration_failed'.tr);
      rethrow; // Re-throw so the OTP controller knows it failed
    }
  }
}
