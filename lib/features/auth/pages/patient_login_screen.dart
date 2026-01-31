import 'package:videocalling/core/config/app_imports.dart';
// ignore: undefined_hidden_name

class LoginAsUser extends GetView<UserLoginController> {
  final UserLoginController loginController = Get.put(UserLoginController());

  LoginAsUser({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    final bool isArabic = languageController.currentLanguage.value == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(48, isArabic ? 60 : 72, 48, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      // const SizedBox(height: 20),
                      // Hero(
                      //   tag: 'app_logo',
                      //   child: SvgPicture.asset(
                      //     AppImages.splashIcon,
                      //     height: 40,
                      //     color: const Color(
                      //         0xFF204FCF), // Blue color for the logo
                      //   ),
                      // ),
                      const SizedBox(height: 78),
                      Text(
                        "login".tr,
                        style: CustomTextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "communicate_with_your_doctor".tr,
                        style: CustomTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                isArabic
                    ? const SizedBox(height: 90)
                    : const SizedBox(height: 100),

                // Email/Username input
                Obx(
                  () => _buildTextField(
                    labelText: "email_or_phone".tr,
                    isArabic: isArabic,
                    keyboardType: TextInputType.text,
                    onChanged: (val) {
                      // Detect if input is phone number or email
                      if (RegExp(r'^\d+$').hasMatch(val)) {
                        // It's a phone number
                        loginController.phoneNumber.value = val;
                        loginController.emailController.text = '';
                      } else {
                        // It's an email
                        loginController.emailController.text = val;
                        loginController.phoneNumber.value = '';
                      }
                      loginController.isPhoneNumberError.value = false;
                    },
                    errorText: loginController.isPhoneNumberError.value
                        ? 'enter_valid_email_or_phone'.tr
                        : null,
                    hasError: loginController.isPhoneNumberError.value,
                  ),
                ),

                const SizedBox(height: 16),

                // Password input
                Obx(
                  () => _buildTextField(
                    labelText: "password".tr,
                    isArabic: isArabic,
                    obscureText: loginController.passwordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        loginController.passwordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: loginController.isPasswordError.value
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: () {
                        loginController.passwordVisible.value =
                            !loginController.passwordVisible.value;
                      },
                    ),
                    prefixIcon: loginController.isPasswordError.value
                        ? const Icon(Icons.error_outline, color: Colors.red)
                        : null,
                    onChanged: (val) {
                      loginController.passwordController.text = val;
                      loginController.isPasswordError.value = false;
                    },
                    errorText: loginController.isPasswordError.value
                        ? loginController.passErrorText.value
                        : null,
                    hasError: loginController.isPasswordError.value,
                  ),
                ),

                const SizedBox(height: 46),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.focusScope?.unfocus();
                      print(
                        'the email ${loginController.emailController.text}',
                      );
                      loginController.login();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF204FCF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'login'.tr,
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

                // Forgot password button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Get.toNamed(
                        Routes.forgetPasswordScreen,
                        arguments: {"id": "1"},
                      );
                      Get.delete<ForgetPasswordController>();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[500]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'forgot_password'.tr,
                      style: CustomTextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 46),

                // Account creation option
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'not_have_an_account'.tr,
                        style: CustomTextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Get.toNamed(Routes.patientRegisterScreen);
                          Get.delete<RegisterPatientController>();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'register_now'.tr,
                          style: CustomTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF204FCF),
                            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Privacy notice
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 20, bottom: 20),
                //     child: Text(
                //       "*We will not disclose your personal\ninformation to any third party.",
                //       textAlign: TextAlign.center,
                //       style: CustomTextStyle(
                //         fontSize: 12,
                //         color: Colors.black,
                //         fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
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
  }) {
    return TextField(
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
