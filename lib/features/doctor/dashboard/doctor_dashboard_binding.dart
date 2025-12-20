import 'package:videocalling/core/config/app_imports.dart';
class DoctorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorDashboardController>(
      () => DoctorDashboardController(),
    );
  }
}
