import 'package:get/get.dart';
import 'package:videocalling/features/patient/profile/controllers/profile_parameters_controller.dart';

class ProfileParametersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileParametersController>(() => ProfileParametersController());
  }
}

