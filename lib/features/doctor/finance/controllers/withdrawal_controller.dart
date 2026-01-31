import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class WithdrawalController extends GetxController {
  final supabaseHelper = SupabaseHelper();
  final TextEditingController amountController = TextEditingController();

  RxDouble totalBalance = 0.0.obs;
  RxDouble withdrawalAmount = 0.0.obs;
  RxDouble remainingBalance = 0.0.obs;
  RxBool isProcessing = false.obs;
  RxString doctorId = "".obs;

  @override
  void onInit() {
    super.onInit();

    // Get total balance from arguments
    totalBalance.value = Get.arguments?['totalBalance'] ?? 0.0;
    remainingBalance.value = totalBalance.value;

    // Get doctor ID from storage
    doctorId.value =
        StorageService.readData(key: LocalStorageKeys.userId) ?? "";

    // Listen to amount changes
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    withdrawalAmount.value = double.tryParse(amountController.text) ?? 0.0;
    remainingBalance.value = totalBalance.value - withdrawalAmount.value;
  }

  bool get isValidAmount {
    return withdrawalAmount.value > 0 &&
        withdrawalAmount.value <= totalBalance.value;
  }

  void processWithdrawal() {
    // Validation
    if (withdrawalAmount.value <= 0) {
      Get.snackbar(
        'error'.tr,
        'please_enter_valid_amount'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (withdrawalAmount.value > totalBalance.value) {
      Get.snackbar(
        'error'.tr,
        'insufficient_balance'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('confirm_withdrawal'.tr),
        content: Text(
          'confirm_withdrawal_message'.trParams({
            'amount': '\$${withdrawalAmount.value.toStringAsFixed(2)}',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: CustomTextStyle(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              submitWithdrawal();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.color1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'confirm'.tr,
              style: const CustomTextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void submitWithdrawal() async {
    try {
      isProcessing.value = true;

      // Add withdrawal to withdraws table only
      await supabaseHelper.client.from('withdraws').insert({
        'doctor_id': doctorId.value,
        'total_amount': withdrawalAmount.value,
        'total_actual_amount': withdrawalAmount.value,
        'withrowl_history': withdrawalAmount.value,
        'income_history': 0,
        'action_type': 'withrowl',
        'operation_status': 'waiting',
        'payment_date': TimezoneService.getCurrentMauritaniaTime()
            .toIso8601String(),
      });

      isProcessing.value = false;

      // Success - go back with result
      Get.back(result: {'success': true, 'amount': withdrawalAmount.value});
    } catch (e) {
      isProcessing.value = false;
      loggerNoStack.e('Error submitting withdrawal: $e');

      // Show error snackbar (still on this page)
      Get.snackbar(
        'error'.tr,
        'withdrawal_request_failed'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
