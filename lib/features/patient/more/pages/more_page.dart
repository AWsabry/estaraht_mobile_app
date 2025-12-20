import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/video_call/video_call_imports.dart';

class MoreScreen extends GetView<PatientMoreScreenController> {
  final PatientMoreScreenController moreScreenController = Get.put(
    PatientMoreScreenController(),
  );

  // Track different screen states
  final RxBool showingLogoutConfirmation = false.obs;
  final RxBool showingLanguageSelection = false.obs;

  MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure LanguageController is registered
    if (!Get.isRegistered<LanguageController>()) {
      Get.put(LanguageController());
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Obx(() {
          if (showingLogoutConfirmation.value) {
            return const CustomAppBar(title: '');
          } else if (showingLanguageSelection.value) {
            return CustomAppBar(title: 'language_settings'.tr);
          } else {
            return CustomAppBar(title: 'settings'.tr);
          }
        }),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (!moreScreenController.isLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show the appropriate screen based on state
        if (showingLogoutConfirmation.value) {
          return _buildLogoutConfirmation(context);
        } else if (showingLanguageSelection.value) {
          return _buildLanguageSelectionScreen(context);
        } else {
          return _buildSettingsList();
        }
      }),
    );
  }

  Widget _buildSettingsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ListView(
        children: [
          // Medical Records
          _buildSettingsItem(
            icon: Icons.medical_information_outlined,
            title: 'manage_medical_record'.tr,
            onTap: () => Get.toNamed(Routes.editProfileScreen),
          ),

          // Payment Settings
          _buildSettingsItem(
            icon: Icons.payment_outlined,
            title: 'payment_settings'.tr,
            onTap: () {
              // Add payment settings navigation
            },
          ),

          // Language Settings
          _buildSettingsItem(
            icon: Icons.language_outlined,
            title: 'language_settings'.tr,
            onTap: () => showingLanguageSelection.value = true,
          ),

          // Sign Out
          _buildSettingsItem(
            icon: Icons.logout_outlined,
            title: 'sign_out'.tr,
            onTap: () {
              if (moreScreenController.isLoggedIn.value) {
                showingLogoutConfirmation.value = true;
              } else {
                Get.toNamed(
                  Routes.loginUserScreen,
                  arguments: {"isBack": false},
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Logout confirmation UI inside the same screen
  Widget _buildLogoutConfirmation(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Question text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'logout_confirmation'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(),

            // Logout icon - large and centered
            SizedBox(
              width: 160,
              height: 160,
              child: Icon(Icons.logout, size: 160, color: Colors.grey[300]),
            ),

            const SizedBox(height: 8),

            // Button row at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 120,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  // Yes button (outlined)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        showingLogoutConfirmation.value = false;
                        _performLogout();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        'yes'.tr,
                        style: TextStyle(
                          fontSize: Get.locale?.languageCode == 'ar' ? 13 : 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // No button (filled blue)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => showingLogoutConfirmation.value = false,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3961F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        'no'.tr,
                        style: TextStyle(
                          fontSize: Get.locale?.languageCode == 'ar' ? 13 : 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Language selection screen with smaller elements and confirmation button
  Widget _buildLanguageSelectionScreen(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    // Track selected language for confirmation button
    RxString selectedLang = RxString(languageController.currentLanguage.value);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Language icon
                  Center(
                    child: SizedBox(
                      width: 80, // Smaller container
                      height: 80, // Smaller container
                      child: Icon(
                        Icons.language,
                        size: 80, // Smaller icon
                        color: Colors.grey[300],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), // Reduced spacing
                  // Instruction text
                  Center(
                    child: Text(
                      'select_your_language'.tr,
                      style: const TextStyle(
                        fontSize: 18, // Smaller text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), // Reduced spacing
                  // Language options
                  Obx(
                    () => _buildLanguageOption(
                      title: 'العربية',
                      isSelected: selectedLang.value == 'ar',
                      onTap: () => selectedLang.value = 'ar',
                    ),
                  ),

                  const SizedBox(height: 10), // Reduced spacing

                  Obx(
                    () => _buildLanguageOption(
                      title: 'English',
                      isSelected: selectedLang.value == 'en',
                      onTap: () => selectedLang.value = 'en',
                    ),
                  ),

                  const SizedBox(height: 10), // Reduced spacing

                  Obx(
                    () => _buildLanguageOption(
                      title: 'Français',
                      isSelected: selectedLang.value == 'fr',
                      onTap: () => selectedLang.value = 'fr',
                    ),
                  ),

                  const Spacer(),

                  // Button row with both cancel and confirm
                  Row(
                    children: [
                      const SizedBox(width: 26),
                      // Cancel button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              showingLanguageSelection.value = false,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ), // Smaller padding
                          ),
                          child: Text(
                            'cancel'.tr,
                            style: TextStyle(
                              fontSize: Get.locale?.languageCode == 'ar'
                                  ? 13
                                  : 14, // Smaller text
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Confirm button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Apply the selected language
                            languageController.changeLanguage(
                              selectedLang.value,
                            );
                            showingLanguageSelection.value = false;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3961F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ), // Smaller padding
                          ),
                          child: Text(
                            'confirm'.tr,
                            style: TextStyle(
                              // Smaller text
                              color: Colors.white,
                              fontSize: Get.locale?.languageCode == 'ar'
                                  ? 13
                                  : 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 26),
                    ],
                  ),
                  const SizedBox(height: 20), // Reduced bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a language option with smaller text and padding
  Widget _buildLanguageOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ), // Reduced padding
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3961F1).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF3961F1) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16, // Smaller text
                  color: isSelected ? const Color(0xFF3961F1) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3961F1),
                size: 20, // Smaller icon
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.centerLeft,
                  child: Icon(icon, size: 24, color: Colors.black87),
                ),
                Get.locale?.languageCode == 'ar'
                    ? const SizedBox(width: 8)
                    : const SizedBox(width: 0),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: Get.locale?.languageCode == 'ar' ? 15.0 : 16.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: Colors.grey[600]),
      ],
    );
  }

  // Extracted logout method for better organization
  void _performLogout() async {
    // Show loading dialog
    customDialog1(
      s1: 'logout_loading_title'.tr,
      s2: 'logout_loading_description'.tr,
    );

    // Cleanup all connections and user state
    try {
      CallManager.instance.destroy();
      CubeChatConnection.instance.destroy();
      await PushNotificationsManager.instance.unsubscribe();
      await SharedPrefs.deleteUserData();
      await signOut();
    } catch (e) {
      print('Logout cleanup error: $e');
    }

    // Clear user data but preserve token
    StorageService.writeBoolData(
      key: LocalStorageKeys.isLoggedIn,
      value: false,
    );
    StorageService.writeBoolData(
      key: LocalStorageKeys.isLoggedInAsDoctor,
      value: false,
    );

    // Save token before erasing everything
    String? token = StorageService.readData(key: LocalStorageKeys.token);
    box.erase();

    // Restore token after erasure
    if (token != null) {
      StorageService.writeBoolData(
        key: LocalStorageKeys.isTokenExist,
        value: true,
      );
      StorageService.writeStringData(key: LocalStorageKeys.token, value: token);
    }

    // Close loading dialog and navigate to role selection
    Get.back();
    Get.offAllNamed(Routes.patientOnboardingScreen);
  }
}
