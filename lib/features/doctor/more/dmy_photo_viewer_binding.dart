import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/more/dmy_photo_viewer_controller.dart';

class DMyPhotoViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DMyPhotoViewController>(() => DMyPhotoViewController());
  }
}
