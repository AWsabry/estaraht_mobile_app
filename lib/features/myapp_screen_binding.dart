import 'package:videocalling/core/config/app_imports.dart';

class MyAppScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyAppController>(
      () => MyAppController(),
    );
  }
}