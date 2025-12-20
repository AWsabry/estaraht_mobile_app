import 'package:get/get.dart';
import 'package:videocalling/features/doctor/finance/controllers/withdrawal_controller.dart';

class WithdrawalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WithdrawalController>(() => WithdrawalController());
  }
}

