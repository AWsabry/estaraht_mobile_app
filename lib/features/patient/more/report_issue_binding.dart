import 'package:videocalling/core/config/app_imports.dart';
class ReportIssueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportIssueController>(
      () => ReportIssueController(),
    );
  }
}
