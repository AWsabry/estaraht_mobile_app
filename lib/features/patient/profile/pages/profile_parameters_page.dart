import 'package:videocalling/core/config/app_imports.dart';
import 'dart:ui';

class ProfileParametersScreen extends GetView<ProfileParametersController> {
  const ProfileParametersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👤 Profile image with name card overlayed
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Profile image (behind everything)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Obx(
                        () => CachedNetworkImage(
                          imageUrl: controller.profileImageUrl.value,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF204FCF),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No Profile Image',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
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
                    ),
                  ),

                  // Header with back button and title (on top of image)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isArabic ? 8 : 16,
                        ),
                        child: Row(
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.black,
                                size: 20,
                              ),
                              onPressed: () => Get.back(),
                            ),
                            Text(
                              'Profile',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontSize: 16,
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

                  // 🧍‍♀️ Name and role card overlaying the bottom of the image
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(0),

                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textDirection: isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                              child: Container(
                                width: 307,
                                height: 55,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F6F6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  textDirection: isArabic
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(
                                      () => Text(
                                        controller.userName.value.isEmpty
                                            ? 'username'.tr
                                            : controller.userName.value,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: isArabic
                                              ? 'NotoKufiArabic'
                                              : 'Roboto',
                                        ),
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        controller.userRole.value.isEmpty
                                            ? 'occupation'.tr
                                            : controller.userRole.value,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.black54,
                                          fontFamily: isArabic
                                              ? 'NotoKufiArabic'
                                              : 'Roboto',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 37,
                            height: 37,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Color(0xFF1C1B1F),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),



            // Container with rounded top corners
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // 🔹 Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      GestureDetector(
                        onTap: () => controller.changeTab(0),
                        child: Obx(() => _buildTab(
                          title: 'bio'.tr,
                          isActive: controller.activeTabIndex.value == 0,
                          isArabic: isArabic,
                        )),
                      ),
                      const SizedBox(width: 24),
                     /* GestureDetector(
                        onTap: () => controller.changeTab(1),
                        child: Obx(() => _buildTab(
                          title: 'medical_file'.tr,
                          isActive: controller.activeTabIndex.value == 1,
                          isArabic: isArabic,
                        )),
                      ),*/
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tab content - switches based on active tab
                  Obx(() {
                    if (controller.activeTabIndex.value == 0) {
                      // Bio Tab Content
                      return Column(
                        children: [
                          // 📄 Description text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Specialized in diagnosing and treating psychological and behavioral disorders, helping individuals deal with stress and emotional and intellectual problems.',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 10,
                                height: 1.0,
                                letterSpacing: 0,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                            ),
                          ),


                          const SizedBox(height: 24),

                          // 🧾 Sessions card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              width: 321,
                              height: 92,
                              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300, width: 0.5),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.topCenter,
                                    child: const Icon(
                                      Icons.video_call, // Use your desired icon
                                      color: Colors.black54,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'sessions'.tr,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Obx(
                                            () => Text(
                                          '${controller.sessionCount} Sessions',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                      ,
                                    ],
                                  ),
                                ],
                              ),
                            )
                            ,
                          )
                          ,
                        ],
                      );
                    } else {
                      // Medical File Tab Content
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Medical History',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No medical records available.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.black54,
                                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isActive,
    required bool isArabic,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFF204FCF) : Colors.black54,
            fontSize: isActive ? 16 : 12,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            height: 1.0,
            letterSpacing: 0,
            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
          ),
          textAlign: TextAlign.right,
        ),
        if (isActive)
          IntrinsicWidth(
            child: Container(
              height: 2,
              color: const Color(0xFF204FCF),
            ),
          ),
      ],
    );
  }

}
