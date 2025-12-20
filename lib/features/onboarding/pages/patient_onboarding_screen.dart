import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PatientOnboardingScreen extends StatelessWidget {
  const PatientOnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the language controller to determine font family
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,

      // Add AppBar with back button to allow navigation back to role selection
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo - Using Hero animation for smooth transition
                    Hero(
                      tag: 'app_logo',
                      child: SvgPicture.asset(
                        AppImages.splashIcon,
                        height: 40,
                        color: const Color(
                          0xFF204FCF,
                        ), // Blue color for the logo
                      ),
                    ),
                    SizedBox(height: 62.h),

                    // Main heading with translation keys
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: isArabic
                              ? 24.sp
                              : 28.sp, // Adjust size based on language
                          color: Colors.black,
                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        ),
                        children: [
                          TextSpan(
                            text: "connect_with_therapist".tr,
                            style: const TextStyle(fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: "start_your_journey".tr,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 23.h),

                    // Subtext with translation key
                    Text(
                      "healing_starts_here".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        // height: 1.8,
                      ),
                    ),

                    SizedBox(height: 62.h),

                    // Login button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Mark onboarding as complete
                          StorageService.writeBoolData(
                            key: LocalStorageKeys.hasSeenOnboarding,
                            value: true,
                          );
                          // Navigate to patient login
                          Get.offAllNamed(
                            Routes.loginUserScreen,
                            arguments: {'isFromOnboarding': true},
                          );
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

                    // Sign up button
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Mark onboarding as complete
                          StorageService.writeBoolData(
                            key: LocalStorageKeys.hasSeenOnboarding,
                            value: true,
                          );
                          // Navigate to patient signup
                          Get.offAllNamed(
                            Routes.patientRegisterScreen,
                            arguments: {'isFromOnboarding': true},
                          );

                          // Navigate to patient signup
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF204FCF,
                          ), // Match the blue in the image
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
