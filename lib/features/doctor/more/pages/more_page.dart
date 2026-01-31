import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/profile/pages/profile_view_page.dart';
import 'package:videocalling/features/video_call/call_manager.dart';
import 'package:videocalling/features/video_call/video_call_imports.dart';

class MoreInfoScreen extends GetView<DMoreInfoController> {
  final DMoreInfoController infoController = Get.put(DMoreInfoController());

  // Track different screen states
  final RxBool showingLogoutConfirmation = false.obs;
  final RxBool showingLanguageSelection = false.obs;

  MoreInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure LanguageController is registered
    if (!Get.isRegistered<LanguageController>()) {
      Get.put(LanguageController());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Obx(() {
          if (showingLogoutConfirmation.value) {
            return const CustomAppBar(title: '');
          } else if (showingLanguageSelection.value) {
            return CustomAppBar(title: 'language_settings'.tr);
          } else {
            return CustomAppBar(title: 'settings'.tr);
          }
        }),
        leading: Container(),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        // Show the appropriate screen based on state
        if (showingLogoutConfirmation.value) {
          loggerNoStack.i('Showing logout confirmation screen');
          return _buildLogoutConfirmation(context);
        } else if (showingLanguageSelection.value) {
          loggerNoStack.i('Showing language selection screen');
          return _buildLanguageSelectionScreen(context);
        } else {
          // Show settings list regardless of loading state
          // The settings list doesn't depend on doctor profile data
          loggerNoStack.t(
            "logout and language selection values ${showingLogoutConfirmation.value}, ${showingLanguageSelection.value}",
          );
          return _buildSettingsList(context);
        }
      }),
    );
  }

  // Widget _buildErrorState() {
  //   return Container(
  //     child: Center(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.search_off_rounded,
  //             size: 100,
  //             color: Colors.grey[400],
  //           ),
  //           const SizedBox(height: 20),
  //           Text(
  //             'unable_to_load_data'.tr,
  //             style: CustomTextStyle(
  //               fontSize: 16,
  //               color: Colors.grey[600],
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSettingsList(BuildContext context) {
    return ListView(
      children: [
        // Settings Options
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              // Manage my file
              _buildSettingsItem(
                svgIcon: AppImages.manageProfileIcon,
                title: 'manage_my_file'.tr,
                onTap: () {
                  Get.to(() => DoctorProfileView());
                },
              ),

              // Change Password
              _buildSettingsItem(
                svgIcon: AppImages.passwordIcon,
                title: 'change_password'.tr,
                onTap: () async {
                  await Get.toNamed(Routes.dChangePasswordScreen);
                  Get.delete<DChangePasswordController>();
                },
              ),

              // // Subscription List
              // _buildSettingsItem(
              //   // svgIcon: Icons.subscriptions_outlined,
              //   title: 'subscription_list'.tr,
              //   onTap: () async {
              //     await Get.toNamed(Routes.dSubscriptionListScreen);
              //     Get.delete<SubscriptionListController>();
              //   },
              // ),

              // Financial Reports and Payments
              _buildSettingsItem(
                svgIcon: AppImages.paymentsIcon,
                title: 'financial_reports'.tr,
                onTap: () {
                  // This could navigate to a combined financial screen in the future
                  Get.toNamed(Routes.dIncomeReportScreen);
                },
              ),

              // Availability and appointment management
              _buildSettingsItem(
                svgIcon: AppImages.availabilityIcon,
                title: 'available_management'.tr,
                onTap: () {
                  Get.toNamed(Routes.dAvailabilityManagementScreen);
                },
              ),

              // Language Settings
              _buildSettingsItem(
                svgIcon: AppImages.languageIcon,
                title: 'language_settings'.tr,
                onTap: () {
                  showingLanguageSelection.value = true;
                },
              ),

              // Sign Out
              _buildSettingsItem(
                svgIcon: AppImages.logoutIcon,
                title: 'sign_out'.tr,
                onTap: () {
                  showingLogoutConfirmation.value = true;
                },
              ),
            ],
          ),
        ),
      ],
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
                style: const CustomTextStyle(
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
                        style: CustomTextStyle(
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
                        backgroundColor: const Color(0xFF3366FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        'no'.tr,
                        style: CustomTextStyle(
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
                      width: 100, // Smaller container
                      height: 100, // Smaller container
                      child: Icon(
                        Icons.language,
                        size: 100, // Smaller icon
                        color: Colors.grey[300],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60), // Reduced spacing
                  // Instruction text
                  Center(
                    child: Text(
                      'select_your_language'.tr,
                      style: const CustomTextStyle(
                        fontSize: 18, // Smaller text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40), // Reduced spacing
                  // Language options
                  Obx(
                    () => _buildLanguageOption(
                      title: 'العربية',
                      isSelected: selectedLang.value == 'ar',
                      onTap: () => selectedLang.value = 'ar',
                    ),
                  ),

                  const SizedBox(height: 12), // Reduced spacing

                  Obx(
                    () => _buildLanguageOption(
                      title: 'English',
                      isSelected: selectedLang.value == 'en',
                      onTap: () => selectedLang.value = 'en',
                    ),
                  ),

                  const SizedBox(height: 12), // Reduced spacing

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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            'cancel'.tr,
                            style: const CustomTextStyle(
                              fontSize: 14,
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
                            backgroundColor: const Color(0xFF3366FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            'confirm'.tr,
                            style: const CustomTextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a language option
  Widget _buildLanguageOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3366FF).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF3366FF) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: CustomTextStyle(
                  fontSize: Get.locale?.languageCode == 'ar' ? 14 : 16,
                  color: isSelected ? const Color(0xFF3366FF) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3366FF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String svgIcon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    svgIcon,
                    width: 24,
                    height: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const CustomTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Icon(
                //   Icons.arrow_forward_ios,
                //   size: 16,
                //   color: Colors.grey[400],
                // ),
              ],
            ),
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),
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
      // Removed ConnectyCube dependencies
      // print('User logged out successfully');
    } catch (e) {
      loggerNoStack.e('Logout cleanup error: $e');
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
    Get.offAllNamed(Routes.therapistOnboardingScreen);
  }
}
