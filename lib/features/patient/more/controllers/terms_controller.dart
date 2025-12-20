import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/more/models/terms_model.dart';
class TermAndConditionsController extends GetxController {
  RxBool isLoaded = false.obs;
  RxBool isError = false.obs;

  TermsData termsData = TermsData();

  getPrivacy() async {
    final response = await get(Uri.parse("${Apis.ServerAddress}/api/about"))
        .timeout(const Duration(seconds: Apis.timeOut))
        .catchError((e) {
      isError.value = true;
    });

    if (response.statusCode == 200 &&
        jsonDecode(response.body)['status'] == 1) {
      final jsonResponse = jsonDecode(response.body);
      termsData = TermsData.fromJson(jsonResponse);
      isLoaded.value = true;
    } else {
      isError.value = true;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getPrivacy();
  }
}
