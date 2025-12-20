import 'package:videocalling/core/config/app_imports.dart';
class DoctorLoginBinding extends Bindings {
  @override

  void dependencies() {
    Get.lazyPut<DoctorLoginController>(
      () => DoctorLoginController(),
    );
  }
}
