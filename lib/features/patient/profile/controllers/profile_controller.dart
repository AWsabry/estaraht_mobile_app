import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/config/app_imports.dart';

class UserEditController extends GetxController {
  RxString name = "".obs;
  RxString phoneNumber = "".obs;
  RxString email = "".obs;
  RxString password = "".obs;
  RxString confirmPassword = "".obs;
  RxString phnNumberError = "".obs;
  RxBool isPhoneNumberError = false.obs;
  RxBool isNameError = false.obs;
  RxBool isEmailError = false.obs;
  RxBool isPassError = false.obs;
  RxString token = "".obs;
  String error = "";
  String? base64image;
  Uint8List? imageBytes; // Store bytes instead of file reference
  File? image;
  RxBool isImageSelected = false.obs;
  RxString userId = "".obs;
  String profileImage = "";

  RxBool isLoaded = false.obs;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  FirebaseHelper firebaseHelper = FirebaseHelper();

  Future getImage() async {
    isImageSelected.value = false;
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );

    if (pickedFile != null) {
      image = File(pickedFile.path);
      // Read bytes immediately while file exists in cache
      imageBytes = await image!.readAsBytes();
      isImageSelected.value = true;
      base64image = base64Encode(imageBytes!);
      update();
    }
  }

  Future<void> uploadProfileImageToSupabase(File imageFile) async {
    final userId = firebaseHelper.currentUserId;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }

    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = 'profiles/users/$fileName';

    // Use stored bytes if available, otherwise read from file
    final bytes = imageBytes ?? await imageFile.readAsBytes();

    // Upload to Supabase Storage
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

    // Update patient profile in Supabase
    await supabaseHelper.client
        .from('patients')
        .update({'profile_img_url': publicUrl})
        .eq('id', userId);

    profileImage = publicUrl;
    update();
  }

  Future<void> fetchPatientProfile() async {
    final userId = firebaseHelper.currentUserId;
    if (userId == null) return;

    final response = await supabaseHelper.client
        .from('patients')
        .select()
        .eq('id', userId)
        .single();

    name.value = response['name']?.toString() ?? '';
    email.value = response['email']?.toString() ?? '';
    phoneNumber.value = response['phone']?.toString() ?? '';
    profileImage = response['profile_img_url']?.toString() ?? '';
    // Optionally handle age, gender, etc.
    nameController.text = name.value;
    emailController.text = email.value;
    phoneController.text = phoneNumber.value;
    update();
  }

  Future<void> registerUser() async {
    if (name.isEmpty) {
      isNameError.value = true;
    } else if (phoneNumber.isEmpty || phoneNumber.value.length < PHONE_LENGTH) {
      isPhoneNumberError.value = true;
      phnNumberError.value = 'valid_mobile_number'.tr;
    } else if (GetUtils.isEmail(email.value) == false) {
      isEmailError.value = true;
    } else if (password != confirmPassword || password.value.isEmpty) {
      isPassError.value = true;
    } else {
      customDialog1(s1: 'edit_dialog1'.tr, s2: 'edit_dialog2'.tr);

      final userId = firebaseHelper.currentUserId;
      if (userId == null) {
        Get.back();
        customDialog(s1: 'error'.tr, s2: 'no_authenticated_user'.tr);
        return;
      }

      String? publicUrl;
      if (image != null) {
        await uploadProfileImageToSupabase(image!);
        publicUrl = profileImage;
      }

      final updateData = {
        'name': name.value,
        'email': email.value,
        'phone': phoneNumber.value,
        'profile_img_url': publicUrl ?? profileImage,
        'fcm_token': token.value,
        // Add other fields as needed
      };

      try {
        await supabaseHelper.client
            .from('patients')
            .update(updateData)
            .eq('id', userId);

        StorageService.writeBoolData(
          key: LocalStorageKeys.isLoggedIn,
          value: true,
        );
        StorageService.writeStringData(
          key: LocalStorageKeys.userId,
          value: userId,
        );
        StorageService.writeStringData(
          key: LocalStorageKeys.name,
          value: name.value,
        );
        StorageService.writeStringData(
          key: LocalStorageKeys.phone,
          value: phoneNumber.value,
        );
        StorageService.writeStringData(
          key: LocalStorageKeys.email,
          value: email.value,
        );
        StorageService.writeStringData(
          key: LocalStorageKeys.profileImage,
          value: publicUrl ?? profileImage,
        );

        // Sync updated profile to Firebase Realtime Database for chat
        try {
          final userIdWithAscii =
              StorageService.readData(key: LocalStorageKeys.userIdWithAscii) ??
              '';
          if (userIdWithAscii.isNotEmpty) {
            await FirebaseDatabase.instance.ref(userIdWithAscii).update({
              'name': name.value,
              'image': publicUrl ?? profileImage,
              'phone': phoneNumber.value,
              'email': email.value,
            });
            print('✅ Patient profile synced to Firebase Realtime Database');
          }
        } catch (e) {
          print('❌ Failed to sync patient profile to Firebase: $e');
        }

        Get.back();
        Get.back();
      } catch (e) {
        Get.back();
        error = e.toString();
        customDialog(s1: 'error'.tr, s2: error);
      }
    }
  }

  getToken() async {
    if (StorageService.readData(key: LocalStorageKeys.isTokenExist) == null) {
      firebaseMessaging.getToken().then((value) {
        if (value == null) return;
        token.value = value;
      });
    } else {
      token.value = StorageService.readData(key: LocalStorageKeys.token);
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    userId.value = StorageService.readData(key: LocalStorageKeys.userId) ?? "";
    fetchPatientProfile();

    isLoaded.value = false;
    update();
    getToken();
  }
}
