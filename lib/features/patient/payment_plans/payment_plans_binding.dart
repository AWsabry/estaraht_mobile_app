import 'package:get/get.dart';
import 'package:videocalling/features/patient/payment_plans/controllers/payment_plans_controller.dart';

class PaymentPlansBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentPlansController>(
      () => PaymentPlansController(),
    );
  }
}
