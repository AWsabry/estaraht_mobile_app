import 'package:videocalling/core/config/app_imports.dart';

class MyVideoThumbNail extends GetView<MyVideoThumbnailController> {
  String url;
  MyVideoThumbNail({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyVideoThumbnailController>(
      init: MyVideoThumbnailController(url: url),
      builder: (thumbnailController) {
        return AspectRatio(
          aspectRatio:
              thumbnailController.videoPlayerController1.value.aspectRatio,
          child: VideoPlayer(thumbnailController.videoPlayerController1),
        );
      },
    );
  }
}
