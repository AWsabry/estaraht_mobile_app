import 'package:videocalling/core/config/app_imports.dart';
class SubscriptionListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionListController>(
      () => SubscriptionListController(),
    );
  }
}
