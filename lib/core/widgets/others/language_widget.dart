import 'package:videocalling/core/config/app_imports.dart';

class LanguageSelectionComponent extends StatelessWidget {
  final Function(String)? onLanguageSelected;
  final bool isFromSettings;
  final Color primaryColor;

  const LanguageSelectionComponent({
    Key? key,
    this.onLanguageSelected,
    this.isFromSettings = false,
    this.primaryColor = const Color(0xFF204FCF), // Default to blue
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get language controller directly from GetX
    final languageController = Get.find<LanguageController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFromSettings) ...[
          const Text(
            "اختر لغة التطبيق",
            style: CustomTextStyle(
              fontSize: 16, // Smaller for Arabic
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoKufiArabic',
            ),
          ),
          const SizedBox(height: 20),
        ],
        // Arabic option
        Obx(
          () => LanguageOption(
            language: "العربية",
            languageCode: "ar",
            primaryColor: primaryColor, // Pass the color
            // When on selection screen, use tempSelectedLanguage, otherwise use currentLanguage
            isSelected: isFromSettings
                ? languageController.currentLanguage.value == "ar"
                : languageController.tempSelectedLanguage.value == "ar",
            onTap: () {
              if (isFromSettings) {
                // In settings, apply immediately
                languageController.changeLanguage("ar");
              } else {
                // On selection screen, just mark as selected
                languageController.tempSelectLanguage("ar");
              }
              if (onLanguageSelected != null) {
                onLanguageSelected!("ar");
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        // English option
        Obx(
          () => LanguageOption(
            language: "English",
            languageCode: "en",
            primaryColor: primaryColor, // Pass the color
            // When on selection screen, use tempSelectedLanguage, otherwise use currentLanguage
            isSelected: isFromSettings
                ? languageController.currentLanguage.value == "en"
                : languageController.tempSelectedLanguage.value == "en",
            onTap: () {
              if (isFromSettings) {
                // In settings, apply immediately
                languageController.changeLanguage("en");
              } else {
                // On selection screen, just mark as selected
                languageController.tempSelectLanguage("en");
              }
              if (onLanguageSelected != null) {
                onLanguageSelected!("en");
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        // French option
        Obx(
          () => LanguageOption(
            language: "Français",
            languageCode: "fr",
            primaryColor: primaryColor, // Pass the color
            // When on selection screen, use tempSelectedLanguage, otherwise use currentLanguage
            isSelected: isFromSettings
                ? languageController.currentLanguage.value == "fr"
                : languageController.tempSelectedLanguage.value == "fr",
            onTap: () {
              if (isFromSettings) {
                // In settings, apply immediately
                languageController.changeLanguage("fr");
              } else {
                // On selection screen, just mark as selected
                languageController.tempSelectLanguage("fr");
              }
              if (onLanguageSelected != null) {
                onLanguageSelected!("fr");
              }
            },
          ),
        ),
      ],
    );
  }
}

class LanguageOption extends StatelessWidget {
  final String language;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const LanguageOption({
    Key? key,
    required this.language,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
    this.primaryColor = const Color(0xFF204FCF), // Default to blue
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isArabic = languageCode == 'ar';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? primaryColor.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Text(
              language,
              style: CustomTextStyle(
                fontSize: isArabic ? 14 : 16, // Smaller font for Arabic
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : null,
                // Use the appropriate font family based on the language
                fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check, color: primaryColor, size: 20)
            else
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
