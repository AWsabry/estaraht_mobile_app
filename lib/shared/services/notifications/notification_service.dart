import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/core/config/routes.dart';
import 'package:videocalling/features/doctor/appointments/controllers/appointment_detail_controller.dart';
import 'package:videocalling/features/chat/controllers/chat_controller.dart';

// Simplified notification service without flutter_local_notifications
class NotificationHelper {
  String? title;
  String? body;
  String? payload;
  String? id;
  String? type;
  BuildContext? context;

  NotificationHelper() {
    initialize();
  }

  Future<void> checkNotificationStatus(String id) async {
    // Stub implementation - notifications disabled for now
    print('Notification status check disabled: $id');
  }

  initialize() async {
    // Stub implementation - notifications disabled for now
    print('Notification service initialized (local notifications disabled)');
  }

  showNotification({
    String? title,
    String? body,
    String? payload,
    String? id,
  }) async {
    // Stub implementation - notifications disabled for now
    print('Notification would show: $title - $body');
  }

  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      if (payload.split(":")[0] == "user_id") {
        Get.toNamed(
          Routes.uAppointmentDetailScreen,
          arguments: {'id': payload.split(":")[1].toString()},
        );
      } else if (payload.split(":")[0] == "doctor_id") {
        await Get.toNamed(
          Routes.dAppointmentDetailScreen,
          arguments: {'id': payload.split(":")[1].toString()},
        );
        Get.delete<DAppointmentDetailsController>();
      } else if (payload.split(":")[0].toString().contains("100") ||
          payload.split(":")[0].toString().contains("117")) {
        await Get.toNamed(
          Routes.chatScreen,
          arguments: {
            'userName': payload.split(":")[1].toString(),
            'uid': payload.split(":")[0].toString(),
            'isUser': payload.split(":")[0].toString().contains("100")
                ? false
                : true,
          },
        );
        Get.delete<ChatController>();
      }
    }
  }

  void onDidReceiveLocalNotification(
    int id,
    String title,
    String? body,
    String? payload,
  ) async {
    if (payload != null) {
      if (payload.split(":")[0] == "user_id") {
        Get.toNamed(
          Routes.uAppointmentDetailScreen,
          arguments: {'id': payload.split(":")[1].toString()},
        );
      } else if (payload.split(":")[0] == "doctor_id") {
        await Get.toNamed(
          Routes.dAppointmentDetailScreen,
          arguments: {'id': payload.split(":")[1].toString()},
        );
        Get.delete<DAppointmentDetailsController>();
      } else if (payload.split(":")[0].toString().contains("100") ||
          payload.split(":")[0].toString().contains("117")) {
        await Get.toNamed(
          Routes.chatScreen,
          arguments: {
            'userName': payload.split(":")[1].toString(),
            'uid': payload.split(":")[0].toString(),
            'isUser': payload.split(":")[0].toString().contains("100")
                ? false
                : true,
          },
        );
        Get.delete<ChatController>();
      }
    }
  }
}
