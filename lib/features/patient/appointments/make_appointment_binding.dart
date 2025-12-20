import 'package:videocalling/core/config/app_imports.dart';
class MakeAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MakeAppointmentController>(
      () => MakeAppointmentController(),
    );
  }
}
