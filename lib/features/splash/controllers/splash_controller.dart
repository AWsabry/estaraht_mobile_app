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
      // Navigate based on user status
      if (StorageService.readData(key: LocalStorageKeys.isLoggedIn) == true) {
        bool isDoctor =
            StorageService.readData(key: LocalStorageKeys.isLoggedInAsDoctor) ??
                false;
        if (isDoctor) {
          // Check doctor approval status before navigating
          await _checkDoctorApprovalStatus();
        } else {
          Get.offAllNamed(Routes.userTabScreen);
        }
      } else {
        final box = GetStorage();
        final appLang = box.read('app_language') == null;
        Logger().i('appLang: $appLang');
        if (appLang) {
          Get.offAllNamed(Routes.languageSelectionScreen);
          return;
        }
        Get.offAllNamed(Routes.roleSelectionScreen);
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
