import 'package:flutter/material.dart' as material show RefreshIndicator;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: CustomAppBar(
          title: 'notifications'.tr,
          onPressed: () => Get.back(),
          isBackArrow: true,
        ),
        elevation: 0,
        leading: Container(),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF204FCF)),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'no_notifications'.tr,
                  style: CustomTextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'no_notifications_desc'.tr,
                  style: CustomTextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return material.RefreshIndicator(
          onRefresh: () => controller.refreshNotifications(),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              // Use the InfoNotificationWidget for display
              InfoNotificationWidget(
                messages: controller.notifications
                    .map((n) => n['message'] as String)
                    .toList(),
              ),
              const SizedBox(height: 16),
              // Detailed notification list with actions
              ...controller.notifications.map((notification) {
                final isRead = notification['is_read'] as bool? ?? false;
                final createdAt = notification['created_at'] != null
                    ? DateTime.parse(notification['created_at'])
                    : TimezoneService.getCurrentMauritaniaTime();
                final timeAgo = _getTimeAgo(createdAt);

                return Dismissible(
                  key: Key(notification['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    controller.deleteNotification(
                      notification['id'].toString(),
                    );
                    Get.snackbar(
                      'deleted'.tr,
                      'notification_deleted'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: InkWell(
                    onTap: () {
                      if (!isRead) {
                        controller.markAsRead(notification['id'].toString());
                      }
                    },
                    child: Container(
                      color: isRead ? Colors.white : Colors.blue[50],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Unread indicator
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            decoration: BoxDecoration(
                              color: isRead
                                  ? Colors.transparent
                                  : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (notification['title'] != null)
                                  Text(
                                    notification['title'],
                                    style: CustomTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: isArabic
                                          ? 'NotoKufiArabic'
                                          : 'Roboto',
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  notification['message'],
                                  style: CustomTextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                    fontFamily: isArabic
                                        ? 'NotoKufiArabic'
                                        : 'Roboto',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeAgo,
                                  style: CustomTextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontFamily: isArabic
                                        ? 'NotoKufiArabic'
                                        : 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              // Clear all button
              if (controller.notifications.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton(
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'clear_all'.tr,
                        middleText: 'clear_all_notifications_confirm'.tr,
                        textConfirm: 'yes'.tr,
                        textCancel: 'cancel'.tr,
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          controller.clearAllNotifications();
                          Get.back();
                        },
                      );
                    },
                    child: Text(
                      'clear_all_notifications'.tr,
                      style: CustomTextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = TimezoneService.getCurrentMauritaniaTime();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, y').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
