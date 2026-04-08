import 'package:url_launcher/url_launcher.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/profile/models/doctor_profile_data.dart';

class DMoreInfoController extends GetxController {
  List<String> optionList = [
    'change_password_str'.tr,
    'subscription_str'.tr,
    'bank_details'.tr,
    'income_report_str'.tr,
    'logout_title'.tr,
  ];

  RxString doctorId = "".obs;
  RxBool isErrorInLoading = false.obs;
  RxBool isLoaded = false.obs;

  DoctorProfileWithRating? doctorProfileWithRating;

  Future<void> fetchDoctorDetails() async {
    isErrorInLoading.value = false;
    isLoaded.value = false;

    try {
      final supabase = SupabaseHelper().client;
      final response = await supabase
          .from('doctors') // adjust table name if different
          .select()
          .eq('doctorId', doctorId.value)
          .single();

      doctorProfileWithRating = DoctorProfileWithRating.fromJson(response);
      isLoaded.value = true;
    } catch (e) {
      loggerNoStack.e('Error fetching doctor details: $e');
      isErrorInLoading.value = true;
    } finally {
      isLoaded.value = true;

      try {
        final response = await supabaseHelper.client
            .from('doctors')
            .select()
            .eq('id', doctorId.value)
            .maybeSingle();
        if (response != null) {
          doctorProfileWithRating = DoctorProfileWithRating.fromJson(response);
          isLoaded.value = true;
        } else {
          isErrorInLoading.value = true;
        }
      } catch (e) {
        isErrorInLoading.value = true;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    doctorId.value = firebaseHelper.currentUser!.uid;
    fetchDoctorDetails();
  }

  /// Open a URL in the external browser (e.g. privacy policy, delete account page).
  Future<void> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'error'.tr,
          'error2'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error2'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
