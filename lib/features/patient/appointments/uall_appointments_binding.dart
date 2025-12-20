import 'package:videocalling/core/config/app_imports.dart';
class UAllAppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UAllAppointmentsController>(
      () => UAllAppointmentsController(),
    );
  }
}
