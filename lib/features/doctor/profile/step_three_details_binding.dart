import 'package:videocalling/core/config/app_imports.dart';
class StepThreeDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StepThreeDetailsController>(
      () => StepThreeDetailsController(),
    );
  }
}
