import 'package:videocalling/core/config/app_imports.dart';
class IncomeReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeReportController>(
      () => IncomeReportController(),
    );
  }
}
