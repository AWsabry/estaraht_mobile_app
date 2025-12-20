import 'package:videocalling/core/config/app_imports.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(
      SplashController(),
    );
  }
}