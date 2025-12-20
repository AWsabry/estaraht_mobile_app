import 'package:videocalling/core/config/app_imports.dart';
class DoctorChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorChatListController>(
      () => DoctorChatListController(),
    );
  }
}
