import 'package:videocalling/core/config/app_imports.dart';

class LanguageController extends GetxController {
  // Current applied language
  final RxString currentLanguage = "en".obs;

  // Temporarily selected language (for confirmation flow)
  final RxString tempSelectedLanguage = "".obs;

  // Whether a language has been selected
  final RxBool isLanguageSelected = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("LanguageController.onInit() called");
    // Load saved language when controller initializes
    loadSavedLanguage();
  }

  // Load the saved language from storage
  void loadSavedLanguage() {
    try {
      String? savedLanguage = StorageService.readData(
        key: LocalStorageKeys.appLanguage,
      );
      print("Loaded language from storage: $savedLanguage");

      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        currentLanguage.value = savedLanguage;
        tempSelectedLanguage.value = savedLanguage; // Initialize temp selection
        isLanguageSelected.value = true; // Mark as selected
        updateLocale(savedLanguage);
        print("Language set to: $savedLanguage");
      } else {
        print("No language saved, using default: ${currentLanguage.value}");
        tempSelectedLanguage.value = currentLanguage.value;
        isLanguageSelected.value = true; // Default language is selected
      }
    } catch (e) {
      print("Error loading language: $e");
    }
  }

  // Temporarily select a language (without applying it)
  void tempSelectLanguage(String languageCode) {
    tempSelectedLanguage.value = languageCode;
    isLanguageSelected.value = true;
    print("Language temporarily selected: $languageCode");
  }

  // Confirm and apply selected language
  void confirmLanguageSelection() {
    try {
      final selectedLang = tempSelectedLanguage.value;
      print("Confirming language selection: $selectedLang");

      // Only proceed if a language is selected
      if (selectedLang.isNotEmpty) {
        changeLanguage(selectedLang);
      }
    } catch (e) {
      print("Error confirming language selection: $e");
    }
  }

  // Change app language
  void changeLanguage(String languageCode) {
    try {
      print("Changing language to: $languageCode");
      currentLanguage.value = languageCode;
      saveLanguage(languageCode);
      updateLocale(languageCode);

      // Force UI refresh for font changes
      Get.forceAppUpdate();
      print("Language changed successfully to: $languageCode");
    } catch (e) {
      print("Error changing language: $e");
    }
  }

  // Update app locale
  void updateLocale(String languageCode) {
    Get.updateLocale(Locale(languageCode));
  }

  // Save language preference to storage
  void saveLanguage(String languageCode) {
    try {
      print("Saving language: $languageCode");
      StorageService.writeStringData(
        key: LocalStorageKeys.appLanguage,
        value: languageCode,
      );
      print("Language saved to storage");
    } catch (e) {
      print("Error saving language: $e");
    }
  }

  // Check if current language is RTL
  bool get isRtl => currentLanguage.value == 'ar';
}
