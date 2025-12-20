import 'package:videocalling/core/config/app_imports.dart';

class ForgetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgetPasswordController>(
          () => ForgetPasswordController(),
    );
  }
}