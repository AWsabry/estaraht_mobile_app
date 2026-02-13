import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:videocalling/core/config/routes.dart';
import 'package:videocalling/core/constants/app_images.dart';
import 'package:videocalling/core/widgets/text_style/custom_text_style.dart';
import 'package:videocalling/features/language/controllers/language_controller.dart';
import 'package:videocalling/features/patient/payment_plans/controllers/payment_plans_controller.dart';
import 'package:videocalling/features/patient/payment_plans/models/payment_plan_model.dart';
import 'package:videocalling/shared/services/storage/storage_service.dart';

class PaymentPlansPage extends StatelessWidget {
  const PaymentPlansPage({super.key});

  // Direct getter that always ensures controller exists
  PaymentPlansController get controller {
    if (!Get.isRegistered<PaymentPlansController>()) {
      Get.put(PaymentPlansController());
    }
    return Get.find<PaymentPlansController>();
  }

  @override
  Widget build(BuildContext context) {
    // Force controller initialization on build
    final ctrl = controller;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(AppImages.appBarIcon, width: 38),

            Text(
              'packages'.tr,
              style: const CustomTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 48), // Balance the layout
          ],
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoadingPlans.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.availablePlans.isEmpty) {
          return Center(
            child: Text(
              'no_plans_available'.tr,
              style: const CustomTextStyle(fontSize: 16),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSessionsStatusCard(ctrl),
              const SizedBox(height: 16),
              ...ctrl.availablePlans.map(
                (plan) => _buildPlanCard(plan, context, ctrl),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSessionsStatusCard(PaymentPlansController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3961F1), Color(0xFF5B7BF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3961F1).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'your_sessions'.tr,
            style: const CustomTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSessionCounter(
                  label: 'available'.tr,
                  count: ctrl.sessionsAvailable.value,
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.greenAccent,
                ),
              ),
              Container(
                height: 50,
                width: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSessionCounter(
                  label: 'pending'.tr,
                  count: ctrl.sessionsPending.value,
                  icon: Icons.schedule,
                  iconColor: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCounter({
    required String label,
    required int count,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              count.toString(),
              style: const CustomTextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: CustomTextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    PaymentPlan plan,
    BuildContext context,
    PaymentPlansController ctrl,
  ) {
    final langCode = Get.find<LanguageController>().currentLanguage.value;

    // Get localized plan name
    String planName;
    if (langCode == 'ar' && plan.planNameAr != null) {
      planName = plan.planNameAr!;
    } else if (langCode == 'fr' && plan.planNameFr != null) {
      planName = plan.planNameFr!;
    } else {
      planName = plan.planName;
    }

    // Get localized description
    String description;
    if (langCode == 'ar' && plan.descriptionAr != null) {
      description = plan.descriptionAr!;
    } else if (langCode == 'fr' && plan.descriptionFr != null) {
      description = plan.descriptionFr!;
    } else {
      description = plan.description ?? '';
    }

    // Check if this plan is selected
    final isSelected = ctrl.selectedPlan.value?.id == plan.id;

    // Highlight the first-time plan
    final isSpecialPlan = plan.isFirstTimeOnly;

    return GestureDetector(
      onTap: () {
        ctrl.selectPlan(plan);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF3961F1) : Colors.grey.shade200,
            width: isSelected ? 1 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // White container (always visible - contains title and price)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: langCode == 'en'
                    ? [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Package badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isSpecialPlan
                                      ? 'save_25_first_session'.tr
                                      : 'package_badge'.tr,
                                  style: isSpecialPlan
                                      ? const CustomTextStyle(
                                          color: Color(0xFFFF6B4A),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        )
                                      : const CustomTextStyle(
                                          color: Color(0xFF3961F1),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Plan name
                              Row(
                                children: [
                                  SizedBox(
                                    width: 170.w,
                                    child: Text(
                                      planName,
                                      textAlign: TextAlign.left,
                                      style: const CustomTextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${plan.price.toStringAsFixed(0)}\$',
                                    style: const CustomTextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3961F1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]
                    : [
                        // Arabic/French: Title and badge on left
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Package badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isSpecialPlan
                                      ? 'save_25_first_session'.tr
                                      : 'package_badge'.tr,
                                  style: isSpecialPlan
                                      ? const CustomTextStyle(
                                          color: Color(0xFFFF6B4A),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        )
                                      : const CustomTextStyle(
                                          color: Color(0xFF3961F1),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              // Plan name
                              Row(
                                children: [
                                  SizedBox(
                                    width: 170.w,
                                    child: Text(
                                      planName,
                                      textAlign: TextAlign.right,
                                      style: const CustomTextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Price on left (for Arabic)
                                  Text(
                                    '${plan.price.toStringAsFixed(0)}\$',
                                    style: const CustomTextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3961F1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
              ),
            ),

            // Expanded state - show features and button in gray area
            if (isSelected) ...[
              // Special offer tag for first-time plans
              const SizedBox(height: 20),

              // Features list - only show sessions count for non-first-time packages
              if (!plan.isFirstTimeOnly) ...[
                _buildFeatureItem(
                  'sessions_count'.tr.replaceAll('{count}', '${plan.sessions}'),
                ),
                const SizedBox(height: 12),
              ],
              _buildFeatureItem('session_duration'.tr),
              const SizedBox(height: 12),
              _buildFeatureItem('session_type'.tr),

              // Description if available
              const SizedBox(height: 24),

              // Subscribe button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleSubscribe(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSpecialPlan
                        ? const Color(0xFFFF6B4A)
                        : const Color(0xFF3961F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    plan.isFirstTimeOnly
                        ? 'book_session_now'.tr
                        : 'book_now'.tr,
                    style: const CustomTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Icon(Icons.check, color: Colors.grey.shade600, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: CustomTextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubscribe(PaymentPlan plan) {
    final langCode = Get.find<LanguageController>().currentLanguage.value;
    // Use the getter to ensure controller is available
    controller.selectPlan(plan);

    // Get current user ID from local storage
    final userId = StorageService.readData(key: LocalStorageKeys.userId);

    if (userId == null || userId.toString().isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_login_to_subscribe'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Navigate to payment screen with plan info
    Get.toNamed(
      Routes.userPaymentScreen,
      arguments: {
        'isPlanPayment': true,
        'plan': plan.toJson(),
        'doctorName': 'Estarht Subscription',

        'userId': userId.toString(),
        'amount': plan.price.toString(),
        'description': langCode == 'ar'
            ? '${plan.descriptionAr} - ${plan.sessions} جلسات'
            : langCode == 'fr'
            ? '${plan.descriptionFr} - ${plan.sessions} sessions'
            : '${plan.description} - ${plan.sessions} sessions',
        'phone': '',
      },
    );
  }
}
