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

  // Doctor-specific fields
  RxBool isDoctor = false.obs;
  RxString yearsOfExperience = ''.obs;
  RxString specialization = ''.obs;
  RxInt numbPatients = 0.obs;
  RxInt numbSessions = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Check if user is doctor
    isDoctor.value =
        StorageService.readData(key: LocalStorageKeys.isLoggedInAsDoctor) ??
        false;
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

      if (isDoctor.value) {
        // Fetch doctor profile from Supabase
        try {
          final response = await supabase
              .from('doctors')
              .select('''
                doctor_id,
                full_name,
                email,
                phone_number,
                age,
                gender,
                specialization,
                years_of_exp,
                numb_patients,
                numb_session,
                profile_img_url
              ''')
              .eq('doctor_id', user.uid)
              .single();

          profileImageUrl.value = response['profile_img_url']?.toString() ?? '';
          userName.value = response['full_name']?.toString() ?? '';
          userEmail.value = response['email']?.toString() ?? '';
          userPhone.value = response['phone_number']?.toString() ?? '';
          userAge.value = response['age']?.toString() ?? '';
          userGender.value = response['gender']?.toString() ?? '';
          yearsOfExperience.value = response['years_of_exp']?.toString() ?? '0';
          specialization.value = response['specialization']?.toString() ?? '';
          numbPatients.value = response['numb_patients'] as int? ?? 0;
          numbSessions.value = response['numb_session'] as int? ?? 0;
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
        }
      } else {
        // Fetch patient profile from Supabase
        try {
          final response = await supabase
              .from('patients')
              .select()
              .eq('id', user.uid)
              .single();

          profileImageUrl.value = response['profile_img_url']?.toString() ?? '';
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
        }
      }
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

      if (isDoctor.value) {
        // For doctors, use numb_session from doctor profile
        // It's already loaded in loadUserProfile
        sessionCount.value = numbSessions.value;
      } else {
        // Fetch session count from Supabase for patients
        final value = await supabase
            .from('bookings')
            .select()
            .eq('patient_id', user.uid);

        sessionCount.value = value.length;
      }
    } catch (e) {
      // If error, set to 0
      sessionCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }
}
