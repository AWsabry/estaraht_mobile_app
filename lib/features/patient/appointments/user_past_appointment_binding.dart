import 'package:videocalling/core/config/app_imports.dart';
class UserPastAppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserPastAppointmentsController>(
      () => UserPastAppointmentsController(),
    );
  }
}
