import 'package:videocalling/core/config/app_imports.dart';
class SpecialityDoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpecialityDoctorController>(
      () => SpecialityDoctorController(),
    );
  }
}
