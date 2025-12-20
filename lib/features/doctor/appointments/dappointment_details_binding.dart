import 'package:videocalling/core/config/app_imports.dart';
class DAppointmentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DAppointmentDetailsController>(
      () => DAppointmentDetailsController(),
    );
  }
}
