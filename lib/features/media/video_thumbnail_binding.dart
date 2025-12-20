import 'package:videocalling/core/config/app_imports.dart';

class MyVideoThumbnailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyVideoThumbnailController>(
          () => MyVideoThumbnailController(url: ''),
    );
  }
}