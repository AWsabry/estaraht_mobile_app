import 'package:videocalling/core/config/app_imports.dart';
class DoctorProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorProfileController>(
      () => DoctorProfileController(),
    );
  }
}
