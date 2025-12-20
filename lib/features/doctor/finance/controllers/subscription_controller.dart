import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/finance/models/subscription_list_model.dart';

class SubscriptionListController extends GetxController {
  RxString docId = "".obs;
  RxBool isErrorInLoading = false.obs;

  Future? future;
  SubscriptionListModel? subscriptionListModel;
  RxList<DoctorsSubscription> info = <DoctorsSubscription>[].obs;

  fetchSubList() async {
    isErrorInLoading.value = true;
    final response = await get(
      Uri.parse(
        "${Apis.ServerAddress}/api/doctor_subscription_list?doctor_id=${docId.value}",
      ),
    ).timeout(const Duration(seconds: Apis.timeOut));
    try {
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        subscriptionListModel = SubscriptionListModel.fromJson(jsonResponse);
        info.value = subscriptionListModel!.data!.doctorsSubscription!;
        isErrorInLoading.value = false;
      }
    } catch (e) {
      isErrorInLoading.value = false;
    }
    Client().close();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    docId.value = StorageService.readData(key: LocalStorageKeys.userId) ?? "";
    fetchSubList();
  }
}
