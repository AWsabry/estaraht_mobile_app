import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/finance/models/bank_detail_model.dart';

class BankDetailController extends GetxController {
  RxString doctorId = "".obs;
  RxBool isLoaded = false.obs;
  RxBool isError = false.obs;

  TextEditingController accountNameController = TextEditingController();
  RxBool isAccountNameError = false.obs;
  RxString accountName = "".obs;

  TextEditingController accountNumberController = TextEditingController();
  RxBool isAccountNumberError = false.obs;
  RxBool isAccountNumberShow = false.obs;
  RxString accountNumber = "".obs;

  TextEditingController confirmAccountNumberController =
      TextEditingController();
  RxBool isConfirmAccountNumberError = false.obs;
  RxBool isConfirmAccountNumberShow = true.obs;
  RxString confirmAccountNumber = "".obs;
  RxString confirmAccountNumberErrorText = "".obs;

  TextEditingController bankNameController = TextEditingController();
  RxBool isBankNameError = false.obs;
  RxString bankName = "".obs;

  TextEditingController ifscCodeController = TextEditingController();
  RxBool isIfscCodeError = false.obs;
  RxString ifscCode = "".obs;

  getBankDetails() async {
    isLoaded.value = false;
    isError.value = false;
    final response = await post(
      Uri.parse("${Apis.ServerAddress}/api/get_bankdetails"),
      body: {'doctor_id': doctorId.value},
    ).timeout(const Duration(seconds: Apis.timeOut));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['msg'] == "Doctors Bank Details") {
        getResponse = GetBankDetails.fromJson(jsonDecode(response.body));
        bankNameController.text = bankName.value =
            getResponse.data!.bankName != null
            ? getResponse.data!.bankName.toString()
            : "";
        accountNameController.text = accountName.value =
            getResponse.data!.accountHolderName != null
            ? getResponse.data!.accountHolderName.toString()
            : "";
        accountNumberController.text = accountNumber.value =
            getResponse.data!.accountNo != null
            ? getResponse.data!.accountNo.toString()
            : "";
        confirmAccountNumberController.text = confirmAccountNumber.value =
            getResponse.data!.accountNo != null
            ? getResponse.data!.accountNo.toString()
            : "";
        ifscCodeController.text = ifscCode.value =
            getResponse.data!.ifscCode != null
            ? getResponse.data!.ifscCode.toString()
            : "";
      } else {
        isError.value = true;
        messageDialog('error'.tr, "${jsonDecode(response.body)['msg']}");
      }

      isLoaded.value = true;
    } else {
      isError.value = true;
      messageDialog('error'.tr, "${response.reasonPhrase}");
    }
    Client().close();
  }

  updateBankDetails() async {
    customDialog1(
      s1: 'reporting_dialog1'.tr,
      s2: 'update_bank_details_dialog'.tr,
    );
    final response = await post(
      Uri.parse("${Apis.ServerAddress}/api/add_bankdetails"),
      body: {
        'doctor_id': doctorId.value,
        'bank_name': bankName.value,
        'ifsc_code': ifscCode.value,
        'account_no': accountNumber.value,
        'account_holder_name': accountName.value,
      },
    ).timeout(const Duration(seconds: Apis.timeOut));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['msg'].toString() !=
          "Doctors Bank Details Add Successfully") {
        Get.back();
        messageDialog('error'.tr, "${jsonDecode(response.body)['msg']}");
      } else {
        Get.back();
        updateResponse = UpdateBankDetails.fromJson(jsonDecode(response.body));
        messageDialog('success'.tr, 'update_bank_details_success'.tr);
      }

      isLoaded.value = true;
    } else {
      Get.back();
      messageDialog('error'.tr, "${response.reasonPhrase}");
    }
    Client().close();
  }

  messageDialog(String s1, String s2) {
    customDialog(
      s1: s1,
      s2: s2,
      onPressed: () {
        if (s1 == 'error'.tr) {
          Get.back();
        } else {
          Get.back();
          Get.back();
        }
      },
    );
  }

  UpdateBankDetails updateResponse = UpdateBankDetails();
  GetBankDetails getResponse = GetBankDetails();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    doctorId.value =
        StorageService.readData(key: LocalStorageKeys.userId) ?? "";
    getBankDetails();
  }
}
