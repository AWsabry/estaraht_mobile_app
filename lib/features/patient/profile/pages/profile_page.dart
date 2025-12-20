import 'package:videocalling/core/config/app_imports.dart';
class UserEditProfile extends GetView<UserEditController> {
  final UserEditController editController = Get.put(UserEditController());

   UserEditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'edit_profile'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          padding: const EdgeInsets.only(right: 16),
          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => editController.isLoaded.value
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF204FCF)),
              ),
            )
          : _buildProfileForm(context, isArabic)),
    );
  }

  Widget _buildProfileForm(BuildContext context, bool isArabic) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Profile image section
                  _buildProfileImageSection(context),
                  const SizedBox(height: 32),

                  // Form fields
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          context: context,
                          labelText: 'enter_name'.tr,
                          controller: editController.nameController,
                          errorText: editController.isNameError.value
                              ? 'enter_name'.tr
                              : null,
                          hasError: editController.isNameError.value,
                          isArabic: isArabic,
                          onChanged: (val) {
                            editController.name.value = val;
                            editController.isNameError.value = false;
                            editController.update();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          context: context,
                          labelText: 'enter_number'.tr,
                          controller: editController.phoneController,
                          keyboardType: TextInputType.phone,
                          errorText: editController.isPhoneNumberError.value
                              ? editController.phnNumberError.value
                              : null,
                          hasError: editController.isPhoneNumberError.value,
                          isArabic: isArabic,
                          onChanged: (val) {
                            editController.phoneNumber.value = val;
                            editController.isPhoneNumberError.value = false;
                            editController.update();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          context: context,
                          labelText: 'enter_email_hint'.tr,
                          controller: editController.emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: editController.isEmailError.value
                              ? 'enter_email_error'.tr
                              : null,
                          hasError: editController.isEmailError.value,
                          isArabic: isArabic,
                          onChanged: (val) {
                            editController.email.value = val;
                            editController.isEmailError.value = false;
                            editController.update();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          context: context,
                          labelText: 'password'.tr,
                          controller: editController.passController,
                          obscureText: true,
                          errorText: editController.isPassError.value
                              ? 'password_not_match'.tr
                              : null,
                          hasError: editController.isPassError.value,
                          isArabic: isArabic,
                          onChanged: (val) {
                            editController.password.value = val;
                            editController.isPassError.value = false;
                            editController.update();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          context: context,
                          labelText: 'confirm_password'.tr,
                          controller: editController.confirmController,
                          obscureText: true,
                          errorText: editController.isPassError.value
                              ? 'password_not_match'.tr
                              : null,
                          hasError: editController.isPassError.value,
                          isArabic: isArabic,
                          onChanged: (val) {
                            editController.confirmPassword.value = val;
                            editController.isPassError.value = false;
                            editController.update();
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom update button
          Container(
            padding: const EdgeInsets.fromLTRB(36, 16, 36, 36),
            child: InkWell(
              onTap: () {
                Get.focusScope?.unfocus();
                editController.registerUser();
              },
              borderRadius: BorderRadius.circular(8),
              child: Ink(
                decoration: BoxDecoration(
                  color: const Color(0xFF204FCF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: Text(
                    'update'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildProfileImageSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              // Profile image container
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF204FCF).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Obx(() => ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: editController.image != null ||
                              editController.isImageSelected.value
                          ? Image.file(
                              editController.image!,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: editController.profileImage,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                            ),
                    )),
              ),

              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => editController.getImage(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF204FCF),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'profile_photo'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String labelText,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    bool hasError = false,
    required bool isArabic,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
        fontSize: 16,
      ),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelText: labelText,
        labelStyle: TextStyle(
          color: hasError ? Colors.red : Colors.grey[700],
          fontSize: 15,
          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
        ),
        errorText: errorText,
        errorStyle: TextStyle(
          fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey[400]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.grey[400]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? Colors.red : const Color(0xFF204FCF),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
    );
  }
}
