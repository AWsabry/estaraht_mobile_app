import 'package:videocalling/core/config/app_imports.dart';
class UserLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserLoginController>(
      () => UserLoginController(),
    );
  }
}
