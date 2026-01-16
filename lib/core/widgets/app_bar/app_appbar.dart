import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool? isBackArrow;
  final TextStyle? textStyle;
  final bool showProfileIcons;
  final bool showMenuIcon;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isBackArrow,
    this.onPressed,
    this.textStyle,
    this.showProfileIcons = true,
    this.showMenuIcon = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.h, vertical: 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side - Either back button with title or profile icons
            if (!showProfileIcons && isBackArrow == true)
              Expanded(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onBackPressed,
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style:
                            textStyle ??
                            const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else if (showProfileIcons)
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.profileParametersScreen);
                    },
                    child: Center(
                      child: SvgPicture.asset(
                        AppImages.appAccountCircle,
                        width: 26,
                        height: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Notification badge with click handler
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.notificationScreen);
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SvgPicture.asset(
                          AppImages.appBadging,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              const SizedBox.shrink(),

            // Right side - Menu icon (optional)
            if (showMenuIcon)
              Center(child: SvgPicture.asset(AppImages.appBarIcon, width: 38))
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class CustomSearchScreenAppBar extends StatelessWidget {
  String title;
  String title1;
  TextEditingController textController;
  Animation<Color> valueColor;
  Function(String) onSubmitted;
  VoidCallback onPressed;
  VoidCallback? onPressed1;
  bool? isBackArrow;

  CustomSearchScreenAppBar({
    super.key,
    required this.title,
    required this.title1,
    required this.textController,
    required this.valueColor,
    required this.onSubmitted,
    required this.onPressed,
    this.isBackArrow,
    this.onPressed1,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            gradient: LinearGradient(
              colors: [AppColors.color1, AppColors.color2],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          height: 125 + MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 15),
                    (isBackArrow ?? false)
                        ? InkWell(
                            onTap: onPressed1,
                            child: Image.asset(
                              AppImages.backIcon,
                              height: 25,
                              width: 22,
                            ),
                          )
                        : const SizedBox(),
                    SizedBox(width: (isBackArrow ?? false) ? 10 : 0),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppFontStyleTextStrings.regular,
                        color: AppColors.WHITE,
                      ),
                    ),
                    AppTextWidgets.mediumText(
                      text: title1,
                      color: AppColors.WHITE,
                      size: 25,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColors.WHITE,
                        ),
                        child: TextField(
                          controller: textController,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.WHITE,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            hintText: 'search_doctor_name'.tr,
                            hintStyle: TextStyle(
                              fontFamily: AppFontStyleTextStrings.regular,
                              color: AppColors.LIGHT_GREY_TEXT,
                              fontSize: 13,
                            ),
                            suffixIcon: SizedBox(
                              height: 20,
                              width: 20,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: valueColor,
                                  ),
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.WHITE,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.WHITE,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.WHITE,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onSubmitted: onSubmitted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: onPressed,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.WHITE,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(child: Image.asset(AppImages.searchIcon)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomHomeScreenAppBar extends StatelessWidget {
  String title;
  String title1;
  TextEditingController textController;
  Animation<Color> valueColor;
  Function(String) onSubmitted;
  Function(String) onChanged;
  VoidCallback onPressed;

  // Language-specific configuration
  final double? arabicFontSize;
  final double? englishFontSize;
  final double? frenchFontSize;
  final double? arabicButtonWidth;
  final double? englishButtonWidth;
  final double? frenchButtonWidth;
  final EdgeInsets? arabicButtonPadding;
  final EdgeInsets? englishButtonPadding;
  final EdgeInsets? frenchButtonPadding;

  CustomHomeScreenAppBar({
    super.key,
    required this.title,
    required this.title1,
    required this.textController,
    required this.valueColor,
    required this.onSubmitted,
    required this.onChanged,
    required this.onPressed,
    // Language configuration defaults
    this.arabicFontSize,
    this.englishFontSize,
    this.frenchFontSize,
    this.arabicButtonWidth,
    this.englishButtonWidth,
    this.frenchButtonWidth,
    this.arabicButtonPadding,
    this.englishButtonPadding,
    this.frenchButtonPadding,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with profile icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Profile Icons
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.profileParametersScreen);
                      },
                      child: Center(
                        child: SvgPicture.asset(
                          AppImages.appAccountCircle,
                          width: 26.w,
                          height: 26.h,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Notification badge with click handler
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.notificationScreen);
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: SvgPicture.asset(
                            AppImages.appBadging,
                            width: 24.w,
                            height: 24.h,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Right side - Menu icon
                Center(
                  child: SvgPicture.asset(AppImages.appBarIcon, width: 38),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar that acts like a button
                  InkWell(
                    onTap: onPressed,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[500]!),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          textDirection: Get.locale?.languageCode == 'ar'
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          children: [
                            Expanded(
                              child: Text(
                                'find_a_therapist'.tr,
                                style: TextStyle(
                                  color: Colors.grey[900],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: Get.locale?.languageCode == 'ar'
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.search, color: Colors.grey[900]),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Welcome message
                  if (Get.locale?.languageCode == 'ar')
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'welcome_back'.tr,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFontStyleTextStrings.regular,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ' ${'wishing_calm_day'.tr}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.normal,
                                fontFamily: AppFontStyleTextStrings.regular,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'welcome_back'.tr,
                            style: TextStyle(
                              fontSize: Get.locale?.languageCode == 'fr'
                                  ? 24
                                  : 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'wishing_calm_day'.tr,
                            style: TextStyle(
                              fontSize: Get.locale?.languageCode == 'fr'
                                  ? 24
                                  : 26,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Action buttons
                  Builder(
                    builder: (context) {
                      final locale = Get.locale?.languageCode;
                      final isArabic = locale == 'ar';
                      final isFrench = locale == 'fr';

                      // Button width - French uses English defaults
                      final buttonWidth = isArabic
                          ? (arabicButtonWidth ?? 150)
                          : isFrench
                          ? (frenchButtonWidth ?? englishButtonWidth ?? 150)
                          : (englishButtonWidth ?? 150);

                      // Button padding - French uses English defaults
                      final buttonPadding = isArabic
                          ? (arabicButtonPadding ??
                                const EdgeInsets.symmetric(vertical: 6))
                          : isFrench
                          ? (frenchButtonPadding ??
                                englishButtonPadding ??
                                const EdgeInsets.symmetric(vertical: 6))
                          : (englishButtonPadding ??
                                const EdgeInsets.symmetric(vertical: 8));

                      // Font size - French uses English defaults
                      final fontSize = isArabic
                          ? (arabicFontSize ?? 11.sp)
                          : isFrench
                          ? (frenchFontSize ?? englishFontSize ?? 10.5.sp)
                          : (englishFontSize ?? 13.sp);

                      return Row(
                        children: [
                          SizedBox(
                            width: buttonWidth.w,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed(Routes.indemandDoctorScreen);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3961F1),
                                padding: buttonPadding,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'book_new_appointment'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () {
                                // Find therapist logic (same as search)
                                onPressed();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: buttonPadding,
                                side: BorderSide(color: Colors.grey[500]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'find_therapist'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,

                                  color: Colors.grey[900],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
