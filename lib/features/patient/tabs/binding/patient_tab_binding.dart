import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:videocalling/features/patient/appointments/controllers/appointments_list_controller.dart';
import 'package:videocalling/features/patient/doctors/controllers/indemand_doctors_controller.dart';
import 'package:videocalling/features/patient/home/controllers/home_controller.dart';
import 'package:videocalling/features/patient/more/controllers/more_controller.dart';
import 'package:videocalling/features/patient/payment_plans/controllers/payment_plans_controller.dart';
import 'package:videocalling/features/patient/tabs/controllers/tabs_controller.dart';

class PatientTabsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PatientTabController());

    Get.lazyPut<UserHomeController>(() => UserHomeController());
    Get.lazyPut<IndemandDoctorController>(() => IndemandDoctorController());
    Get.lazyPut<UAllAppointmentsController>(() => UAllAppointmentsController());
    Get.lazyPut<PaymentPlansController>(() => PaymentPlansController());
    Get.lazyPut<PatientMoreScreenController>(
      () => PatientMoreScreenController(),
    );
  }
}
