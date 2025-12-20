import 'package:videocalling/core/config/app_imports.dart';

class MyVideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyVideoPlayerController>(
          () => MyVideoPlayerController(),
    );
  }
}