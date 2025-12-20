import 'package:get/get.dart';
import 'package:videocalling/features/patient/payment/controllers/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentController>(() => PaymentController());
  }
}

