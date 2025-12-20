import 'package:videocalling/core/config/app_imports.dart';
class UserAppointmentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserAppointmentDetailsController>(
      () => UserAppointmentDetailsController(),
    );
  }
}
