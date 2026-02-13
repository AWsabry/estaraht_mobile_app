import 'package:videocalling/core/config/app_imports.dart';

class DoctorProfile extends GetView<DoctorProfileController> {
  final DoctorProfileController profileController = Get.put(
    DoctorProfileController(),
  );

  DoctorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: profileController.onWillPopScope,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Obx(
            () => Text(
              profileController
                  .pageTitle
                  .value, // Use dynamic title based on flow
              style: const CustomTextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          centerTitle: false,
          leading: Obx(
            () => profileController.isFromRegistration.value
                ? Container() // No back button for registration flow
                : IconButton(
                    padding: const EdgeInsets.only(left: 16),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 18,
                    ),
                    onPressed: () => Get.back(),
                  ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: Container(),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Main Content Area
                Obx(
                  () => profileController.isErrorInLoading.value
                      ? _buildErrorState()
                      : (profileController.isProfileLoaded.value)
                      ? FutureBuilder(
                          future: profileController.future,
                          builder: (context, snapshot) {
                            print("Loading future...  0 here");
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                profileController.future == null ||
                                profileController.future2 == null) {
                              print("Loading future...  1 here");

                              return _buildLoadingState(context);
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              print("Loading future...  2 here");
                              return _buildStepContent(context);
                            } else {
                              print("Loading future...  3 here");
                              return _buildLoadingState(context);
                            }
                          },
                        )
                      : _buildLoadingState(context),
                ),
              ],
            ),

            // Bottom Button
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(BuildContext context, int step, String label) {
    bool isActive = profileController.index.value >= step;
    bool isCurrent = profileController.index.value == step;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.color1 : Colors.grey[200],
        border: Border.all(
          color: isCurrent ? AppColors.color1 : Colors.transparent,
          width: isCurrent ? 2 : 0,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: CustomTextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressLine(BuildContext context, bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.color1 : Colors.grey[300],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'unable_to_load_data'.tr,
              style: CustomTextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => profileController.retryLoading(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.color1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'retry'.tr,
                style: const CustomTextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.color1),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'loading_profile'.tr,
              style: CustomTextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    return Expanded(
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Stack(
            children: [
              Visibility(
                visible: profileController.index.value == 0,
                child: profileController.step1(context: context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Row(
          children: [
            // Next/Update/Complete button with dynamic text
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () => _handleNextButtonPress(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'update'.tr,
                  style: const CustomTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNextButtonPress(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (profileController.index.value == 0) {
      if ((profileController.doctorProfileDetails?.data?.image ==
                  "profile.png" ||
              profileController.doctorProfileDetails?.data?.image ==
                  "user.png") &&
          profileController.sImage == null) {
        _showErrorToast('please_select_image'.tr);
      } else if (profileController.nameController.text.isEmpty) {
        profileController.isNameError.value = true;
      } else if (profileController.phoneController.text.length < PHONE_LENGTH) {
        profileController.isPhoneError.value = true;
      } else if (profileController.selectedValue.value == null) {
        profileController.isDepartmentError.value = true;
      } else if (profileController.feeController.text.isEmpty) {
        profileController.isFeeError.value = true;
      } else if (profileController.aboutUsController.text.isEmpty) {
        profileController.isAboutUsError.value = true;
      } else if (profileController.yearsOfExpController.text.isEmpty) {
        profileController.isHealthCareError.value = true;
      } else {
        profileController.uploadData();
      }
    } else {
      profileController.uploadData();
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}
