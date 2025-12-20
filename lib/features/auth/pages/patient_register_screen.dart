import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';

class RegisterAsPatient extends GetView<RegisterPatientController> {
  const RegisterAsPatient({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final registerController = Get.put(RegisterPatientController());
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(48, isArabic ? 60 : 72, 48, 0),
              child: Form(
                key: registerController.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "create_account_title".tr,
                            style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: isArabic
                                  ? 'NotoKufiArabic'
                                  : 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6.0.h),
                          Text(
                            "journey_begins_here".tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: isArabic
                                  ? 'NotoKufiArabic'
                                  : 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    isArabic
                        ? const SizedBox(height: 28)
                        : const SizedBox(height: 72),

                    // Full name field
                    Obx(
                      () => _buildTextField(
                        labelText: "full_name".tr,
                        isArabic: isArabic,
                        onChanged: (val) {
                          registerController.name.value = val;
                          registerController.isNameError.value = false;
                        },
                        errorText: registerController.isNameError.value
                            ? "name_required".tr
                            : null,
                        hasError: registerController.isNameError.value,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Combined Email or Phone Number field
                    Obx(
                      () => _buildTextField(
                        labelText: "email_or_phone".tr,
                        isArabic: isArabic,
                        keyboardType: TextInputType.text,
                        onChanged: (val) {
                          registerController.emailOrPhone.value = val;
                          registerController.isEmailOrPhoneError.value = false;
                        },
                        errorText: registerController.isEmailOrPhoneError.value
                            ? registerController.emailOrPhoneError.value
                            : null,
                        hasError: registerController.isEmailOrPhoneError.value,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password field with visible error state as in screenshot
                    Obx(
                      () => _buildTextField(
                        labelText: "password".tr,
                        isArabic: isArabic,
                        obscureText: registerController.passwordVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            registerController.passwordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: registerController.isPassError.value
                                ? Colors.red
                                : Colors.grey,
                          ),
                          onPressed: () {
                            registerController.passwordVisible.value =
                                !registerController.passwordVisible.value;
                          },
                        ),
                        prefixIcon: registerController.isPassError.value
                            ? const Icon(Icons.error_outline, color: Colors.red)
                            : null,
                        onChanged: (val) {
                          registerController.password.value = val;
                          registerController.isPassError.value = false;
                        },
                        errorText: registerController.isPassError.value
                            ? "password_invalid".tr
                            : null,
                        hasError: registerController.isPassError.value,
                        borderColor: registerController.isPassError.value
                            ? Colors.red
                            : null,
                      ),
                    ),

                    // Password hint - only show when there's no error
                    Obx(
                      () => registerController.isPassError.value
                          ? SizedBox(
                              height: 16.0.h,
                            ) // Maintain spacing when error appears
                          : Padding(
                              padding: EdgeInsets.only(
                                top: 4.0.h,
                                bottom: 16.0.h,
                                right: 8.0.w,
                              ),
                              child: Text(
                                "at_least_characters".trArgs(['8']),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontFamily: isArabic
                                      ? 'NotoKufiArabic'
                                      : 'Roboto',
                                ),
                              ),
                            ),
                    ),

                    // Age and Gender in a row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Obx(
                            () => _buildTextField(
                              labelText: "age".tr,
                              isArabic: isArabic,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                registerController.age.value = val;
                                registerController.isAgeError.value = false;
                              },
                              errorText: registerController.isAgeError.value
                                  ? "age_required".tr
                                  : null,
                              hasError: registerController.isAgeError.value,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0.w),
                        Expanded(
                          flex: 3,
                          child: Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: isArabic ? 64 : 54,
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    top: 4,
                                    right: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          registerController.isGenderError.value
                                          ? Colors.red
                                          : Colors.grey[500]!,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                      border: InputBorder.none,
                                      labelText: "gender".tr,
                                      labelStyle: TextStyle(
                                        color:
                                            registerController
                                                .isGenderError
                                                .value
                                            ? Colors.red
                                            : Colors.grey[800],
                                        fontFamily: isArabic
                                            ? 'NotoKufiArabic'
                                            : 'Roboto',
                                      ),
                                    ),
                                    isExpanded: true,
                                    value:
                                        registerController.gender.value.isEmpty
                                        ? null
                                        : registerController.gender.value,
                                    items: registerController.genderOptions.map(
                                      (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value.tr,
                                            style: TextStyle(
                                              fontFamily: isArabic
                                                  ? 'NotoKufiArabic'
                                                  : 'Roboto',
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        registerController.gender.value =
                                            newValue;
                                        registerController.isGenderError.value =
                                            false;
                                      }
                                    },
                                  ),
                                ),
                                // Error message for gender
                                if (registerController.isGenderError.value)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4.0.h),
                                    child: Text(
                                      "gender_required".tr,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.red,
                                        fontFamily: isArabic
                                            ? 'NotoKufiArabic'
                                            : 'Roboto',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: registerController.isGenderError.value
                          ? 8.0.h
                          : 32.0.h,
                    ),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate and submit form
                          if (registerController.validateForm()) {
                            registerController.registerUser();
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
                          "register_button".tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Bottom text for "Already have an account"
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${"have_account".tr} ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontFamily: isArabic
                                    ? 'NotoKufiArabic'
                                    : 'Roboto',
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.offAllNamed(
                                  Routes.loginUserScreen,
                                  arguments: {'isFromOnboarding': false},
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "login_link".tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF204FCF),
                                  fontFamily: isArabic
                                      ? 'NotoKufiArabic'
                                      : 'Roboto',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            "privacy_notice".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontFamily: isArabic
                                  ? 'NotoKufiArabic'
                                  : 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated helper method with prefixText parameter for the "+222" prefix
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
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
            // Remove errorText from InputDecoration to use custom error display
            errorText: null,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color:
                    borderColor ?? (hasError ? Colors.red : Colors.grey[700]!),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color:
                    borderColor ?? (hasError ? Colors.red : Colors.grey[500]!),
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
        ),
        // Custom error message aligned with text field start
        if (hasError && errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.0.h),
            child: Text(
              errorText,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red,
                fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
              ),
            ),
          ),
      ],
    );
  }
}
