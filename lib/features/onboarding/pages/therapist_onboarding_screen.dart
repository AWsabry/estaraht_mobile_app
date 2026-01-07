import 'package:videocalling/core/config/app_imports.dart';

class TherapistOnboardingScreen extends StatelessWidget {
  const TherapistOnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final languageController = Get.find<LanguageController>();
    // final bool isArabic = languageController.currentLanguage.value == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Logo - Using Hero animation for smooth transition
                    Hero(
                      tag: 'app_logo',
                      child: SvgPicture.asset(
                        AppImages.splashIcon,
                        height: 40,
                        color: const Color(0xFF204FCF),

                        /// Blue color for the logo
                      ),
                    ),
                    const SizedBox(height: 78),

                    /// Main heading - split into parts for better text styling
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.black,
                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        ),
                        children: [
                          TextSpan(
                            text: "${"help_your_patients".tr} ",
                            style: const TextStyle(fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: "your_appointments_just".tr,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Subtext
                    Text(
                      "manage_your_appointments_easily".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 46),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          StorageService.writeBoolData(
                            key: LocalStorageKeys.hasSeenOnboarding,
                            value: true,
                          );
                          Get.off(() => LoginAsDoctor());
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          "login".tr,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          StorageService.writeBoolData(
                            key: LocalStorageKeys.hasSeenOnboarding,
                            value: true,
                          );
                          Get.offAllNamed(Routes.doctorRegisterScreen);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF204FCF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0, // No shadow
                        ),
                        child: Text(
                          "sign_up".tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
