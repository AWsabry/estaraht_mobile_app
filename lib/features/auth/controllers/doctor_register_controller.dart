import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;
import 'package:videocalling/core/config/app_imports.dart';

class DoctorRegisterController extends GetxController {
  // Instance du client Supabase
  final supabase = supabaseHelper;

  // --- Variables d'état (inchangées) ---
  final genderOptions = ["male", "female"].obs;
  final selectedGender = RxString("");
  RxString name = "".obs;
  RxString phoneNumber = "".obs;
  RxString email = "".obs;
  RxString password = "".obs;
  RxString confirmPassword = "".obs;
  RxString age = "".obs;
  RxString gender = "".obs;
  RxString phnNumberError = "".obs;
  RxBool isPhoneNumberError = false.obs;
  RxBool isNameError = false.obs;
  RxBool isEmailError = false.obs;
  RxBool isPassError = false.obs;
  RxBool isAgeError = false.obs;
  RxBool isGenderError = false.obs;
  RxString token = "".obs; // Token FCM
  RxString error = "".obs;
  RxBool passwordVisible = true.obs;
  RxBool passwordVisible1 = true.obs;
  final formKey = GlobalKey<FormState>();

  // --- Fonctions d'aide et de validation (inchangées) ---
  void setGender(String gender) {
    selectedGender.value = gender;
    this.gender.value = gender;
    isGenderError.value = false;
  }

  void detectInputType(String val) {
    isEmailError.value = false;
    isPhoneNumberError.value = false;
    String input = val.trim();
    if (input.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(input)) {
      phoneNumber.value = input;
      email.value = "";
    } else {
      email.value = input;
      phoneNumber.value = "";
    }
  }

  bool validateForm() {
    bool isValid = true;
    isNameError.value = false;
    isEmailError.value = false;
    isPhoneNumberError.value = false;
    isPassError.value = false;
    isAgeError.value = false;
    isGenderError.value = false;

    if (name.value.isEmpty) {
      isNameError.value = true;
      isValid = false;
    }
    if (email.value.isNotEmpty) {
      if (!GetUtils.isEmail(email.value)) {
        isEmailError.value = true;
        isValid = false;
      }
    } else if (phoneNumber.value.isNotEmpty) {
      if (!RegExp(r'^[0-9]{8}$').hasMatch(phoneNumber.value)) {
        isPhoneNumberError.value = true;
        phnNumberError.value = "valid_mobile_number".tr;
        isValid = false;
      }
    } else {
      isEmailError.value = true;
      isValid = false;
    }
    if (password.value.isEmpty || password.value.length < 8) {
      isPassError.value = true;
      isValid = false;
    }
    if (age.value.isEmpty) {
      isAgeError.value = true;
      isValid = false;
    }
    if (gender.value.isEmpty) {
      isGenderError.value = true;
      isValid = false;
    }
    return isValid;
  }

  // --- ÉTAPE 1: Démarrer l'inscription et rediriger vers l'OTP ---
  Future<void> registerUserWithSupabase() async {
    if (!validateForm()) {
      return;
    }

    customDialog1(s1: 'creating_account'.tr, s2: 'creating_account1'.tr);

    try {
      if (token.value.isEmpty) {
        await getToken();
      }

      // Generate a 6-digit OTP code
      final otpCode = _generateOTP();

      print('🔐 Generated OTP Code: $otpCode');
      print('📧 Sending OTP to: ${email.value}');

      // Register with Firebase Auth
      final authResponse = await firebaseHelper.signUp(
        email: email.value,
        password: password.value,
      );

      if (authResponse.user != null) {
        print('✅ User registered successfully: ${authResponse.user!.uid}');

        // Insert into doctors table
        await supabase.from('doctors').insert({
          'doctor_id': authResponse.user!.uid,
          'full_name': name.value,
          'email': email.value,
          'phone_number': phoneNumber.value.isNotEmpty
              ? "+20${phoneNumber.value}"
              : null,
          'age': int.tryParse(age.value),
          'gender': gender.value,
          'specialization': "",
          'bio': "",
          'years_of_exp': 0,
          'numb_patients': 0,
          'profile_img_url': "",
          'booking_price': 50,
        });
        print(
          '✅ Doctor profile created in Supabase for user ID: ${authResponse.user!.uid}',
        );

        // Save OTP to Supabase table with expiration (5 minutes from now)
        try {
          final otpRecord = await supabase
              .from('otp_codes')
              .insert({
                'user_id': authResponse.user!.uid,
                'email': email.value,
                'otp_code': otpCode,
                'expires_at': DateTime.now()
                    .add(const Duration(minutes: 5))
                    .toIso8601String(),
                'is_used': false,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

          final otpId = otpRecord['id'];
          print('💾 OTP saved to database with ID: $otpId');

          Get.back(); // Close loading dialog

          // Send OTP email
          try {
            await EmailService.sendOtpEmail(
              to: email.value,
              otpCode: otpCode,
              userName: name.value,
            );
            print('✅ OTP email sent successfully with code: $otpCode');
          } catch (e) {
            print('⚠️ Gmail notification failed but OTP was saved: $e');
          }

          // Navigate to OTP screen with database validation
          Get.toNamed(
            Routes.otpScreen,
            arguments: {
              'email': email.value,
              'phone': null,
              'otpPurpose': OtpType.signup,
              'isPatient': false, // This is a doctor
              'otpId': otpId,
              'userId': authResponse.user!.uid,
              'expectedOtp': otpCode,
            },
          );
        } catch (otpSaveError) {
          print('❌ Failed to save OTP to database: $otpSaveError');
          Get.back();

          // Send email anyway
          try {
            await EmailService.sendOtpEmail(
              to: email.value,
              otpCode: otpCode,
              userName: name.value,
            );
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
              'isPatient': false,
              'expectedOtp': otpCode,
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
      print("Firebase Auth Error: ${e.message}");
      customDialog(s1: 'error'.tr, s2: e.message ?? 'An error occurred');
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

  // --- ÉTAPE 2: Finaliser l'inscription APRÈS la vérification OTP ---
  // Cette fonction sera appelée par OtpController après une vérification réussie.
  Future<void> finalizeRegistration(User user) async {
    customDialog1(s1: 'finalizing_setup'.tr, s2: 'please_wait'.tr);

    try {
      final String userId = user.uid;

      print(
        '📝 Doctor record already exists in Supabase (created during registration)',
      );
      print('📝 Updating Firebase Realtime Database...');

      // 2. Sauvegarder les données dans le stockage local
      StorageService.writeBoolData(
        key: LocalStorageKeys.isLoggedInAsDoctor,
        value: true,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.userId,
        value: userId,
      );
      StorageService.writeBoolData(key: 'isNewDoctorRegistration', value: true);
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
        value: '100$userId',
      );

      // 3. Send welcome email
      try {
        await EmailService.sendWelcomeEmail(
          to: email.value,
          userName: name.value,
          userType: 'doctor',
        );
        print('✅ Welcome email sent successfully');
      } catch (e) {
        print('⚠️ Welcome email failed but registration successful: $e');
      }

      Get.back(); // Close loading dialog
      customDialog(s1: 'success'.tr, s2: 'registration_successful'.tr);

      // Navigate to doctor home screen
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.doctorTabScreen);
    } catch (e) {
      Get.back();
      print("Final registration error: $e");
      customDialog(s1: 'error'.tr, s2: 'registration_failed'.tr);
    }
  }

  // --- Fonctions utilitaires (inchangées) ---
  Future<void> getToken() async {
    final fcmToken = await firebaseMessaging.getToken();
    if (fcmToken != null) {
      token.value = fcmToken;
      print("FCM Token: ${token.value}");
    }
  }

  void resetForm() {
    name.value = "";
    email.value = "";
    phoneNumber.value = "";
    password.value = "";
    confirmPassword.value = "";
    age.value = "";
    gender.value = "";

    isNameError.value = false;
    isEmailError.value = false;
    isPhoneNumberError.value = false;
    isPassError.value = false;
    isAgeError.value = false;
    isGenderError.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    getToken();
  }
}
