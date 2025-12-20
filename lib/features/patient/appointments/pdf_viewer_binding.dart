import 'package:videocalling/core/config/app_imports.dart';
class AppointmentDetailsScreenPdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppointmentDetailsScreenPdfController>(
      () => AppointmentDetailsScreenPdfController(),
    );
  }
}
