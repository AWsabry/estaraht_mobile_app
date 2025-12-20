import 'package:videocalling/core/config/app_imports.dart';

class AppFontHelper {
  /// Returns the appropriate font family based on current language
  static String getFontFamily() {
    // Try-catch to handle potential errors during initialization
    try {
      final languageController = Get.find<LanguageController>();
      return languageController.currentLanguage.value == 'ar'
          ? 'NotoKufiArabic'
          : 'Roboto';
    } catch (e) {
      // Default to Roboto if LanguageController is not yet available
      return 'Roboto';
    }
  }

  /// Returns appropriate font weight based on style name
  static FontWeight getFontWeight(String styleName) {
    switch (styleName) {
      case 'bold':
        return FontWeight.w700;
      case 'black':
        return FontWeight.w900;
      case 'medium':
        return FontWeight.w500;
      case 'semiBold':
        return FontWeight.w600;
      case 'light':
        return FontWeight.w300;
      default:
        return FontWeight.w400; // regular
    }
  }
}
