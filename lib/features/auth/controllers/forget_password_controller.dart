import 'package:videocalling/core/config/app_imports.dart';

class ForgetPasswordController extends GetxController {
  FirebaseHelper firebaseHelper = FirebaseHelper();

  String id = Get.arguments['id'];

  TextEditingController emailTextField = TextEditingController();
  RxBool isEmailError = false.obs;
  RxString emailError = "".obs;

  sendEmail() async {
    // Validate email format
    if (!_isValidEmail(emailTextField.text)) {
      messageDialog('error'.tr, 'please_enter_valid_email'.tr, 0);
      return;
    }

    customDialog1(s1: 'loading'.tr, s2: 'please_wait_while_processing'.tr);

    try {
      // Use custom password reset email template
      final success = await firebaseHelper
          .sendPasswordResetEmailWithCustomTemplate(emailTextField.text);

      Get.back(); // Close loading dialog

      if (success) {
        messageDialog('success'.tr, 'password_reset_email_sent'.tr, 1);
        loggerNoStack.i(
          'Firebase password reset email sent successfully to: ${emailTextField.text}',
        );
      } else {
        messageDialog('error'.tr, 'failed_to_send_email'.tr, 0);
        loggerNoStack.e('Failed to send Firebase password reset email');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      loggerNoStack.e('Error sending Firebase password reset email: $e');
      messageDialog('error'.tr, 'failed_to_send_email'.tr, 0);
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  messageDialog(String s1, String s2, int i) {
    customDialog(
      s1: s1,
      s2: s2,
      onPressed: () async {
        if (i == 1 && id == "1") {
          Get.back();
          Get.back();
        } else if (i == 1 && id == "2") {
          Get.back();
          Get.back();
        } else {
          Get.back();
        }
      },
      s3style: CustomTextStyle(
        fontFamily: AppFontStyleTextStrings.medium,
        color: AppColors.BLACK,
      ),
    );
  }
}
