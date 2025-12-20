import 'package:videocalling/core/config/app_imports.dart';
class UserEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserEditController>(
      () => UserEditController(),
    );
  }
}
