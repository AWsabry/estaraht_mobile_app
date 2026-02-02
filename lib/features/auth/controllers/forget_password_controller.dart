import 'package:http/http.dart' as http;
import 'package:videocalling/core/config/app_imports.dart';

class ForgetPasswordController extends GetxController {
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
      // Call backend API for password reset request
      final response = await http
          .post(
            Uri.parse('https://backend.estaraht.com/api/auth/request-reset'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': emailTextField.text}),
          )
          .timeout(const Duration(seconds: 20));

      Get.back(); // Close loading dialog

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['resetLink'] != null) {
          final resetLink = responseData['data']['resetLink'];
          loggerNoStack.i(
            'Password reset requested successfully for: ${emailTextField.text}',
          );

          // Navigate to WebView with reset link
          Get.toNamed(
            '/reset-password-webview',
            arguments: {'url': resetLink, 'email': emailTextField.text},
          );
        } else {
          messageDialog('error'.tr, 'failed_to_send_email'.tr, 0);
          loggerNoStack.e('Invalid response format from backend');
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'failed_to_send_email'.tr;
        messageDialog('error'.tr, errorMessage, 0);
        loggerNoStack.e('Backend returned error: ${response.statusCode}');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      loggerNoStack.e('Error requesting password reset: $e');
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
