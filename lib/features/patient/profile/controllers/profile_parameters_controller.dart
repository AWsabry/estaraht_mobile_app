import 'package:videocalling/core/config/app_imports.dart';

class ProfileParametersController extends GetxController {
  final supabase = supabaseHelper;

  // Observable for profile image URL
  RxString profileImageUrl = ''.obs;
  RxString userName = ''.obs;
  RxString userEmail = ''.obs;
  RxString userPhone = ''.obs;
  RxString userAge = ''.obs;
  RxString userGender = ''.obs;
  RxInt sessionCount = 0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadSessionCounts();
  }

  /// Load user profile data from Supabase
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;

      final user = firebaseHelper.currentUser;
      if (user == null) {
        // Load from local storage if available
        profileImageUrl.value =
            StorageService.readData(key: LocalStorageKeys.profileImage) ?? '';
        userName.value =
            StorageService.readData(key: LocalStorageKeys.name) ?? '';
        userEmail.value =
            StorageService.readData(key: LocalStorageKeys.email) ?? '';
        userPhone.value =
            StorageService.readData(key: LocalStorageKeys.phone) ?? '';
        return;
      }

      // Fetch patient profile from Supabase
      final response = await supabase
          .from('patients')
          .select()
          .eq('id', user.uid)
          .single();

      profileImageUrl.value = response['profile_pic']?.toString() ?? '';
      userName.value = response['name']?.toString() ?? '';
      userEmail.value = response['email']?.toString() ?? '';
      userPhone.value = response['phone']?.toString() ?? '';
      userAge.value = response['age']?.toString() ?? '';
      userGender.value = response['gender']?.toString() ?? '';
    } catch (e) {
      // If error, try to load from local storage
      profileImageUrl.value =
          StorageService.readData(key: LocalStorageKeys.profileImage) ?? '';
      userName.value =
          StorageService.readData(key: LocalStorageKeys.name) ?? '';
      userEmail.value =
          StorageService.readData(key: LocalStorageKeys.email) ?? '';
      userPhone.value =
          StorageService.readData(key: LocalStorageKeys.phone) ?? '';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSessionCounts() async {
    try {
      isLoading.value = true;

      final user = firebaseHelper.currentUser;
      if (user == null) {
        sessionCount.value = 0;
        return;
      }

      // Fetch session count from Supabase
      final value = await supabase
          .from('bookings')
          .select()
          .eq('patient_id', user.uid);

      sessionCount.value = value.length;
    } catch (e) {
      // If error, set to 0
      sessionCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }
}
