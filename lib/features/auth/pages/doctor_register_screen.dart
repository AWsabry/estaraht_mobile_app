import 'package:videocalling/core/config/app_imports.dart';

class RegisterAsDoctor extends GetView<DoctorRegisterController> {
  const RegisterAsDoctor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final registerController = Get.put(DoctorRegisterController());
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    return Scaffold(
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
                          "create_doctor_account_title".tr,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "connect_with_your_patient".tr,
                          style: TextStyle(
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

                  // Email field
                  Obx(
                    () => _buildTextField(
                      labelText: "email".tr,
                      isArabic: isArabic,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) {
                        registerController.email.value = val;
                        registerController.isEmailError.value = false;
                      },
                      errorText: registerController.isEmailError.value
                          ? "email_invalid".tr
                          : null,
                      hasError: registerController.isEmailError.value,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Country code dropdown + Phone number field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country code dropdown
                      Obx(
                        () => Container(
                          width: 100,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: registerController.selectedCountryCode.value,
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              items: registerController.supportedCountries.map((country) {
                                return DropdownMenuItem<String>(
                                  value: country['code'],
                                  child: Text(
                                    '${country['flag']} ${country['code']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  final country = registerController.supportedCountries
                                      .firstWhere((c) => c['code'] == value);
                                  registerController.setCountryCode(
                                    value,
                                    country['name'] ?? '',
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Phone number field
                      Expanded(
                        child: Obx(
                          () => _buildTextField(
                            labelText: "mobile_number".tr,
                            isArabic: isArabic,
                            keyboardType: TextInputType.phone,
                            onChanged: (val) {
                              registerController.phoneNumber.value = val;
                              registerController.isPhoneNumberError.value = false;
                            },
                            errorText: registerController.isPhoneNumberError.value
                                ? registerController.phnNumberError.value
                                : null,
                            hasError: registerController.isPhoneNumberError.value,
                          ),
                        ),
                      ),
                    ],
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

                  // Password hint
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                      bottom: 16,
                      left: 8,
                      right: 8,
                    ),
                    child: Text(
                      "at_least_characters".trArgs(['8']),
                      style: TextStyle(
                        fontSize: 12,
                        color: registerController.isPassError.value
                            ? Colors.red
                            : Colors.grey[600],
                        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
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
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Obx(
                          () => Container(
                            height: isArabic ? 64 : 54,
                            padding: const EdgeInsets.only(
                              left: 8,
                              top: 4,
                              right: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: registerController.isGenderError.value
                                    ? Colors.red
                                    : Colors.grey[500]!,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                border: InputBorder.none,
                                labelText: "gender".tr,
                                labelStyle: TextStyle(
                                  color: registerController.isGenderError.value
                                      ? Colors.red
                                      : Colors.grey[800],
                                  fontFamily: isArabic
                                      ? 'NotoKufiArabic'
                                      : 'Roboto',
                                ),
                              ),
                              isExpanded: true,
                              value: registerController.gender.value.isEmpty
                                  ? null
                                  : registerController.gender.value,
                              items: registerController.genderOptions.map((
                                String value,
                              ) {
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
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  registerController.gender.value = newValue;
                                  registerController.isGenderError.value =
                                      false;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  /// Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        /// Validate and submit form
                        if (registerController.validateForm()) {
                          registerController.registerUserWithSupabase();
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
                              Get.off(() => LoginAsDoctor());
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
                            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
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
    );
  }

  // Updated helper method with prefixText parameter
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
    return TextField(
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
