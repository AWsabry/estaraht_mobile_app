import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show OtpType, PostgrestException, AuthException;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class OtpController extends GetxController {
  final supabase = SupabaseHelper().client;

  RxString otpCode = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isOtpError = false.obs;
  RxString errorMessage = ''.obs;

  // Timer variables
  Timer? _timer;
  final int _initialCountdown = 30;
  RxInt countdown = 0.obs;
  RxBool canResend = false.obs;

  // Data from previous screen
  String? targetEmail;
  String? targetPhone;
  OtpType otpPurpose;
  bool isPatient; // New flag to identify patient vs doctor
  String? expectedOtp; // Add expected OTP for custom validation
  String? otpId; // OTP record ID from database
  String? userId; // User ID for validation

  OtpController({
    this.targetEmail,
    this.targetPhone,
    required this.otpPurpose,
    this.isPatient = false, // Default to doctor
    this.expectedOtp, // Add expected OTP parameter
    this.otpId, // Add OTP ID parameter
    this.userId, // Add user ID parameter
  });

  @override
  void onInit() {
    super.onInit();

    // Retrieve arguments from Get.arguments to ensure values are properly set
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;

      // Update values from arguments if they were passed
      if (args.containsKey('email')) targetEmail = args['email'];
      if (args.containsKey('phone')) targetPhone = args['phone'];
      if (args.containsKey('otpPurpose')) otpPurpose = args['otpPurpose'];
      if (args.containsKey('isPatient')) isPatient = args['isPatient'];
      if (args.containsKey('expectedOtp')) expectedOtp = args['expectedOtp'];
      if (args.containsKey('otpId')) otpId = args['otpId'];
      if (args.containsKey('userId')) userId = args['userId'];

      // Debug logging to verify values are set
      print('✅ OTP Controller initialized with:');
      print('   📋 OTP ID: $otpId');
      print('   📋 User ID: $userId');
      print('   📋 Expected OTP: $expectedOtp');
      print('   📋 Email: $targetEmail');
      print('   📋 Phone: $targetPhone');
      print('   📋 Is Patient: $isPatient');
    }

    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    canResend.value = false;
    countdown.value = _initialCountdown;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> verifyOtp() async {
    if (otpCode.value.length != 6) {
      isOtpError.value = true;
      errorMessage.value = 'enter_6_digits_otp'.tr;
      return;
    }

    isLoading.value = true;
    isOtpError.value = false;
    errorMessage.value = '';

    // Debug logging
    print('🔍 Starting OTP verification...');
    print('📋 OTP ID: $otpId');
    print('📋 User ID: $userId');
    print('📋 Expected OTP: $expectedOtp');
    print('📋 User Input: ${otpCode.value}');
    print('📋 Is Patient: $isPatient');

    try {
      // Check if we have an OTP ID (database-based validation for patients)
      if (otpId != null && userId != null) {
        print('🔍 Using database validation - ID: $otpId, User: $userId');

        // Fetch OTP record from database with more detailed error handling
        final otpRecords = await supabase
            .from('otp_codes')
            .select()
            .eq('user_id', userId!)
            .eq('is_used', false);

        print('📊 Found ${otpRecords.length} OTP records');

        if (otpRecords.isEmpty) {
          print('❌ No valid OTP record found');
          isOtpError.value = true;
          errorMessage.value = 'invalid_otp_or_used'.tr;
          isLoading.value = false;
          return;
        }

        final otpRecord = otpRecords.first;
        print('🔍 Database OTP Code: ${otpRecord['otp_code']}');
        print('🔍 User Input: ${otpCode.value}');

        // Check if OTP codes match
        if (otpRecord['otp_code'] != otpCode.value) {
          print('❌ OTP codes do not match');
          isOtpError.value = true;
          errorMessage.value = 'invalid_otp_code'.tr;
          isLoading.value = false;
          return;
        }

        // Check if OTP has expired
        final expiresAt = DateTime.parse(otpRecord['expires_at']);
        final now = TimezoneService.getCurrentMauritaniaTime();

        print('⏰ OTP expires at: $expiresAt');
        print('⏰ Current time: $now');
        print('⏰ Is expired: ${now.isAfter(expiresAt)}');

        if (now.isAfter(expiresAt)) {
          print('❌ OTP has expired');
          isOtpError.value = true;
          errorMessage.value = 'otp_expired'.tr;
          isLoading.value = false;
          return;
        }

        // Mark OTP as used
        await supabase
            .from('otp_codes')
            .update({'is_used': true, 'used_at': now.toIso8601String()})
            .eq('id', otpId!);

        print('✅ OTP validation successful - marked as used');
        print('🚀 Starting finalization process...');

        // Get current Firebase user
        final currentUser = firebaseHelper.currentUser;
        print('👤 Current user: ${currentUser?.uid}');

        if (currentUser != null) {
          try {
            if (isPatient) {
              print('🏥 Calling patient finalization...');
              await Get.find<RegisterPatientController>().finalizeRegistration(
                currentUser,
              );
              print('✅ Patient finalization completed');
            } else {
              print('👨‍⚕️ Calling doctor finalization...');
              await Get.find<DoctorRegisterController>().finalizeRegistration(
                currentUser,
              );
              print('✅ Doctor finalization completed');
            }
          } catch (finalizationError) {
            print('❌ Finalization error: $finalizationError');
            print('Stack trace: ${StackTrace.current}');
            rethrow; // Re-throw to be caught by outer catch
          }
        } else {
          print('❌ Current user is null!');
          throw Exception('User not found after registration');
        }
      } else if (expectedOtp != null && expectedOtp!.isNotEmpty) {
        // Fallback to custom OTP validation (backwards compatibility)
        print(
          '🔍 Using custom OTP validation: ${otpCode.value} vs $expectedOtp',
        );

        if (otpCode.value == expectedOtp) {
          print('✅ Custom OTP validation successful');
          print('🚀 Starting finalization process...');

          final currentUser = firebaseHelper.currentUser;
          print('👤 Current user: ${currentUser?.uid}');

          if (currentUser != null) {
            try {
              if (isPatient) {
                print('🏥 Calling patient finalization...');
                await Get.find<RegisterPatientController>()
                    .finalizeRegistration(currentUser);
                print('✅ Patient finalization completed');
              } else {
                print('👨‍⚕️ Calling doctor finalization...');
                await Get.find<DoctorRegisterController>().finalizeRegistration(
                  currentUser,
                );
                print('✅ Doctor finalization completed');
              }
            } catch (finalizationError) {
              print('❌ Finalization error: $finalizationError');
              print('Stack trace: ${StackTrace.current}');
              rethrow; // Re-throw to be caught by outer catch
            }
          } else {
            print('❌ Current user is null!');
            throw Exception('User not found after registration');
          }
        } else {
          print('❌ Custom OTP validation failed');
          isOtpError.value = true;
          errorMessage.value = 'invalid_or_expired_otp'.tr;
          isLoading.value = false;
          return;
        }
      } else {
        // For cases without database OTP, verify directly through Firebase
        // This is mainly for backward compatibility
        print('🔍 Using fallback validation - checking Firebase user');

        final currentUser = firebaseHelper.currentUser;

        if (currentUser != null) {
          print('✅ Firebase user found, proceeding with finalization');
          print('🚀 Starting finalization process...');

          try {
            if (isPatient) {
              print('🏥 Calling patient finalization...');
              await Get.find<RegisterPatientController>().finalizeRegistration(
                currentUser,
              );
              print('✅ Patient finalization completed');
            } else {
              print('👨‍⚕️ Calling doctor finalization...');
              await Get.find<DoctorRegisterController>().finalizeRegistration(
                currentUser,
              );
              print('✅ Doctor finalization completed');
            }
          } catch (finalizationError) {
            print('❌ Finalization error: $finalizationError');
            print('Stack trace: ${StackTrace.current}');
            rethrow; // Re-throw to be caught by outer catch
          }
        } else {
          isOtpError.value = true;
          errorMessage.value = 'invalid_or_expired_otp'.tr;
          isLoading.value = false;
          return;
        }
      }

      // If we got here, everything succeeded
      isLoading.value = false;
      print('🎉 OTP verification and finalization completed successfully!');
    } on PostgrestException catch (e) {
      isLoading.value = false;
      isOtpError.value = true;
      errorMessage.value = 'database_error'.tr;
      print("❌ PostgrestException during OTP verification: ${e.message}");
      print("Details: ${e.details}");
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      isOtpError.value = true;
      errorMessage.value = 'authentication_error'.tr;
      print("❌ FirebaseAuthException during OTP verification: ${e.message}");
    } catch (e, stackTrace) {
      isLoading.value = false;
      isOtpError.value = true;
      errorMessage.value = 'an_unexpected_error_occurred'.tr;
      print("❌ Unexpected error during OTP verification: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> resendOtp() async {
    if (!canResend.value) return;

    isLoading.value = true;
    isOtpError.value = false;
    errorMessage.value = '';

    try {
      // If we have database-based OTP (for patients), generate and save new OTP
      if (otpId != null && userId != null && isPatient) {
        // Generate new OTP code
        final newOtpCode = _generateOTP();
        print('🔐 Generated new OTP Code: $newOtpCode');

        // Mark old OTP as expired/used
        await supabase
            .from('otp_codes')
            .update({
              'is_used': true,
              'used_at': TimezoneService.getCurrentMauritaniaTime().toIso8601String(),
            })
            .eq('id', otpId!);

        // Create new OTP record
        final newOtpRecord = await supabase
            .from('otp_codes')
            .insert({
              'user_id': userId!,
              'email': targetEmail,
              'otp_code': newOtpCode,
              'expires_at': TimezoneService.getCurrentMauritaniaTime()
                  .add(const Duration(minutes: 5))
                  .toIso8601String(),
              'is_used': false,
              'created_at': TimezoneService.getCurrentMauritaniaTime().toIso8601String(),
            })
            .select()
            .single();

        // Update current otpId for validation
        otpId = newOtpRecord['id'];
        print('💾 New OTP saved to database with ID: $otpId');

        // Send new OTP via email
        try {
          String userName = Get.find<RegisterPatientController>().name.value;
          await EmailService.sendOtpEmail(
            to: targetEmail!,
            otpCode: newOtpCode,
            userName: userName,
          );
          print('✅ New OTP email sent successfully with code: $newOtpCode');
        } catch (e) {
          print('⚠️ Gmail notification failed: $e');
        }
      } else {
        // Use Supabase's built-in resend for doctors or other cases
        if (targetEmail != null && targetEmail!.isNotEmpty) {
          await supabase.auth.resend(email: targetEmail!, type: otpPurpose);

          // Send OTP notification via Gmail
          try {
            String userName = isPatient
                ? Get.find<RegisterPatientController>().name.value
                : Get.find<DoctorRegisterController>().name.value;

            await EmailService.sendOtpEmail(
              to: targetEmail!,
              otpCode: '******', // Supabase sends actual OTP
              userName: userName,
            );
            print('✅ OTP resend notification sent via Gmail');
          } catch (e) {
            print('⚠️ Gmail notification failed but OTP was resent: $e');
          }
        } else if (targetPhone != null && targetPhone!.isNotEmpty) {
          await supabase.auth.resend(phone: targetPhone!, type: otpPurpose);
        } else {
          throw Exception('email_or_phone_not_provided'.tr);
        }
      }

      Get.snackbar(
        'success_str'.tr,
        'a_new_code_has_been_sent'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      startTimer();
    } on PostgrestException catch (e) {
      print('❌ Database error during resend: ${e.message}');
      Get.snackbar(
        'error'.tr,
        'failed_to_resend_otp'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      Get.snackbar('error'.tr, 'failed_to_resend_otp'.tr, snackPosition: SnackPosition.BOTTOM);
      print("Supabase Resend OTP Error: ${e.message}");
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'an_unexpected_error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      print("Unexpected error: $e");
    } finally {
      isLoading.value = false;
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
}
