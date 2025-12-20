import 'package:videocalling/core/config/app_imports.dart';
class DMoreInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DMoreInfoController>(
      () => DMoreInfoController(),
    );
  }
}
