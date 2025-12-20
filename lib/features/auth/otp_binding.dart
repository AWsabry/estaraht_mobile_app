import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;

import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/auth/controllers/otp_controller.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    // Get arguments from the route
    final args = Get.arguments as Map<String, dynamic>?;

    Get.lazyPut<OtpController>(
      () => OtpController(
        targetEmail: args?['email'],
        targetPhone: args?['phone'],
        otpPurpose: args?['otpPurpose'] ?? OtpType.signup,
        isPatient: args?['isPatient'] ?? false,
      ),
    );
  }
}
