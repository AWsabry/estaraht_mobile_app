import 'package:videocalling/core/config/app_imports.dart';
class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewController>(
      () => ReviewController(),
    );
  }
}
