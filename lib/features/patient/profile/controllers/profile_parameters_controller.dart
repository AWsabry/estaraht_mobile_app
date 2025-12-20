import 'package:videocalling/core/config/app_imports.dart';

class ProfileParametersController extends GetxController {
  final supabase = supabaseHelper;

  // Observable for profile image URL
  RxString profileImageUrl =
      'https://media.istockphoto.com/id/1331281439/photo/cheerful-young-woman-in-white-t-shirt.jpg?s=612x612&w=0&k=20&c=kctE1SBfFR43rbst2Z4sxElTj1wvtDgAoqFwGJWNZoU='
          .obs;
  RxString userName = ''.obs;
  RxString userRole = ''.obs;
  RxInt sessionCount = 0.obs;
  RxBool isLoading = false.obs;
  RxString userOcupation = ''.obs;
  RxString userBio = ''.obs;

  // Active tab index (0 = Bio, 1 = Medical File)
  RxInt activeTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadSessionCounts();
  }

  /// Change active tab
  void changeTab(int index) {
    activeTabIndex.value = index;
  }

  /// Load user profile data from Supabase
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;

      final user = firebaseHelper.currentUser;
      if (user == null) {
        // Load from local storage if available
        profileImageUrl.value =
            StorageService.readData(key: LocalStorageKeys.profileImage) ??
            'https://media.istockphoto.com/id/1331281439/photo/cheerful-young-woman-in-white-t-shirt.jpg?s=612x612&w=0&k=20&c=kctE1SBfFR43rbst2Z4sxElTj1wvtDgAoqFwGJWNZoU=';
        userName.value =
            StorageService.readData(key: LocalStorageKeys.name) ?? '';
        return;
      }

      // Fetch patient profile from Supabase
      final response = await supabase
          .from('patients')
          .select()
          .eq('id', user.uid)
          .single();

      profileImageUrl.value = response['profile_pic'] ?? '';
      userName.value = response['name'] ?? '';
      // Add other fields as needed
    } catch (e) {
      // If error, try to load from local storage
      profileImageUrl.value =
          StorageService.readData(key: LocalStorageKeys.profileImage) ?? '';
      userName.value =
          StorageService.readData(key: LocalStorageKeys.name) ?? '';
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
