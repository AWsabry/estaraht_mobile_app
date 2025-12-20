import 'package:videocalling/core/config/app_imports.dart';

class MyPhotoViewerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyPhotoViewerController>(
          () => MyPhotoViewerController(),
    );
  }
}