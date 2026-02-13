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

      if (doctorId.value.isEmpty) {
        throw Exception('Doctor ID is empty');
      }

      // Add withdrawal to withdraws table (currency always USD)
      // MRU equivalent: 1 USD = 46.06 MRU
      const double usdToMruRate = 46.06;
      final totalAmountInMru = withdrawalAmount.value * usdToMruRate;

      // Insert withdrawal record
      await supabaseHelper.client.from('withdraws').insert({
        'doctor_id': doctorId.value,
        'total_amount': withdrawalAmount.value,
        'total_actual_amount': withdrawalAmount.value,
        'withrowl_history': withdrawalAmount.value,
        'income_history': 0,
        'action_type': 'withdrawal',
        'operation_status': 'waiting',
        'payment_date': TimezoneService.getCurrentMauritaniaTime()
            .toIso8601String(),
        'currency': 'USD',
        'total_amount_in_MRU': totalAmountInMru,
      });

      // Deduct withdrawal amount from doctor's wallet
      await _deductFromWallet(withdrawalAmount.value);

      isProcessing.value = false;

      loggerNoStack.i(
        '✅ Withdrawal request submitted: \$${withdrawalAmount.value.toStringAsFixed(2)}',
      );

      // Success - go back with result
      Get.back(result: {'success': true, 'amount': withdrawalAmount.value});
    } catch (e, stackTrace) {
      isProcessing.value = false;
      loggerNoStack.e('❌ Error submitting withdrawal: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

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

  /// Deduct withdrawal amount from doctor's wallet in doctors table
  Future<void> _deductFromWallet(double amount) async {
    try {
      loggerNoStack.i(
        '💰 Deducting \$${amount.toStringAsFixed(2)} from doctor wallet: ${doctorId.value}',
      );

      // Get current wallet value
      var doctorData = await supabaseHelper.client
          .from('doctors')
          .select('wallet, doctor_id')
          .eq('doctor_id', doctorId.value)
          .maybeSingle();

      // If not found by doctor_id, try by id (UUID)
      if (doctorData == null) {
        loggerNoStack.w(
          '⚠️ Doctor not found with doctor_id: ${doctorId.value}, trying id...',
        );
        doctorData = await supabaseHelper.client
            .from('doctors')
            .select('wallet, doctor_id')
            .eq('id', doctorId.value)
            .maybeSingle();
      }

      if (doctorData == null) {
        throw Exception(
          'Doctor not found with doctor_id or id: ${doctorId.value}',
        );
      }

      final currentWallet = (doctorData['wallet'] ?? 0.0) as num;
      final newWallet = (currentWallet.toDouble() - amount).clamp(0.0, double.infinity);
      final actualDoctorId = doctorData['doctor_id']?.toString() ?? doctorId.value;

      // Update wallet
      final updateResponse = await supabaseHelper.client
          .from('doctors')
          .update({'wallet': newWallet})
          .eq('doctor_id', actualDoctorId)
          .select('wallet');

      if (updateResponse.isEmpty) {
        throw Exception(
          'Failed to update wallet: No rows affected for doctor_id: $actualDoctorId',
        );
      }

      final updatedWallet = updateResponse[0]['wallet'] ?? 0.0;
      loggerNoStack.i(
        '✅ Doctor wallet updated: \$${currentWallet.toStringAsFixed(2)} → '
        '\$${updatedWallet.toStringAsFixed(2)} (- \$${amount.toStringAsFixed(2)})',
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error deducting from wallet: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      // Re-throw to ensure withdrawal insertion can be rolled back if needed
      rethrow;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
