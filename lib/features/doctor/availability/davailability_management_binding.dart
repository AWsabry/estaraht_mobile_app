import 'package:get/get.dart';
import 'package:videocalling/features/doctor/availability/controllers/availability_controller.dart';

class DAvailabilityManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DAvailabilityManagementController>(
      () => DAvailabilityManagementController(),
    );
  }
}
