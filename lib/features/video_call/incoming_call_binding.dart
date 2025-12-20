import 'package:videocalling/core/config/app_imports.dart';

class IncomingCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomingCallController>(
          () => IncomingCallController(),
    );
  }
}