import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLoginController extends GetxController {
  // --- VOS ATTRIBUTS EXISTANTS SONT CONSERVÉS ---
  final bool isFromOnboarding;
  late bool isBack;

  RxBool passwordVisible = true.obs;
  final RxBool isLoading = false.obs;
  RxString phoneNumber = "".obs; // Gardé pour la compatibilité
  RxString pass = "".obs; // Gardé pour la compatibilité
  RxBool isPhoneNumberError = false.obs;
  RxBool isPasswordError = false.obs;
  RxString passErrorText = "".obs;
  RxString token = "".obs; // Pour le token FCM
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  RxString name = "".obs, email = "".obs, image = "".obs;
  String message = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// Instance Supabase
  SupabaseHelper supabaseHelper = SupabaseHelper();
  SupabaseClient get supabase => supabaseHelper.client;

  UserLoginController()
    : isFromOnboarding =
          Get.arguments != null && Get.arguments['isFromOnboarding'] != null
          ? Get.arguments['isFromOnboarding']
          : false {
    isBack = Get.arguments != null && Get.arguments['isBack'] != null
        ? Get.arguments['isBack']
        : false;
  }

  @override
  void onInit() {
    super.onInit();
    // On récupère le token au démarrage pour l'avoir prêt
    getToken();
  }

  // --- NOUVELLE LOGIQUE DE TOKEN ET DE CONNEXION ---

  /// Fonction pour récupérer le token FCM. Remplace l'ancienne getToken.
  Future<void> getToken() async {
    try {
      final fcmToken = await firebaseMessaging.getToken();
      if (fcmToken != null) {
        token.value = fcmToken;
        loggerNoStack.d("FCM Token for Patient obtained: ${token.value}");
      }
    } catch (e) {
      loggerNoStack.e("Error getting FCM token", error: e);
      messageDialog('error'.tr, 'unable_to_save_token'.tr);
    }
  }

  /// NOUVELLE FONCTION PRINCIPALE: Remplace login(), loginInto() et storeToken().
  Future<void> login() async {
    loggerNoStack.d(
      'Attempting login for patient with email: ${emailController.text.trim()}',
    );
    loggerNoStack.d(
      'Password provided: ${passwordController.text.isNotEmpty ? "Yes" : "No"}',
    );
    // 1. Validation des champs
    if (emailController.text.trim().isEmpty ||
        !GetUtils.isEmail(emailController.text.trim())) {
      customDialog(s1: 'error'.tr, s2: 'enter_email_error'.tr);
      return;
    }
    if (passwordController.text.isEmpty) {
      customDialog(s1: 'error'.tr, s2: 'common_textfield_error'.tr);
      return;
    }

    isLoading.value = true;
    customDialog1(
      s1: 'login_dialog_title'.tr,
      s2: 'login_dialog_description'.tr,
    );

    try {
      // 2. Authentification de l'utilisateur avec Supabase
      final authResponse = await firebaseHelper.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (authResponse.user != null) {
        final user = authResponse.user!;
        loggerNoStack.i("✅ firensae login successful for patient: ${user.uid}");

        // Verify and log session immediately after login
        //supabaseHelper.verifySession();

        // S'assurer d'avoir le token le plus récent
        await getToken();

        // 3. Récupérer le profil depuis la table 'patients'
        final patientProfileResponse = await supabase
            .from('patients')
            .select()
            .eq('id', user.uid)
            .single();

        // 4. Mettre à jour le token FCM dans la table 'patients' (remplace storeToken)
        if (token.value.isNotEmpty) {
          await supabase
              .from('patients')
              .update({'fcm_token': token.value})
              .eq('id', user.uid);
          loggerNoStack.d("FCM token updated in Supabase for patient.");
        }

        // 5. Gérer toutes les actions après une connexion réussie
        await _handleSuccessfulLogin(patientProfileResponse);
      } else {
        Get.back();
        customDialog(s1: 'error'.tr, s2: 'registration_failed_user_exists'.tr);
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      loggerNoStack.e("Firebase Auth error for patient", error: e);
      print("Firebase Auth Error Code: ${e.code}");
      print("Firebase Auth Error Message: ${e.message}");

      // Handle Firebase Auth errors using error codes (more reliable than message strings)
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'registration_failed_user_exists'.tr; // User not found
          break;
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'invalid_password'.tr; // Wrong password
          break;
        case 'invalid-email':
          errorMessage = 'enter_email_error'.tr;
          break;
        case 'user-disabled':
          errorMessage =
              'registration_failed_user_exists'.tr; // Account disabled
          break;
        case 'too-many-requests':
          errorMessage = 'error2'.tr; // Too many requests, please try again
          break;
        case 'network-request-failed':
        case 'network-error':
          errorMessage = 'error2'.tr; // Network error, please try again
          break;
        default:
          // Fallback to checking message for other errors
          if (e.message != null) {
            final message = e.message!.toLowerCase();
            if (message.contains('password') &&
                (message.contains('wrong') || message.contains('invalid'))) {
              errorMessage = 'invalid_password'.tr;
            } else if (message.contains('user') &&
                (message.contains('not') || message.contains('found'))) {
              errorMessage = 'registration_failed_user_exists'.tr;
            } else if (message.contains('email')) {
              errorMessage = 'enter_email_error'.tr;
            } else {
              errorMessage = 'an_unexpected_error_occurred'.tr;
            }
          } else {
            errorMessage = 'an_unexpected_error_occurred'.tr;
          }
      }

      customDialog(s1: 'error'.tr, s2: errorMessage);
    } on AuthException catch (e) {
      Get.back();
      loggerNoStack.e("Supabase Auth error for patient", error: e);
      customDialog(s1: 'error'.tr, s2: 'an_unexpected_error_occurred'.tr);
    } catch (e) {
      Get.back();
      loggerNoStack.e("An unexpected error occurred", error: e);
      customDialog(s1: 'error'.tr, s2: 'an_unexpected_error_occurred'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fonction privée pour gérer la logique après une connexion réussie
  Future<void> _handleSuccessfulLogin(Map<String, dynamic> profile) async {
    try {
      final patientId = profile['id'].toString();

      // On met à jour les variables du contrôleur pour la compatibilité
      name.value = profile['name'] ?? '';
      email.value = profile['email'] ?? '';
      image.value = profile['profile_pic'] ?? '';
      phoneNumber.value = profile['phone'] ?? '';

      // Sauvegarder les données dans le stockage local
      StorageService.writeBoolData(
        key: LocalStorageKeys.isLoggedIn,
        value: true,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.userId,
        value: patientId,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.name,
        value: name.value,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.email,
        value: email.value,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.phone,
        value: phoneNumber.value,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.profileImage,
        value: image.value,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.userIdWithAscii,
        value: '117$patientId',
      );

      // NOTE: La logique pour ConnectyCube doit être ajoutée ici si nécessaire
      // en récupérant les IDs depuis la table 'patients'.
      loggerNoStack.d('reach here after saving local storage');
      Get.back(); // Ferme le dialogue de chargement
      if (isBack) {
        Get.back(result: true);
      } else {
        Get.offAllNamed(Routes.userTabScreen);
      }
    } catch (e) {
      Get.back();
      loggerNoStack.e("Post-login handling error for patient", error: e);
      customDialog(s1: 'error'.tr, s2: 'an_unexpected_error_occurred'.tr);
    }
  }

  messageDialog(String s1, String s2) {
    customDialog(s1: s1, s2: s2);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
