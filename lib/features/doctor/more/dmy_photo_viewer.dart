import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/more/dmy_photo_viewer_controller.dart';

class DMyPhotoView extends GetView<DMyPhotoViewController> {
  final DMyPhotoViewController photoViewController = Get.put(
    DMyPhotoViewController(),
  );

  DMyPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: photoViewController.isFromFile
          ? PhotoView(
              imageProvider: FileImage(File(photoViewController.imagePath)),
            )
          : PhotoView(
              imageProvider: NetworkImage(photoViewController.imagePath),
            ),
    );
  }
}
