import 'package:videocalling/core/config/app_imports.dart';
class DoctorRegisterBinding extends Bindings {
  @override

  void dependencies() {
    Get.lazyPut<DoctorRegisterController>(
      () => DoctorRegisterController(),
    );
  }
}
