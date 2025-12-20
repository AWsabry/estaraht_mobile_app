import 'package:videocalling/core/config/app_imports.dart';
class DAllAppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DAllAppointmentsController>(
      () => DAllAppointmentsController(),
    );
  }
}
