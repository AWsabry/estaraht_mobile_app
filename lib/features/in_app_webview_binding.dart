import 'package:videocalling/core/config/app_imports.dart';

class InAppWebViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InAppWebViewController1>(
          () => InAppWebViewController1(),
    );
  }
}