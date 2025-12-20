import 'package:videocalling/core/config/app_imports.dart';
class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  final pages = 2; // We have 2 onboarding screens

  // Get role from arguments
  String get role => Get.arguments?['role'] ?? 'patient';

  @override
  void onInit() {
    super.onInit();
    // Initialize page controller
    pageController.addListener(() {
      int page = pageController.page?.round() ?? 0;
      if (currentPage.value != page) {
        currentPage.value = page;
      }
    });

    // Set initial page based on role
    if (role == 'doctor') {
      currentPage.value = 1;
      pageController.jumpToPage(1);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value < pages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  void navigateToLogin() {
    completeOnboarding();

    if (currentPage.value == 1) {
      // Doctor page
      // Navigate to doctor login
      Get.offAllNamed(Routes.doctorLoginScreen);
    } else {
      // Patient page
      // Navigate to patient login
      Get.offAllNamed(Routes.loginUserScreen);
    }
  }

  void navigateToSignUp() {
    completeOnboarding();

    if (currentPage.value == 1) {
      // Doctor page
      // Navigate to doctor signup
      Get.offAllNamed(Routes.doctorRegisterScreen);
    } else {
      // Patient page
      // Navigate to patient signup
      Get.offAllNamed(Routes.patientRegisterScreen);
    }
  }

  Future<void> completeOnboarding() async {
    // Use writeBoolData instead of saveData
    StorageService.writeBoolData(
        key: LocalStorageKeys.hasSeenOnboarding, value: true);
  }
}
