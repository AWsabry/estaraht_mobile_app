import 'package:videocalling/core/config/app_imports.dart';
class HolidayManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HolidayManageController>(
      () => HolidayManageController(),
    );
  }
}
