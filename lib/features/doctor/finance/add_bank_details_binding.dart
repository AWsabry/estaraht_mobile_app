import 'package:videocalling/core/config/app_imports.dart';
class BankDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BankDetailController>(
      () => BankDetailController(),
    );
  }
}
