import 'package:videocalling/core/config/app_imports.dart';
class DoctorDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorDetailController>(
      () => DoctorDetailController(),
    );
  }
}
