import 'package:videocalling/core/config/app_imports.dart';
class DChangePasswordBinding extends Bindings {
  @override

  void dependencies() {
    Get.lazyPut<DChangePasswordController>(
      () => DChangePasswordController(),
    );
  }
}
