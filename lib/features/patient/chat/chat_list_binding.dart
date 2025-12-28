import 'package:videocalling/core/config/app_imports.dart';

class PatientChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientChatListController>(() => PatientChatListController());
  }
}
