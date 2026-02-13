import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToTherapist() {
    Get.to(
      () => const TherapistOnboardingScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _navigateToPatient() {
    Get.to(
      () => const PatientOnboardingScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF204FCF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo with  Hero animation
                  Hero(
                    tag: 'app_logo',
                    child: SvgPicture.asset(
                      AppImages.splashIcon,
                      height: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Title
                  Text(
                    'welcome_back'.tr,
                    textAlign: TextAlign.center,
                    style: CustomTextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'select_your_role'.tr,
                    textAlign: TextAlign.center,
                    style: CustomTextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade300,
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                    ),
                  ),
                  const Spacer(flex: 3),

                  // Role selection buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Therapist button
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 800),
                            child: _buildRoleButton(
                              title: 'therapist'.tr,
                              subtitle: 'help_your_patients'.tr,
                              icon: Icons.medical_services_outlined,
                              onPressed: _navigateToTherapist,
                              isPrimary: true,
                              isArabic: isArabic,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Patient button
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 1000),
                            child: _buildRoleButton(
                              title: 'seeking_support'.tr,
                              subtitle: 'connect_with_your_doctor'.tr,
                              icon: Icons.person_outline,
                              onPressed: _navigateToPatient,
                              isPrimary: false,
                              isArabic: isArabic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
    required bool isArabic,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            textDirection: isArabic ? TextDirection.ltr : TextDirection.ltr,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? const Color(0xFF204FCF).withOpacity(0.1)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isPrimary ? const Color(0xFF204FCF) : Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: CustomTextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isPrimary
                            ? const Color(0xFF204FCF)
                            : Colors.white,
                        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: CustomTextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: isPrimary
                            ? Colors.black87
                            : Colors.white.withOpacity(0.8),
                        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                size: 20,
                color: isPrimary
                    ? const Color(0xFF204FCF)
                    : Colors.white.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
