import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/profile/controllers/profile_view_controller.dart';

class DoctorProfileViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorProfileViewController>(
      () => DoctorProfileViewController(),
    );
  }
}
