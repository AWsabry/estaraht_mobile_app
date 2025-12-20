import 'package:get/get.dart';
import 'package:videocalling/features/patient/doctors/controllers/indemand_doctors_controller.dart';

class InDemandeDoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IndemandDoctorController>(() => IndemandDoctorController());
  }
}
