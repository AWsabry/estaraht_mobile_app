import 'package:videocalling/core/config/app_imports.dart';

class ForgetPassword extends GetView<ForgetPasswordController> {
  ForgetPasswordController forgetPasswordController = Get.put(
    ForgetPasswordController(),
  );

  ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   // leading: IconButton(
      //   //   icon: Icon(
      //   //     Icons.arrow_back_ios,
      //   //     color: Colors.black,
      //   //     size: 20,
      //   //   ),
      //   //   onPressed: () => Get.back(),
      //   // ),
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(48, isArabic ? 32 : 40, 48, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo and title section
            Center(
              child: Column(
                children: [
                  // // App logo
                  // SvgPicture.asset(
                  //   AppImages.splashIcon,
                  //   height: 40,
                  //   color: const Color(0xFF204FCF),
                  // ),
                  const SizedBox(height: 92),
                  Text(
                    "forgot_password".tr,
                    style: CustomTextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "forget_password_enter_email".tr,
                    style: CustomTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "we_will_email_a_password_reset_link".tr,
                    style: CustomTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            isArabic ? const SizedBox(height: 60) : const SizedBox(height: 70),

            // Email input field
            Obx(
              () => _buildTextField(
                labelText: "enter_email_hint".tr,
                isArabic: isArabic,
                keyboardType: TextInputType.emailAddress,
                controller: forgetPasswordController.emailTextField,
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    forgetPasswordController.isEmailError.value = false;
                  }
                },
                errorText: forgetPasswordController.isEmailError.value
                    ? forgetPasswordController.emailError.value
                    : null,
                hasError: forgetPasswordController.isEmailError.value,
              ),
            ),

            const SizedBox(height: 46),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.focusScope?.unfocus();
                  if (forgetPasswordController.emailTextField.text.isEmpty) {
                    forgetPasswordController.isEmailError.value = true;
                    forgetPasswordController.emailError.value =
                        'enter_email_hint'.tr;
                  } else if (GetUtils.isEmail(
                        forgetPasswordController.emailTextField.text,
                      ) ==
                      false) {
                    forgetPasswordController.isEmailError.value = true;
                    forgetPasswordController.emailError.value =
                        'enter_email_error'.tr;
                  } else {
                    forgetPasswordController.sendEmail();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF204FCF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'btn_submit'.tr,
                  style: CustomTextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Return to login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[500]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'back_to_login'.tr,
                  style: CustomTextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper method to build text fields with consistent style and error handling
  Widget _buildTextField({
    required String labelText,
    required bool isArabic,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    Widget? prefixIcon,
    required Function(String) onChanged,
    String? errorText,
    bool hasError = false,
    Color? borderColor,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: CustomTextStyle(
        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
        color: hasError ? Colors.red : Colors.black,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelText: labelText,
        labelStyle: CustomTextStyle(
          color: hasError ? Colors.red : Colors.grey[800],
          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        errorText: errorText,
        errorStyle: CustomTextStyle(
          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: borderColor ?? (hasError ? Colors.red : Colors.grey[700]!),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: borderColor ?? (hasError ? Colors.red : Colors.grey[500]!),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color:
                borderColor ??
                (hasError ? Colors.red : const Color(0xFF204FCF)),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
