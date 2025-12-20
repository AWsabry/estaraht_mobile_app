import 'package:get/get.dart';
import 'package:videocalling/features/patient/more/controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
