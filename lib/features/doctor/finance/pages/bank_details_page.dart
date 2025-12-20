import 'package:videocalling/core/config/app_imports.dart';

class BankDetailScreen extends GetView<BankDetailController> {
  final BankDetailController detailController = Get.put(BankDetailController());

  BankDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.LIGHT_GREY_SCREEN_BACKGROUND,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: CustomAppBar(
          onPressed: () => Get.back(),
          isBackArrow: true,
          title: 'bank_details'.tr,
          textStyle: Theme.of(context).textTheme.headlineSmall!.apply(
            color: Theme.of(context).colorScheme.background,
            fontWeightDelta: 5,
          ),
        ),
        leading: Container(),
      ),
      body: Obx(
        () => detailController.isError.value
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 100,
                      color: AppColors.LIGHT_GREY_TEXT,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'unable_to_load_data'.tr,
                      style: TextStyle(
                        fontFamily: AppFontStyleTextStrings.regular,
                      ),
                    ),
                  ],
                ),
              )
            : detailController.isLoaded.value
            ? Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            EditTextField(
                              editingController:
                                  detailController.accountNameController,
                              labelText: 'account_name'.tr,
                              errorText:
                                  detailController.isAccountNameError.value
                                  ? 'account_name_error'.tr
                                  : null,
                              onChanged: (val) {
                                detailController.accountName.value = val;
                                detailController.isAccountNameError.value =
                                    false;
                                detailController.update();
                              },
                            ),
                            const SizedBox(height: 3),
                            EditTextField(
                              keyboardType: TextInputType.number,
                              obscureText:
                                  !detailController.isAccountNumberShow.value,
                              editingController:
                                  detailController.accountNumberController,
                              labelText: 'account_number'.tr,
                              errorText:
                                  detailController.isAccountNumberError.value
                                  ? 'account_number_error'.tr
                                  : null,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  detailController.isAccountNumberShow.value =
                                      !detailController
                                          .isAccountNumberShow
                                          .value;
                                },
                                icon: Icon(
                                  detailController.isAccountNumberShow.value
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              onChanged: (val) {
                                detailController.accountNumber.value = val;
                                detailController.isAccountNumberError.value =
                                    false;
                                detailController.update();
                              },
                            ),
                            const SizedBox(height: 3),
                            EditTextField(
                              keyboardType: TextInputType.number,
                              obscureText: !detailController
                                  .isConfirmAccountNumberShow
                                  .value,
                              editingController: detailController
                                  .confirmAccountNumberController,
                              labelText: 'conf_account_number'.tr,
                              errorText:
                                  detailController
                                      .isConfirmAccountNumberError
                                      .value
                                  ? detailController
                                        .confirmAccountNumberErrorText
                                        .value
                                  : null,
                              onChanged: (val) {
                                detailController.confirmAccountNumber.value =
                                    val;
                                detailController
                                        .isConfirmAccountNumberError
                                        .value =
                                    false;
                                detailController.update();
                              },
                            ),
                            const SizedBox(height: 3),
                            EditTextField(
                              editingController:
                                  detailController.ifscCodeController,
                              labelText: 'account_ifsc'.tr,
                              errorText: detailController.isIfscCodeError.value
                                  ? 'account_ifsc_error'.tr
                                  : null,
                              onChanged: (val) {
                                detailController.ifscCode.value = val;
                                detailController.isIfscCodeError.value = false;
                                detailController.update();
                              },
                            ),
                            const SizedBox(height: 3),
                            EditTextField(
                              editingController:
                                  detailController.bankNameController,
                              labelText: 'bank_name'.tr,
                              errorText: detailController.isBankNameError.value
                                  ? 'bank_name_error'.tr
                                  : null,
                              onChanged: (val) {
                                detailController.bankName.value = val;
                                detailController.isBankNameError.value = false;
                                detailController.update();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      child: CustomButton(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          if (detailController
                              .bankNameController
                              .text
                              .isEmpty) {
                            detailController.isBankNameError.value = true;
                          } else if (detailController
                              .accountNumberController
                              .text
                              .isEmpty) {
                            detailController.isAccountNumberError.value = true;
                          } else if (detailController
                              .confirmAccountNumberController
                              .text
                              .isEmpty) {
                            detailController.isConfirmAccountNumberError.value =
                                true;
                            detailController
                                    .confirmAccountNumberErrorText
                                    .value =
                                "Enter confirm account number";
                          } else if (detailController
                              .ifscCodeController
                              .text
                              .isEmpty) {
                            detailController.isIfscCodeError.value = true;
                          } else if (detailController
                              .accountNameController
                              .text
                              .isEmpty) {
                            detailController.isAccountNameError.value = true;
                          } else if (detailController
                                  .accountNumberController
                                  .text !=
                              detailController
                                  .confirmAccountNumberController
                                  .text) {
                            detailController.isConfirmAccountNumberError.value =
                                true;
                            detailController
                                    .confirmAccountNumberErrorText
                                    .value =
                                "Account number Not Matched!";
                          } else {
                            detailController.updateBankDetails();
                          }
                        },
                        btnText: 'update_bank_details'.tr,
                      ),
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
