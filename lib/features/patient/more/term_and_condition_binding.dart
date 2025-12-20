import 'package:videocalling/core/config/app_imports.dart';
class TermAndConditionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermAndConditionsController>(
      () => TermAndConditionsController(),
    );
  }
}
