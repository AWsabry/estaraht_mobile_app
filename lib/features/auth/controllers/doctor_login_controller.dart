import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/config/app_imports.dart';

class DoctorLoginController extends GetxController {
  // Instance du client Supabase
  SupabaseClient get supabase => supabaseHelper.client;

  var passwordVisible = true.obs;
  RxString emailAddress = "".obs;
  RxString pass = "".obs;
  RxBool isEmailError = false.obs;
  RxBool isPasswordError = false.obs;
  RxString passErrorText = "".obs;
  RxString token = "".obs; // Token FCM pour les notifications

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  // Obtenir le token FCM (inchangé)
  getToken() async {
    // Il est préférable de s'assurer que nous avons toujours le dernier token
    final fcmToken = await firebaseMessaging.getToken();
    if (fcmToken != null) {
      token.value = fcmToken;
      print("FCM Token obtained: ${token.value}");
    }
  }

  // --- NOUVELLE FONCTION DE CONNEXION AVEC SUPABASE (AVEC DÉBOGAGE AMÉLIORÉ) ---
  Future<void> login() async {
    // 1. Valider les champs côté client
    if (!GetUtils.isEmail(emailAddress.value)) {
      isEmailError.value = true;
      return;
    }
    if (pass.value.isEmpty || pass.value.length < 6) {
      isPasswordError.value = true;
      passErrorText.value = 'enter_6_characters'.tr;
      return;
    }

    // Réinitialiser les erreurs
    isEmailError.value = false;
    isPasswordError.value = false;

    // Afficher la boîte de dialogue de chargement
    customDialog1(
      s1: 'login_dialog_title'.tr,
      s2: 'login_dialog_description'.tr,
    );

    try {
      // 2. Se connecter avec Firebase Auth
      final UserCredential firebaseUserCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailAddress.value,
            password: pass.value,
          );
      final firebaseUser = firebaseUserCred.user;
      if (firebaseUser == null) {
        Get.back();
        customDialog(s1: 'error'.tr, s2: 'login_failed'.tr);
        return;
      }
      print(
        "✅ Connexion Firebase réussie pour l'utilisateur : ${firebaseUser.uid}",
      );

      // 3. Récupérer le médecin depuis Supabase en utilisant l'UID Firebase
      print(
        "ℹ️  Récupération du profil du médecin pour l'UID : ${firebaseUser.uid}",
      );
      final doctorProfileResponse = await supabase
          .from('doctors')
          .select()
          .eq('doctor_id', firebaseUser.uid)
          .single();

      print("✅ Profil du médecin trouvé :");
      print(doctorProfileResponse);

      // 3.5. Check approval status before proceeding
      final String approvalStatus =
          doctorProfileResponse['approval_status'] ?? 'pending';
      print("👨‍⚕️ Doctor approval status: $approvalStatus");

      if (approvalStatus == 'pending') {
        Get.back(); // Close loading dialog
        Get.offAllNamed(Routes.underReviewScreen);
        return;
      } else if (approvalStatus == 'rejected') {
        Get.back(); // Close loading dialog
        final rejectionReason = doctorProfileResponse['rejection_reason'];
        Get.offAllNamed(
          '/account-rejected',
          arguments: rejectionReason,
        );
        return;
      }

      // 4. Mettre à jour le token FCM si disponible
      if (token.value.isNotEmpty) {
        await supabase
            .from('doctors')
            .update({'fcm_token': token.value})
            .eq('doctor_id', firebaseUser.uid);
        print("Token FCM mis à jour dans Supabase.");
      }

      // 5. Gérer le reste de la connexion (only for approved doctors)
      await _handleSuccessfulLogin(doctorProfileResponse);
    } on FirebaseAuthException catch (e) {
      Get.back();
      print("Erreur d'authentification Firebase : ${e.message}");
      isPasswordError.value = true;
      passErrorText.value = 'invalid_credentials'.tr;
      customDialog(s1: 'error'.tr, s2: e.message ?? 'authentication_error'.tr);
    } catch (e) {
      Get.back();
      print("Une erreur inattendue est survenue : $e");
      customDialog(s1: 'error'.tr, s2: 'network_error'.tr);
    }
  }

  // --- NOUVELLE FONCTION POUR GÉRER LA LOGIQUE POST-CONNEXION ---
  Future<void> _handleSuccessfulLogin(Map<String, dynamic> profile) async {
    try {
      final doctorId = profile['doctor_id'].toString();
      final name = profile['name'] ?? '';
      final profilePic = profile['profile_pic'] ?? '';

      // Mettre à jour Firebase Realtime Database

      // Sauvegarder les données dans le stockage local
      StorageService.writeBoolData(
        key: LocalStorageKeys.isLoggedIn,
        value: true,
      );
      StorageService.writeBoolData(
        key: LocalStorageKeys.isLoggedInAsDoctor,
        value: true,
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.userIdWithAscii,
        value: "100$doctorId",
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.userId,
        value: doctorId,
      );
      StorageService.writeStringData(key: LocalStorageKeys.name, value: name);
      StorageService.writeStringData(
        key: LocalStorageKeys.phone,
        value: profile['phone'] ?? "",
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.email,
        value: profile['email'] ?? "",
      );
      StorageService.writeStringData(
        key: LocalStorageKeys.callerImage,
        value: profilePic,
      );

      // Sync doctor profile to Firebase Realtime Database for chat
      try {
        await FirebaseDatabase.instance.ref('100$doctorId').update({
          'name': name,
          'image': profilePic,
          'phone': profile['phone'] ?? "",
          'email': profile['email'] ?? "",
        });
        loggerNoStack.d(
          '✅ Doctor profile synced to Firebase Realtime Database',
        );
      } catch (e) {
        loggerNoStack.e('❌ Failed to sync doctor profile to Firebase: $e');
      }

      // Removed ConnectyCube login - proceed directly to dashboard
      Get.back();
      Get.offAllNamed(Routes.doctorTabScreen);
    } catch (e) {
      Get.back();
      print("Erreur lors du traitement post-connexion : $e");
      customDialog(s1: 'error'.tr, s2: 'unable_to_load_data'.tr);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Obtenir le token dès l'initialisation du contrôleur
    getToken();
  }
}
