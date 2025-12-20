import 'package:videocalling/core/config/app_imports.dart';
class SpecialityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpecialityController>(
      () => SpecialityController(),
    );
  }
}
