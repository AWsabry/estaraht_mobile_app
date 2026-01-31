import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/config/app_imports.dart';

class ReviewStatusController extends GetxController {
  // Supabase client instance
  SupabaseClient get supabase => supabaseHelper.client;

  // Observable variables
  RxString approvalStatus = 'pending'.obs;
  RxString doctorName = ''.obs;
  RxString doctorEmail = ''.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDoctorInfo();
  }

  /// Load doctor information from local storage and Supabase
  Future<void> _loadDoctorInfo() async {
    try {
      doctorName.value = StorageService.readData(key: LocalStorageKeys.name) ?? '';
      doctorEmail.value = StorageService.readData(key: LocalStorageKeys.email) ?? '';

      // Fetch current approval status
      await checkApprovalStatus();
    } catch (e) {
      loggerNoStack.e('Error loading doctor info: $e');
    }
  }

  /// Check the current approval status of the doctor
  Future<void> checkApprovalStatus({bool showSnackbar = false}) async {
    try {
      isLoading.value = true;

      final userId = StorageService.readData(key: LocalStorageKeys.userId);

      // Fetch doctor data from Supabase
      final doctorData = await supabase
          .from('doctors')
          .select('approval_status, full_name, email, rejection_reason')
          .eq('doctor_id', userId)
          .single();

      final String status = doctorData['approval_status'] ?? 'pending';
      approvalStatus.value = status;

      // Update local info if available
      if (doctorData['full_name'] != null) {
        doctorName.value = doctorData['full_name'];
      }
      if (doctorData['email'] != null) {
        doctorEmail.value = doctorData['email'];
      }

      // Handle different statuses
      if (status == 'approved') {
        if (showSnackbar) {
          customSnackbar(
            title: 'approved'.tr,
            message: 'account_approved_message'.tr,
            type: SnackbarType.success,
          );
        }
        // Navigate to doctor dashboard
        Get.offAllNamed(Routes.doctorTabScreen);
      } else if (status == 'rejected') {
        // Navigate to rejection screen with reason
        final rejectionReason = doctorData['rejection_reason'];
        // TODO: Update this route after adding it to Routes class
        Get.offAllNamed(
          '/account-rejected',
          arguments: rejectionReason,
        );
      } else {
        if (showSnackbar) {
          customSnackbar(
            title: 'status_unchanged'.tr,
            message: 'still_under_review'.tr,
            type: SnackbarType.info,
          );
        }
      }
    } catch (e) {
      loggerNoStack.e('Error checking approval status: $e');
      if (showSnackbar) {
        customSnackbar(
          title: 'error'.tr,
          message: 'unable_to_check_status'.tr,
          type: SnackbarType.error,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout and return to login screen
  Future<void> logout() async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('logout'.tr),
          content: Text('logout_confirmation'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('logout'.tr),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Clear local storage
      StorageService.clearAllStorage();

      // Sign out from Firebase
      await firebaseHelper.signOut();

      // Navigate to login screen
      Get.offAllNamed(Routes.doctorLoginScreen);
    } catch (e) {
      loggerNoStack.e('Error during logout: $e');
      customSnackbar(
        title: 'error'.tr,
        message: 'logout_error'.tr,
        type: SnackbarType.error,
      );
    }
  }

  /// Contact support (placeholder - can be implemented later)
  void contactSupport() {
    customSnackbar(
      title: 'support'.tr,
      message: 'support_contact_message'.tr,
      type: SnackbarType.info,
    );
    // TODO: Implement contact support functionality
    // This could open email client, in-app chat, or phone dialer
  }
}

/// Binding for ReviewStatusController
class ReviewStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewStatusController>(() => ReviewStatusController());
  }
}

/// Custom snackbar helper
void customSnackbar({
  required String title,
  required String message,
  SnackbarType type = SnackbarType.info,
}) {
  Color backgroundColor;
  IconData icon;

  switch (type) {
    case SnackbarType.success:
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case SnackbarType.error:
      backgroundColor = Colors.red;
      icon = Icons.error;
      break;
    case SnackbarType.warning:
      backgroundColor = Colors.orange;
      icon = Icons.warning;
      break;
    case SnackbarType.info:
      backgroundColor = Colors.blue;
      icon = Icons.info;
      break;
  }

  Get.snackbar(
    title,
    message,
    backgroundColor: backgroundColor,
    colorText: Colors.white,
    icon: Icon(icon, color: Colors.white),
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(10),
  );
}

enum SnackbarType {
  success,
  error,
  warning,
  info,
}
