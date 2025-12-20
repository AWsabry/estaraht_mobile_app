import 'package:videocalling/core/config/app_imports.dart';
class DoctorPastAppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorPastAppointmentsController>(
      () => DoctorPastAppointmentsController(),
    );
  }
}
