import 'package:videocalling/core/config/app_imports.dart';
class AboutUSBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutUsController>(
      () => AboutUsController(),
    );
  }
}
