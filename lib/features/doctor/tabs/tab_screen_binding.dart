import 'package:videocalling/core/config/app_imports.dart';
class TabScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorTabController>(
      () => DoctorTabController(),
    );
  }
}
