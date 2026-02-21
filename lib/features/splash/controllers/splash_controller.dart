import 'package:logger/web.dart';
import 'package:videocalling/core/config/app_imports.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print('Splash controller initialized');
    checkUserStatus();
  }

  void checkUserStatus() {
    Timer(const Duration(seconds: 3), () async {
      // Navigate based on user status (flavor-aware: only honor login for current app type)
      if (StorageService.readData(key: LocalStorageKeys.isLoggedIn) == true) {
        bool isDoctor =
            StorageService.readData(key: LocalStorageKeys.isLoggedInAsDoctor) ??
                false;
        // In patient app, only proceed to home if logged in as patient
        if (isPatientApp && !isDoctor) {
          Get.offAllNamed(Routes.userTabScreen);
          return;
        }
        // In doctor app, only proceed to doctor flow if logged in as doctor
        if (isDoctorApp && isDoctor) {
          await _checkDoctorApprovalStatus();
          return;
        }
        // Wrong app for this login (e.g. patient app open but stored as doctor) -> go to onboarding
      }

      // Not logged in (or wrong app): language then role-specific onboarding
      final box = GetStorage();
        final appLang = box.read('app_language') == null;
        Logger().i('appLang: $appLang');
        if (appLang) {
          Get.offAllNamed(Routes.languageSelectionScreen);
          return;
        }
        // Flavor-aware: go directly to role-specific onboarding (no role selection)
        if (isPatientApp) {
          Get.offAllNamed(Routes.patientOnboardingScreen);
        } else {
          Get.offAllNamed(Routes.therapistOnboardingScreen);
        }
    });
  }

  /// Check doctor's approval status and navigate accordingly
  Future<void> _checkDoctorApprovalStatus() async {
    try {
      final userId = StorageService.readData(key: LocalStorageKeys.userId);

      if (userId == null || userId.isEmpty) {
        // No user ID, navigate to login
        Get.offAllNamed(Routes.doctorLoginScreen);
        return;
      }

      // Fetch doctor approval status from Supabase
      final doctorData = await supabaseHelper.client
          .from('doctors')
          .select('approval_status')
          .eq('doctor_id', userId)
          .single();

      final String approvalStatus =
          doctorData['approval_status'] ?? 'pending';
      print('👨‍⚕️ Doctor approval status on splash: $approvalStatus');

      if (approvalStatus == 'pending') {
        Get.offAllNamed(Routes.underReviewScreen);
      } else if (approvalStatus == 'approved') {
        Get.offAllNamed(Routes.doctorTabScreen);
      } else if (approvalStatus == 'rejected') {
        final rejectionReason = doctorData['rejection_reason'];
        Get.offAllNamed(
          '/account-rejected',
          arguments: rejectionReason,
        );
      } else {
        // Unknown status, fallback to login
        Get.offAllNamed(Routes.doctorLoginScreen);
      }
    } catch (e) {
      print('❌ Error checking doctor approval status: $e');
      // On error, fallback to doctor dashboard (assume approved)
      Get.offAllNamed(Routes.doctorTabScreen);
    }
  }
}
