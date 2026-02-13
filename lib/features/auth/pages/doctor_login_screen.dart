import 'package:videocalling/core/config/app_imports.dart';

class LoginAsDoctor extends GetView<DoctorLoginController> {
  final DoctorLoginController doctorLoginController = Get.put(
    DoctorLoginController(),
  );

  LoginAsDoctor({super.key});

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
                        "connect_with_your_patient".tr,
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

                // Email input
                Obx(
                  () => _buildTextField(
                    labelText: "email".tr,
                    isArabic: isArabic,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {
                      doctorLoginController.emailAddress.value = val;
                      doctorLoginController.isEmailError.value = false;
                    },
                    errorText: doctorLoginController.isEmailError.value
                        ? 'enter_email_error'.tr
                        : null,
                    hasError: doctorLoginController.isEmailError.value,
                  ),
                ),

                const SizedBox(height: 16),

                // Password input
                Obx(
                  () => _buildTextField(
                    labelText: "password".tr,
                    isArabic: isArabic,
                    obscureText: doctorLoginController.passwordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        doctorLoginController.passwordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: doctorLoginController.isPasswordError.value
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: () {
                        doctorLoginController.passwordVisible.value =
                            !doctorLoginController.passwordVisible.value;
                      },
                    ),
                    prefixIcon: doctorLoginController.isPasswordError.value
                        ? const Icon(Icons.error_outline, color: Colors.red)
                        : null,
                    onChanged: (val) {
                      doctorLoginController.pass.value = val;
                      doctorLoginController.isPasswordError.value = false;
                    },
                    errorText: doctorLoginController.isPasswordError.value
                        ? doctorLoginController.passErrorText.value
                        : null,
                    hasError: doctorLoginController.isPasswordError.value,
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
                      doctorLoginController.login();
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
                        arguments: {"id": "2"},
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
                        onPressed: () {
                          Get.toNamed(Routes.doctorRegisterScreen);
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
