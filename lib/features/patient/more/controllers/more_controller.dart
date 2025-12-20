import 'package:videocalling/core/config/app_imports.dart';

class PatientMoreScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  // Updated menu items for the modern design
  List<Map<String, dynamic>> settingsOptions = [
    {
      'icon': Icons.medical_information_outlined,
      'title': 'manage_medical_record',
      'route': Routes.specialityScreen,
    },
    {
      'icon': Icons.payment_outlined,
      'title': 'payment_settings',
      'route': null, // Add appropriate route
    },
    {
      'icon': Icons.language_outlined,
      'title': 'language_settings',
      'route': null, // Handled with dialog
    },
    {
      'icon': Icons.logout_outlined,
      'title': 'sign_out',
      'route': null, // Handled with dialog
    },
  ];

  RxString userId = "".obs;
  RxString name = "".obs;
  RxString email = "".obs;
  RxString profileImage = "".obs;
  RxBool isLoaded = false.obs;
  RxBool isLoggedIn = false.obs;
  RxString currentLanguage = 'en'.obs;

  initialize() async {
    isLoaded.value = false;

    isLoggedIn.value =
        StorageService.readData(key: LocalStorageKeys.isLoggedIn) ?? false;
    userId.value = StorageService.readData(key: LocalStorageKeys.userId) ?? "";
    name.value = StorageService.readData(key: LocalStorageKeys.name) ?? "";
    email.value = StorageService.readData(key: LocalStorageKeys.email) ?? "";
    profileImage.value =
        StorageService.readData(key: LocalStorageKeys.profileImage) ?? "";

    // Get current language
    final box = GetStorage();
    currentLanguage.value = box.read('language') ?? 'en';

    isLoaded.value = true;
  }
}
