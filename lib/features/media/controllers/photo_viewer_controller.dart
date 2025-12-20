import 'package:videocalling/core/config/app_imports.dart';

class MyPhotoViewerController extends GetxController {
  String url = Get.arguments['url'];
  String id = Get.arguments['id'];
  bool isDeleteShown = Get.arguments['isDeleteShown'];
  String reportName = Get.arguments['reportName'];
  GlobalKey<FormState> sKey = GlobalKey<FormState>();

  deletePhoto({String? imageId}) async {
    var res = await get(Uri.parse(
            "${Apis.ServerAddress}/api/delete_upload_image?image_id=$imageId"))
        .timeout(const Duration(seconds: Apis.timeOut));

    if (res.statusCode == 200) {
      ReportDeleteRes reportDeleteRes =
          ReportDeleteRes.fromJson(jsonDecode(res.body));

      if (reportDeleteRes.status == 1) {
        customDialog(
          onPressed: () {
            Get.back();
            Get.back(result: true);
          },
          s1: 'success'.tr,
          s2: reportDeleteRes.message ?? "",
        );
      } else {
        customDialog(
          onPressed: () {
            Get.back();
            Get.back(result: true);
          },
          s1: 'success'.tr,
          s2: reportDeleteRes.message ?? "",
        );
      }
    }
    Client().close();
  }
}
