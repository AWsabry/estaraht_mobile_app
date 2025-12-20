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
      customDialog(s1: 'error'.tr, s2: 'Please enter your old password');
      return;
    }

    if (newpassword.text.isEmpty) {
      customDialog(s1: 'error'.tr, s2: 'Please enter a new password');
      return;
    }

    if (confirmpassword.text.isEmpty) {
      customDialog(s1: 'error'.tr, s2: 'Please confirm your new password');
      return;
    }

    if (newpassword.text != confirmpassword.text) {
      customDialog(
        s1: 'error'.tr,
        s2: 'New password and confirmation do not match',
      );
      return;
    }

    if (newpassword.text.length < 6) {
      customDialog(
        s1: 'error'.tr,
        s2: 'Password must be at least 6 characters',
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
        s2: 'Password changed successfully. A verification email has been sent.',
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
          errorMessage = 'The old password is incorrect';
          break;
        case 'weak-password':
          errorMessage =
              'The new password is too weak. Please use a stronger password';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log in again to change your password';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later';
          break;
        default:
          errorMessage = e.message ?? 'Failed to change password';
      }

      customDialog(s1: 'error'.tr, s2: errorMessage);
    } catch (e, stackTrace) {
      isErrorInLoading.value = false;
      loggerNoStack.e('Error changing password: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      String errorMessage = 'Unable to change password. Please try again.';

      if (e.toString().contains('old password is incorrect')) {
        errorMessage = 'The old password is incorrect';
      } else if (e.toString().contains('No authenticated user')) {
        errorMessage = 'Please log in again to change your password';
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
