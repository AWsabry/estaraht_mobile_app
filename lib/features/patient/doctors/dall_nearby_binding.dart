import 'package:videocalling/core/config/app_imports.dart';
class DAllNearbyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DAllNearbyController>(
      () => DAllNearbyController(),
    );
  }
}
