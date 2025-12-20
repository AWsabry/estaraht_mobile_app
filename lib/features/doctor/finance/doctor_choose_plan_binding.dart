import 'package:videocalling/core/config/app_imports.dart';
class DoctorChooseYourPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorChooseYourPlanController>(
      () => DoctorChooseYourPlanController(),
    );
  }
}
