import 'package:videocalling/core/config/app_imports.dart';

class AccountRejectedScreen extends StatelessWidget {
  const AccountRejectedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    // Get rejection reason from route arguments
    final String? rejectionReason = Get.arguments as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Rejection Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 64,
                  color: Color(0xFFE53935),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'account_rejected_title'.tr,
                style: CustomTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'account_rejected_message'.tr,
                  style: CustomTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                    height: 1.5,
                    fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Rejection reason (if provided)
              if (rejectionReason != null && rejectionReason.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE53935),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Color(0xFFE53935),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'rejection_reason'.tr,
                            style: CustomTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE53935),
                              fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rejectionReason,
                        style: CustomTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Info cards
              _buildInfoCard(
                icon: Icons.support_agent_outlined,
                text: 'rejection_contact_support'.tr,
                isArabic: isArabic,
              ),

              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.restart_alt_outlined,
                text: 'rejection_reapply_info'.tr,
                isArabic: isArabic,
              ),

              const Spacer(),

              // Contact Support button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _contactSupport(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.support_agent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'contact_support'.tr,
                        style: CustomTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Back to Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _backToLogin(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A90E2),
                    side: const BorderSide(
                      color: Color(0xFF4A90E2),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'back_to_login'.tr,
                    style: CustomTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    required bool isArabic,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF4A90E2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: CustomTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    // TODO: Implement contact support functionality
    // This could open email client, in-app chat, or phone dialer
    Get.snackbar(
      'contact_support'.tr,
      'support_contact_message'.tr,
      backgroundColor: const Color(0xFF4A90E2),
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
    );
  }

  void _backToLogin() async {
    // Clear local storage
    StorageService.clearAllStorage();

    // Sign out from Firebase
    await firebaseHelper.signOut();

    // Navigate to login screen
    Get.offAllNamed(Routes.doctorLoginScreen);
  }
}
