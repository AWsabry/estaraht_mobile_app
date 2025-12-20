import 'package:videocalling/core/config/app_imports.dart';

class PatientTabScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientTabController>(
      () => PatientTabController(),
    );
    Get.lazyPut<IndemandDoctorController>(
      () => IndemandDoctorController(),
    );
  }
}
