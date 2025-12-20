import 'package:videocalling/core/config/app_imports.dart';

class ChangePassword extends GetView<DChangePasswordController> {
  final DChangePasswordController changePasswordController = Get.put(
    DChangePasswordController(),
  );

  ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'change_password_str'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Form(
                  key: changePasswordController.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Old password
                      Obx(
                        () => _buildTextField(
                          labelText: 'old_pwd'.tr,
                          isArabic: isArabic,
                          obscureText:
                              changePasswordController.passwordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              changePasswordController.passwordVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color:
                                  changePasswordController.passwordError1.value
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              changePasswordController.passwordVisible.value =
                                  !changePasswordController
                                      .passwordVisible
                                      .value;
                            },
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty) {
                              changePasswordController.oldPwdText.value = val;
                              changePasswordController.passwordError1.value =
                                  false;
                              changePasswordController.update();
                            }
                          },
                          errorText:
                              changePasswordController.passwordError1.value
                              ? 'old_pwd_error'.tr
                              : null,
                          hasError:
                              changePasswordController.passwordError1.value,
                          controller: changePasswordController.oldpassword,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // New password
                      Obx(
                        () => _buildTextField(
                          labelText: 'new_pwd'.tr,
                          isArabic: isArabic,
                          obscureText:
                              changePasswordController.passwordVisible1.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              changePasswordController.passwordVisible1.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color:
                                  changePasswordController.passwordError2.value
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              changePasswordController.passwordVisible1.value =
                                  !changePasswordController
                                      .passwordVisible1
                                      .value;
                            },
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty) {
                              changePasswordController.newPwdText.value = val;
                              changePasswordController.passwordError2.value =
                                  false;
                              changePasswordController.update();
                            }
                          },
                          errorText:
                              changePasswordController.passwordError2.value
                              ? changePasswordController.newPwd.value
                              : null,
                          hasError:
                              changePasswordController.passwordError2.value,
                          controller: changePasswordController.newpassword,
                        ),
                      ),

                      // Password length hint
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                          bottom: 16,
                          left: 8,
                          right: 8,
                        ),
                        child: Text(
                          "at_least_characters".trArgs(['$PASS_LENGTH']),
                          style: TextStyle(
                            fontSize: 12,
                            color: changePasswordController.passwordError2.value
                                ? Colors.red
                                : Colors.grey[600],
                            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                          ),
                        ),
                      ),

                      // Confirm password
                      Obx(
                        () => _buildTextField(
                          labelText: 'confirm_password'.tr,
                          isArabic: isArabic,
                          obscureText:
                              changePasswordController.passwordVisible2.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              changePasswordController.passwordVisible2.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color:
                                  changePasswordController.passwordError3.value
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              changePasswordController.passwordVisible2.value =
                                  !changePasswordController
                                      .passwordVisible2
                                      .value;
                            },
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty) {
                              changePasswordController.confPwdText.value = val;
                              changePasswordController.passwordError3.value =
                                  false;
                              changePasswordController.update();
                            }
                          },
                          errorText:
                              changePasswordController.passwordError3.value
                              ? changePasswordController.confPwd.value
                              : null,
                          hasError:
                              changePasswordController.passwordError3.value,
                          controller: changePasswordController.confirmpassword,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Action button at the bottom - same as signup style
          Padding(
            padding: const EdgeInsets.all(36),
            child: Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.focusScope?.unfocus();
                    changePasswordController.passwordError1.value = false;
                    changePasswordController.passwordError2.value = false;
                    changePasswordController.passwordError3.value = false;
                    changePasswordController.oldPwd.value = "";
                    changePasswordController.newPwd.value = "";
                    changePasswordController.confPwd.value = "";

                    if (changePasswordController.oldPwdText.value.isEmpty ||
                        changePasswordController.newPwdText.value.isEmpty ||
                        changePasswordController.confPwdText.value.isEmpty) {
                      if (changePasswordController.oldPwdText.value.isEmpty) {
                        changePasswordController.oldPwd.value =
                            'old_pwd_error'.tr;
                        changePasswordController.passwordError1.value = true;
                      }
                      if (changePasswordController.newPwdText.value.isEmpty) {
                        changePasswordController.newPwd.value =
                            'new_pwd_error'.tr;
                        changePasswordController.passwordError2.value = true;
                      }
                      if (changePasswordController.confPwdText.value.isEmpty) {
                        changePasswordController.confPwd.value =
                            'conf_pwd_error'.tr;
                        changePasswordController.passwordError3.value = true;
                      }
                    } else if (changePasswordController
                            .newPwdText
                            .value
                            .length <
                        PASS_LENGTH) {
                      changePasswordController.newPwd.value = 'password_error2'
                          .trParams({'length': '$PASS_LENGTH'});
                      changePasswordController.passwordError2.value = true;
                    } else if (changePasswordController.newPwdText.value !=
                        changePasswordController.confPwdText.value) {
                      changePasswordController.confPwd.value =
                          'password_error'.tr;
                      changePasswordController.passwordError3.value = true;
                    } else {
                      changePasswordController.changePassword();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF204FCF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: changePasswordController.isErrorInLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "change_password_str".tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required bool isArabic,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? prefixText,
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
      style: TextStyle(
        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
        color: hasError ? Colors.red : Colors.black,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixText: prefixText,
        prefixStyle: TextStyle(
          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        labelText: labelText,
        labelStyle: TextStyle(
          color: hasError ? Colors.red : Colors.grey[800],
          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        errorText: errorText,
        errorStyle: TextStyle(
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
