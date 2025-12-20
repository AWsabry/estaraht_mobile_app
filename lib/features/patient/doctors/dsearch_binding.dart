import 'package:videocalling/core/config/app_imports.dart';
class DoctorSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorSearchController>(
      () => DoctorSearchController(),
    );
  }
}
