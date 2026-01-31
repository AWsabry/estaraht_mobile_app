import 'package:videocalling/core/config/app_imports.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get language controller
    final languageController = Get.find<LanguageController>();

    // Define the blue color once (same as splash screen)
    const Color primaryBlue = Color(0xFF204FCF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Test texts to verify fonts
              const Text(
                "Choose Your Language",
                style: CustomTextStyle(
                  fontSize: 24, // Slightly smaller
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "اختر لغتك المفضلة",
                style: CustomTextStyle(
                  fontSize: 20, // Smaller to match English visually
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoKufiArabic',
                ),
              ),
              const SizedBox(height: 30),

              // Language selection component with blue color passed
              LanguageSelectionComponent(
                primaryColor: primaryBlue,
                onLanguageSelected: (language) {
                  // Only store temporarily, don't navigate yet
                  languageController.tempSelectLanguage(language);
                },
              ),

              // Add spacer to push button to bottom
              const Spacer(),

              // Add confirm button
              Obx(() {
                // Get the button text based on selected language
                String buttonText = "confirm";

                // Use tempSelectedLanguage to determine button text language
                if (languageController.tempSelectedLanguage.value == "ar") {
                  buttonText = "تأكيد"; // Directly use Arabic text
                } else if (languageController.tempSelectedLanguage.value ==
                    "fr") {
                  buttonText = "Confirmer"; // Directly use French text
                } else {
                  buttonText = "Confirm"; // English text
                }

                // Update the ElevatedButton in your language selection screen:

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: languageController.isLanguageSelected.value
                        ? () {
                            // Apply the selected language
                            final selectedLang =
                                languageController.tempSelectedLanguage.value;

                            // Save and apply changes
                            languageController.confirmLanguageSelection();

                            // Navigate to role selection with transition
                            Get.toNamed(Routes.roleSelectionScreen);
                          }
                        : null, // Disable if no language selected
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue, // Use consistent blue
                      foregroundColor: Colors.white,
                      // Different padding based on language
                      padding:
                          languageController.tempSelectedLanguage.value == 'ar'
                          ? const EdgeInsets.symmetric(
                              vertical: 16,
                            ) // Reduced vertical padding for Arabic
                          : const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Force consistent height
                    ),
                    child: Text(
                      buttonText, // Use the appropriate text based on selection
                      style: CustomTextStyle(
                        fontSize:
                            languageController.tempSelectedLanguage.value ==
                                'ar'
                            ? 14
                            : 16, // Smaller for Arabic
                        fontWeight: FontWeight.w700,
                        fontFamily:
                            languageController.tempSelectedLanguage.value ==
                                'ar'
                            ? 'NotoKufiArabic'
                            : 'Roboto',
                        height:
                            languageController.tempSelectedLanguage.value ==
                                'ar'
                            ? 1.4 // Tighter line height for Arabic
                            : 1.2, // Normal line height for English
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
