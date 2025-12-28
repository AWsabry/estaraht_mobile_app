import 'package:videocalling/core/config/app_imports.dart';

class ConsultationsController extends GetxController {
  RxInt currentTabIndex = 0.obs;

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
