import 'package:videocalling/core/config/app_imports.dart';
class RegisterPatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterPatientController>(
      () => RegisterPatientController(),
    );
  }
}
