import 'package:videocalling/core/config/app_imports.dart';
class UserHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserHomeController>(
      () => UserHomeController(),
    );
  }
}
