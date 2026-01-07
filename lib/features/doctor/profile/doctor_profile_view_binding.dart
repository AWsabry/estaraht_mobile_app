import 'package:videocalling/core/config/app_imports.dart';

class DoctorProfileViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorProfileViewController>(
      () => DoctorProfileViewController(),
    );
  }
}
