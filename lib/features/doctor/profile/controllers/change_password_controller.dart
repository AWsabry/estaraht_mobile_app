import 'package:firebase_auth/firebase_auth.dart';
import 'package:videocalling/core/config/app_imports.dart';

class DChangePasswordController extends GetxController {
  FirebaseHelper firebaseHelper = FirebaseHelper();

  TextEditingController oldpassword = TextEditingController();
  TextEditingController newpassword = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();

  RxString docId = "".obs;
  final formKey = GlobalKey<FormState>();

  RxString oldPwd = "".obs;
  RxString newPwd = "".obs;
  RxString confPwd = "".obs;

  RxString oldPwdText = "".obs;
  RxString newPwdText = "".obs;
  RxString confPwdText = "".obs;

  RxBool isErrorInLoading = false.obs;

  RxBool passwordVisible = true.obs;
  RxBool passwordVisible1 = true.obs;
  RxBool passwordVisible2 = true.obs;

  RxBool passwordError1 = false.obs;
  RxBool passwordError2 = false.obs;
  RxBool passwordError3 = false.obs;

  changePassword() async {
    // Validate inputs
    if (oldpassword.text.isEmpty) {
      customDialog(s1: 'error'.tr, s2: 'please_enter_old_password'.tr);
      return;
    }

    if (newpassword.text.isEmpty) {
      customDialog(s1: 'error'.tr, s2: 'please_enter_new_password'.tr);
      return;
    }

    if (confirmpassword.text.isEmpty) {
      customDialog(s1: 'error'.tr, s2: 'please_confirm_new_password'.tr);
      return;
    }

    if (newpassword.text != confirmpassword.text) {
      customDialog(
        s1: 'error'.tr,
        s2: 'passwords_do_not_match'.tr,
      );
      return;
    }

    if (newpassword.text.length < 6) {
      customDialog(
        s1: 'error'.tr,
        s2: 'password_too_short'.tr,
      );
      return;
    }

    isErrorInLoading.value = true;

    try {
      loggerNoStack.i('Starting password change process...');

      // Change password using Firebase Authentication
      await firebaseHelper.changePassword(
        oldPassword: oldpassword.text,
        newPassword: newpassword.text,
      );

      loggerNoStack.i('Password changed successfully in Firebase');

      // Optionally send email verification
      await firebaseHelper.sendEmailVerification();
      loggerNoStack.i('Email verification sent');

      isErrorInLoading.value = false;

      // Show success dialog
      customDialog(
        s1: 'success_str'.tr,
        s2: 'password_changed_successfully'.tr,
        onPressed: () {
          Get.back();
          Get.back();
        },
      );
    } on FirebaseAuthException catch (e) {
      isErrorInLoading.value = false;
      loggerNoStack.e('Firebase Auth Error: ${e.code} - ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'old_password_incorrect'.tr;
          break;
        case 'weak-password':
          errorMessage = 'password_too_weak'.tr;
          break;
        case 'requires-recent-login':
          errorMessage = 'please_login_again'.tr;
          break;
        case 'too-many-requests':
          errorMessage = 'too_many_attempts'.tr;
          break;
        default:
          errorMessage = 'failed_to_change_password'.tr;
      }

      customDialog(s1: 'error'.tr, s2: errorMessage);
    } catch (e, stackTrace) {
      isErrorInLoading.value = false;
      loggerNoStack.e('Error changing password: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      String errorMessage = 'unable_to_change_password'.tr;

      if (e.toString().contains('old password is incorrect')) {
        errorMessage = 'old_password_incorrect'.tr;
      } else if (e.toString().contains('No authenticated user')) {
        errorMessage = 'please_login_again'.tr;
      }

      customDialog(s1: 'error'.tr, s2: errorMessage);
    }
  }

  @override
  void onInit() {
    super.onInit();
    docId.value = firebaseHelper.currentUserId ?? "";
  }

  @override
  void onClose() {
    oldpassword.dispose();
    newpassword.dispose();
    confirmpassword.dispose();
    super.onClose();
  }
}
