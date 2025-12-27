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
                      child: Obx(() {
                        final imageUrl = controller.profileImageUrl.value;
                        if (imageUrl.isEmpty) {
                          return Container(
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
                          );
                        }
                        return CachedNetworkImage(
                          imageUrl: imageUrl,
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
                        );
                      }),
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

                  // 🧍‍♀️ Name and email card overlaying the bottom of the image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textDirection: isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isArabic
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => Text(
                                    controller.userName.value.isEmpty
                                        ? 'username'.tr
                                        : controller.userName.value,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: isArabic
                                              ? 'NotoKufiArabic'
                                              : 'Roboto',
                                        ),
                                    textAlign: isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    controller.userEmail.value.isEmpty
                                        ? 'email'.tr
                                        : controller.userEmail.value,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                      fontFamily: isArabic
                                          ? 'NotoKufiArabic'
                                          : 'Roboto',
                                    ),
                                    textAlign: isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  ),
                                ),
                              ],
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

                  // Patient Information
                  Obx(
                    () => Column(
                      children: [
                        // Email
                        if (controller.userEmail.value.isNotEmpty)
                          _buildInfoRow(
                            icon: Icons.email,
                            label: 'email'.tr,
                            value: controller.userEmail.value,
                            isArabic: isArabic,
                            theme: theme,
                          ),

                        if (controller.userEmail.value.isNotEmpty)
                          const SizedBox(height: 16),

                        // Phone
                        if (controller.userPhone.value.isNotEmpty)
                          _buildInfoRow(
                            icon: Icons.phone,
                            label: 'phone'.tr,
                            value: controller.userPhone.value,
                            isArabic: isArabic,
                            theme: theme,
                          ),

                        if (controller.userPhone.value.isNotEmpty)
                          const SizedBox(height: 16),

                        // Age
                        if (controller.userAge.value.isNotEmpty)
                          _buildInfoRow(
                            icon: Icons.cake,
                            label: 'age'.tr,
                            value: controller.userAge.value,
                            isArabic: isArabic,
                            theme: theme,
                          ),

                        if (controller.userAge.value.isNotEmpty)
                          const SizedBox(height: 16),

                        // Gender
                        if (controller.userGender.value.isNotEmpty)
                          _buildInfoRow(
                            icon: Icons.person,
                            label: 'gender'.tr,
                            value: controller.userGender.value,
                            isArabic: isArabic,
                            theme: theme,
                          ),

                        const SizedBox(height: 24),

                        // 🧾 Sessions card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: isArabic
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.topCenter,
                                  child: const Icon(
                                    Icons.video_call,
                                    color: Colors.black54,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: isArabic
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'sessions'.tr,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: isArabic
                                                ? 'NotoKufiArabic'
                                                : 'Roboto',
                                            fontSize: 16,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(
                                      () => Text(
                                        '${controller.sessionCount} Sessions',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: isArabic
                                                  ? 'NotoKufiArabic'
                                                  : 'Roboto',
                                              fontSize: 14,
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
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isArabic,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: Row(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Icon(icon, color: const Color(0xFF204FCF), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
