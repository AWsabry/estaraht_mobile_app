import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:dio/dio.dart' as dio;

import 'dart:developer' as dev;
import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/features/doctor/availability/models/holiday_model.dart';
import 'package:videocalling/features/doctor/profile/models/doctor_profile_details_model.dart';
import 'package:videocalling/features/doctor/profile/models/doctor_schdule_details_model.dart';
import 'package:videocalling/features/patient/doctors/models/doctor_detail_model.dart';

class DoctorProfileController extends GetxController {
  FirebaseHelper firebaseHelper = FirebaseHelper();
  SupabaseHelper supabaseHelper = SupabaseHelper();

  RxInt index = 0.obs;

  // Add these properties to the controller
  RxBool isSuccessful = false.obs;
  RxBool isFromRegistration = false.obs;
  RxString pageTitle = "edit_profile".tr.obs;

  // Add method to validate all required fields
  bool validateProfileCompletion() {
    bool isValid = true;

    // Reset all error states
    isNameError.value = false;
    isPhoneError.value = false;
    isDepartmentError.value = false;
    isFeeError.value = false;
    isAboutUsError.value = false;
    isServiceError.value = false;
    isAddressError.value = false;
    isHealthCareError.value = false;
    isWorkingTimeError.value = false;

    // Validate required fields
    if (nameController.text.isEmpty) {
      isNameError.value = true;
      isValid = false;
    }

    if (phoneController.text.isEmpty) {
      isPhoneError.value = true;
      isValid = false;
    }

    if (selectedValue.value == null) {
      isDepartmentError.value = true;
      isValid = false;
    }

    if (feeController.text.isEmpty) {
      isFeeError.value = true;
      isValid = false;
    }

    if (aboutUsController.text.isEmpty) {
      isAboutUsError.value = true;
      isValid = false;
    }

    if (yearsOfExpController.text.isEmpty) {
      isHealthCareError.value = true;
      isValid = false;
    }

    return isValid;
  }

  uploadData() async {
    // If coming from registration, validate all fields
    if (isFromRegistration.value && !validateProfileCompletion()) {
      customDialog(
        s1: 'incomplete_profile'.tr,
        s2: 'please_complete_all_fields'.tr,
      );
      return;
    }

    await Future.delayed(Duration.zero);
    customDialog1(s1: 'reporting_dialog1'.tr, s2: 'while_saving_changes'.tr);

    try {
      String? imageUrl;

      // Upload image to Supabase Storage if a new image was selected
      if (sImage != null) {
        loggerNoStack.i('Uploading image to Supabase Storage...');
        imageUrl = await _uploadImageToSupabase(sImage!);
        loggerNoStack.i('Image uploaded successfully: $imageUrl');
      }

      // Prepare doctor data for Supabase - matching database structure
      final doctorData = {
        'full_name': nameController.text,
        'phone_number': phoneController.text,
        'specialization': selectedValue.value,
        'booking_price': feeController.text,
        'bio': aboutUsController.text,
        'years_of_exp': int.tryParse(yearsOfExpController.text) ?? 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Only update image URL if a new image was uploaded
      if (imageUrl != null) {
        doctorData['profile_img_url'] = imageUrl;
      }

      loggerNoStack.i('Updating doctor profile in Supabase...');

      // Update doctor profile in Supabase
      await supabaseHelper.client
          .from('doctors')
          .update(doctorData)
          .eq('doctor_id', doctorId.value);

      loggerNoStack.i('Profile updated successfully');
      Get.back();
      isSuccessful.value = true;

      // Use appropriate message based on flow
      String message = isFromRegistration.value
          ? 'profile_completed_successfully'.tr
          : 'profile_update_successfully'.tr;

      messageDialog('success'.tr, message);
    } catch (e, stackTrace) {
      loggerNoStack.e('Error updating profile: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      Get.back();
      messageDialog('error'.tr, 'unable_to_update_profile'.tr);
    }
  }

  /// Upload image to Supabase Storage
  Future<String> _uploadImageToSupabase(File imageFile) async {
    try {
      final fileName =
          '${doctorId.value}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'profiles/doctors/$fileName';

      loggerNoStack.i('Uploading file to path: $filePath');

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage - bucket name: estarht, folder: profiles/doctors
      await supabaseHelper.client.storage
          .from('estarht')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = supabaseHelper.client.storage
          .from('estarht')
          .getPublicUrl(filePath);

      loggerNoStack.i('Public URL generated: $publicUrl');
      return publicUrl;
    } catch (e) {
      loggerNoStack.e('Error uploading image to Supabase: $e');
      rethrow;
    }
  }

  messageDialog(String s1, String s2) {
    customDialog(
      s1: s1,
      s2: s2,
      onPressed: () {
        if (isSuccessful.value) {
          // Clear the flag only after successful profile completion
          if (isFromRegistration.value) {
            StorageService.writeBoolData(
              key: 'isNewDoctorRegistration',
              value: false,
            );
          }
          // Always navigate to home screen after successful profile completion
          Get.offAllNamed(Routes.doctorTabScreen);
        } else {
          Get.back();
        }
      },
    );
  }

  DoctorDetailsClass? doctorProfileDetails;
  DoctorScheduleDetails? doctorScheduleDetails;
  Future? future;
  Future? future2;
  RxString doctorId = "".obs;

  RxBool isErrorInLoading = false.obs;
  RxBool isProfileLoaded = false.obs;
  RxBool isScheduleLoaded = false.obs;
  RxBool isLoading = false.obs;

  List<String> daysList = [
    'day_full_1'.tr,
    'day_full_2'.tr,
    'day_full_3'.tr,
    'day_full_4'.tr,
    'day_full_5'.tr,
    'day_full_6'.tr,
    'day_full_7'.tr,
  ];

  RxList<MyData> myData = <MyData>[].obs;

  fetchDoctorSchedule() async {
    isScheduleLoaded.value = false;
    final response = await get(
      Uri.parse(
        "${Apis.ServerAddress}/api/getdoctorschedule?doctor_id=${doctorId.value}",
      ),
    ).timeout(const Duration(seconds: Apis.timeOut));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'].toString() == "1") {
        doctorScheduleDetails = DoctorScheduleDetails.fromJson(jsonResponse);

        isScheduleLoaded.value = true;
      }
    } else {
      isErrorInLoading.value = true;
    }
  }

  fetchDoctorProfileDetails() async {
    loggerNoStack.i("the doctor id is ${doctorId.value}");
    isLoading.value = true;
    isErrorInLoading.value = false;
    try {
      final response = await supabaseHelper.client
          .from('doctors')
          .select()
          .eq('doctor_id', doctorId)
          .single();

      final jsonResponse = response;
      doctorProfileDetails = DoctorDetailsClass(
        success: 'true',
        register: null,
        data: DoctorDData(
          name: (jsonResponse['full_name'] ?? '').toString(),
          email: (jsonResponse['email'] ?? '').toString(),
          phoneno: jsonResponse['phone_number']?.toString(),
          age: jsonResponse['age']?.toString(),
          gender: jsonResponse['gender']?.toString(),
          aboutus: (jsonResponse['bio'] ?? '').toString(),
          image: (jsonResponse['profile_img_url'] ?? '').toString(),
          departmentName: (jsonResponse['specialization'] ?? '').toString(),
          yearsOfExp: jsonResponse['years_of_exp'] is int
              ? jsonResponse['years_of_exp']
              : int.tryParse(jsonResponse['years_of_exp']?.toString() ?? '0'),
          numbPatients: jsonResponse['numb_patients'] is int
              ? jsonResponse['numb_patients']
              : int.tryParse(jsonResponse['numb_patients']?.toString() ?? '0'),
          consultationFee: jsonResponse['booking_price']?.toString(),
          totalReview: jsonResponse['number_review'] is int
              ? jsonResponse['number_review']
              : int.tryParse(jsonResponse['number_review']?.toString() ?? '0'),
          specializations:
              (jsonResponse['specialization'] != null &&
                  jsonResponse['specialization'].toString().isNotEmpty)
              ? [Speciality(name: jsonResponse['specialization'].toString())]
              : null,
        ),
      );
      loggerNoStack.i('Doctor details fetched successfully');
      loggerNoStack.i('Name: ${doctorProfileDetails?.data?.name}');
      loggerNoStack.i('Email: ${doctorProfileDetails?.data?.email}');
      loggerNoStack.i('Phone: ${doctorProfileDetails?.data?.phoneno}');
      loggerNoStack.i('Age: ${doctorProfileDetails?.data?.age}');
      loggerNoStack.i('Gender: ${doctorProfileDetails?.data?.gender}');
      loggerNoStack.i('Bio: ${doctorProfileDetails?.data?.aboutus}');
      loggerNoStack.i('Profile Image: ${doctorProfileDetails?.data?.image}');
      loggerNoStack.i(
        'Specialization: ${doctorProfileDetails?.data?.departmentName}',
      );
      loggerNoStack.i(
        'Years of Experience: ${doctorProfileDetails?.data?.yearsOfExp}',
      );
      loggerNoStack.i(
        'Number of Patients: ${doctorProfileDetails?.data?.numbPatients}',
      );
      loggerNoStack.i(
        'Consultation Fee: ${doctorProfileDetails?.data?.consultationFee}',
      );

      // Populate TextEditingControllers with fetched data
      nameController.text = doctorProfileDetails?.data?.name ?? '';
      phoneController.text = doctorProfileDetails?.data?.phoneno ?? '';
      aboutUsController.text = doctorProfileDetails?.data?.aboutus ?? '';
      specializationController.text = doctorProfileDetails!
          .data!
          .departmentName!
          .toString();
      selectedValue.value = doctorProfileDetails?.data?.departmentName;
      worktimeController.text =
          doctorProfileDetails?.data?.yearsOfExp?.toString() ?? '';
      feeController.text = doctorProfileDetails?.data?.consultationFee ?? '';
      textEditingController.text = jsonResponse['address']?.toString() ?? '';
      yearsOfExpController.text =
          doctorProfileDetails?.data?.yearsOfExp?.toString() ?? '';

      isLoading.value = false;
      isProfileLoaded.value = true;
    } catch (e) {
      isErrorInLoading.value = true;
      loggerNoStack.e("Exception fetching doctor details: $e");
    }
  }

  Future<bool> onWillPopScope() async {
    // If from registration, don't allow back navigation
    if (isFromRegistration.value) {
      customDialog(
        s1: 'profile_completion_required'.tr,
        s2: 'please_complete_your_profile_to_continue'.tr,
      );
      return false;
    }

    bool x = false;
    if (index.value > 0) {
      index.value = index.value - 1;
      x = false;
    } else {
      x = true;
    }
    return x;
  }

  RxBool isNameError = false.obs;
  RxBool isPhoneError = false.obs;
  RxBool isWorkingTimeError = false.obs;
  RxBool isAboutUsError = false.obs;
  RxBool isServiceError = false.obs;
  RxBool isDepartmentError = false.obs;
  RxBool isHealthCareError = false.obs;
  RxBool isFeeError = false.obs;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController aboutUsController = TextEditingController();
  TextEditingController specializationController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController worktimeController = TextEditingController();
  TextEditingController yearsOfExpController = TextEditingController();
  TextEditingController feeController = TextEditingController();

  RxString password = "".obs;

  GoogleMapController? mapController;
  final Map<String, Marker> markers = {};
  LatLng? center;
  RxBool sLocationUpdated = false.obs;
  Future? getLocation;
  RxBool isAddressError = false.obs;
  TextEditingController textEditingController = TextEditingController();

  RxList<String> departmentList = <String>[].obs;
  SpecialityClass? specialityClass;
  File? sImage;
  RxBool sImageSelected = false.obs;

  String? base64image;

  Future getImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );

    if (pickedFile != null) {
      sImageSelected.value = false;
      sImage = File(pickedFile.path);
      base64image = base64Encode(sImage!.readAsBytesSync());
      sImageSelected.value = true;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void retryLoading() {
    isErrorInLoading.value = false;
    isLoading.value = true;

    // Reset any error states
    isProfileLoaded.value = false;
    isScheduleLoaded.value = false;

    // Reload data
    onInit();
  }

  // Check if coming from registration
  @override
  void onInit() {
    super.onInit();

    // Check if coming from registration flow
    if (Get.arguments != null && Get.arguments['isFromRegistration'] == true) {
      isFromRegistration.value = true;
      pageTitle.value = "complete_therapist_info".tr;
    }

    //getSpecialities();
    doctorId.value = firebaseHelper.currentUser!.uid.toString();
    StorageService.readData(key: LocalStorageKeys.userId) ?? "";
    future = fetchDoctorProfileDetails();
    future2 = fetchDoctorSchedule();
  }

  ValueNotifier<String?> selectedValue = ValueNotifier(null);

  // Add this helper function to your DoctorProfileController class
  String getLocalizedText(String multiLanguageText, String languageCode) {
    if (multiLanguageText.isEmpty) return '';

    // Check if the text is in the multi-language format
    if (!multiLanguageText.contains('{') || !multiLanguageText.contains('}')) {
      return multiLanguageText; // Return as is if not in the format
    }

    // Pattern to extract content for specific language
    RegExp regExp = RegExp(r'\{' + languageCode + r'\[(.*?)\]\}');
    Match? match = regExp.firstMatch(multiLanguageText);

    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? '';
    }

    // If requested language not found, try English as fallback
    if (languageCode != 'en') {
      RegExp enRegExp = RegExp(r'\{en\[(.*?)\]\}');
      Match? enMatch = enRegExp.firstMatch(multiLanguageText);
      if (enMatch != null && enMatch.groupCount >= 1) {
        return enMatch.group(1) ?? '';
      }
    }

    return ''; // Return empty if no match found
  }

  // Add this function to save the multi-language format
  void updateServiceText(String newText, String languageCode) {
    String currentValue = specializationController.text;

    // If empty or not in multi-language format, create a new format
    if (currentValue.isEmpty ||
        (!currentValue.contains('{') && !currentValue.contains('}'))) {
      specializationController.text = '{$languageCode[$newText]}';
      return;
    }
  }

  Widget step1({required BuildContext context}) {
    final languageController = Get.find<LanguageController>();
    final String currentLang = languageController.currentLanguage.value;
    final bool isArabic = currentLang == 'ar';

    // Create a temporary controller to show only current language content
    final localizedspecializationController = TextEditingController(
      text: getLocalizedText(specializationController.text, currentLang),
    );
    return Obx(
      () => Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24, bottom: 40),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 124,
                          width: 124,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.color1.withOpacity(0.3),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(62),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: (sImageSelected.value && sImage != null)
                                  ? Image.file(
                                      sImage!,
                                      height: 124,
                                      width: 124,
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl:
                                          doctorProfileDetails!.data!.image!
                                              .toString()
                                              .contains(Apis.doctorImagePath)
                                          ? doctorProfileDetails!.data!.image!
                                                .toString()
                                          : doctorProfileDetails!.data!.image
                                                .toString(),
                                      height: 124,
                                      width: 124,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[100],
                                        child: Icon(
                                          Icons.account_circle,
                                          color: Colors.grey[400],
                                          size: 60,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey[100],
                                            child: Icon(
                                              Icons.account_circle,
                                              color: Colors.grey[400],
                                              size: 60,
                                            ),
                                          ),
                                    ),
                            ),
                          ),
                        ),
                        // Edit Button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => getImage(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.color1,
                                borderRadius: BorderRadius.circular(19),
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
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Form Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information
                    _buildModernTextField(
                      context: context,
                      labelText: 'name_hint'.tr,
                      controller: nameController,
                      errorText: isNameError.value ? 'enter_name'.tr : null,
                      hasError: isNameError.value,
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          isNameError.value = false;
                        }
                        update();
                      },
                    ),

                    const SizedBox(height: 20),
                    _buildModernTextField(
                      context: context,
                      labelText: 'phone_number'.tr,
                      controller: phoneController,
                      errorText: isPhoneError.value ? 'enter_number'.tr : null,
                      hasError: isPhoneError.value,
                      keyboardType: TextInputType.phone,
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          isPhoneError.value = false;
                        }
                        update();
                      },
                    ),

                    const SizedBox(height: 24),

                    // Specialty dropdown
                    const SizedBox(height: 20),

                    const SizedBox(height: 20),

                    _buildModernTextField(
                      context: context,
                      labelText: 'consultation_fee'.tr,
                      controller: feeController,
                      errorText: isFeeError.value
                          ? 'common_textfield_error'.tr
                          : null,
                      hasError: isFeeError.value,
                      keyboardType: TextInputType.number,
                      prefixText: "$CURRENCY ",
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          isFeeError.value = false;
                        }
                        update();
                      },
                    ),

                    const SizedBox(height: 24),

                    // Text Areas with better styling
                    _buildModernTextArea(
                      context: context,
                      labelText: 'bio'.tr,
                      controller: aboutUsController,
                      errorText: isAboutUsError.value
                          ? 'about_us_error'.tr
                          : null,
                      hasError: isAboutUsError.value,
                      maxLines: 4,
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          isAboutUsError.value = false;
                        }
                        update();
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildModernTextArea(
                      context: context,
                      labelText: 'specialization'.tr,
                      controller:
                          localizedspecializationController, // Use localized controller for display
                      errorText: isServiceError.value
                          ? 'services_error'.tr
                          : null,
                      hasError: isServiceError.value,
                      maxLines: 4,
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          isServiceError.value = false;
                        }
                        // Update the multi-language format when text changes
                        updateServiceText(val, currentLang);
                        update();
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildModernTextArea(
                      context: context,
                      labelText: 'years_of_exp'.tr,
                      controller: yearsOfExpController,
                      errorText: isHealthCareError.value
                          ? 'common_textfield_error'.tr
                          : null,
                      hasError: isHealthCareError.value,
                      maxLines: 3,
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          isHealthCareError.value = false;
                        }
                        update();
                      },
                    ),

                    // Bottom spacing
                    const SizedBox(height: 80),
                  ],
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // Modern styled text field
  Widget _buildModernTextField({
    required BuildContext context,
    required String labelText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    bool hasError = false,
    String? prefixText,
    Widget? suffixIcon,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        labelText: labelText,
        labelStyle: TextStyle(
          color: hasError ? AppColors.RED700 : Colors.grey[600],
          fontSize: 15,
        ),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: hasError
            ? Colors.red.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? AppColors.RED700 : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? AppColors.RED700 : Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? AppColors.RED700 : AppColors.color1,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.RED700),
        ),
      ),
      onChanged: onChanged,
    );
  }

  // Modern styled text area for multiline input
  Widget _buildModernTextArea({
    required BuildContext context,
    required String labelText,
    required TextEditingController controller,
    required int maxLines,
    String? errorText,
    bool hasError = false,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelText: labelText,
        alignLabelWithHint: true,
        labelStyle: TextStyle(
          color: hasError ? AppColors.RED700 : Colors.grey[600],
          fontSize: 15,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: hasError
            ? Colors.red.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? AppColors.RED700 : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? AppColors.RED700 : Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? AppColors.RED700 : AppColors.color1,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.RED700),
        ),
      ),
      onChanged: onChanged,
    );
  }

  List<String> months = [
    'month1'.tr,
    'month2'.tr,
    'month3'.tr,
    'month4'.tr,
    'month5'.tr,
    'month6'.tr,
    'month7'.tr,
    'month8'.tr,
    'month9'.tr,
    'month10'.tr,
    'month11'.tr,
    'month12'.tr,
  ];

  RxBool isErrorInHoliday = false.obs;
  RxBool isHolidayLoaded = false.obs;
  RxBool isHolidayFound = false.obs;
  RxList<HData> holidayList = <HData>[].obs;
}
