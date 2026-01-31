import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/auth/controllers/review_status_controller.dart';

class UnderReviewScreen extends GetView<ReviewStatusController> {
  const UnderReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewStatusController());
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isSmallScreen = width < 360;
    final isMediumScreen = width >= 360 && width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16.0 : (isMediumScreen ? 24.0 : 32.0),
            vertical: isSmallScreen ? 16.0 : 16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              // Review Icon
              Container(
                width: isSmallScreen ? 80 : (isMediumScreen ? 100 : 120),
                height: isSmallScreen ? 80 : (isMediumScreen ? 100 : 120),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 40 : (isMediumScreen ? 50 : 60),
                  ),
                ),
                child: Icon(
                  Icons.hourglass_empty_rounded,
                  size: isSmallScreen ? 40 : (isMediumScreen ? 52 : 64),
                  color: const Color(0xFF4A90E2),
                ),
              ),

              SizedBox(height: isSmallScreen ? 20 : (isMediumScreen ? 26 : 32)),

              // Title
              Text(
                'under_review_title'.tr,
                style: CustomTextStyle(
                  fontSize: isSmallScreen ? 22 : (isMediumScreen ? 25 : 28),
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isSmallScreen ? 12 : 16),

              // Doctor info
              Obx(
                () => Column(
                  children: [
                    if (controller.doctorName.value.isNotEmpty)
                      Text(
                        controller.doctorName.value,
                        style: CustomTextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 8),
                    if (controller.doctorEmail.value.isNotEmpty)
                      Text(
                        controller.doctorEmail.value,
                        style: CustomTextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 16 : 24),

              // Description
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8.0 : 16.0,
                ),
                child: Text(
                  'under_review_message'.tr,
                  style: CustomTextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                    height: 1.5,
                    fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: isSmallScreen ? 12 : 16),

              // Estimated time
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 20,
                  vertical: isSmallScreen ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFB74D), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: isSmallScreen ? 18 : 20,
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'review_time_estimate'.tr,
                        style: CustomTextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFE65100),
                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 20 : (isMediumScreen ? 26 : 32)),

              // Info cards
              _buildInfoCard(
                icon: Icons.email_outlined,
                text: 'review_email_notification'.tr,
                isArabic: isArabic,
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: isSmallScreen ? 10 : 12),

              _buildInfoCard(
                icon: Icons.verified_user_outlined,
                text: 'review_verification_process'.tr,
                isArabic: isArabic,
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: isSmallScreen ? 20 : 24),

              // Refresh status button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 48 : 56,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.checkApprovalStatus(
                            showSnackbar: true,
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFFB0BEC5),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: isSmallScreen ? 20 : 24,
                            height: isSmallScreen ? 20 : 24,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh,
                                size: isSmallScreen ? 18 : 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'refresh_status'.tr,
                                style: CustomTextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: isArabic
                                      ? 'NotoKufiArabic'
                                      : 'Roboto',
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              SizedBox(height: isSmallScreen ? 10 : 12),

              // Logout button
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 48 : 56,
                child: OutlinedButton(
                  onPressed: () => controller.logout(),
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
                    'logout'.tr,
                    style: CustomTextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
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
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    required bool isArabic,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 20 : 24,
            color: const Color(0xFF4A90E2),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Text(
              text,
              style: CustomTextStyle(
                fontSize: isSmallScreen ? 12 : 14,
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
}
