import 'package:logger/logger.dart';
import 'package:pinput/pinput.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/config/app_imports.dart';

// Pour les traductions

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupérer les arguments passés (email/téléphone et type d'OTP)
    final args = Get.arguments as Map<String, dynamic>;
    final String? email = args['email'];
    final String? phone = args['phone'];

    final bool isPatient = args['isPatient'] ?? false; // Get patient flag
    final String? expectedOtp = args['expectedOtp']; // Get expected OTP
    final String? otpId = args['otpId']; // Get OTP record ID
    final String? userId = args['userId']; // Get user ID
    Logger().d('args: $args');

    // Initialiser le contrôleur avec les arguments
    final OtpController controller = Get.put(
      OtpController(
        targetEmail: email,
        targetPhone: phone,
        otpPurpose: OtpType.signup,
        isPatient: isPatient, // Pass patient flag
        expectedOtp: expectedOtp, // Pass expected OTP for validation
        otpId: otpId, // Pass OTP record ID
        userId: userId, // Pass user ID
      ),
    );

    final bool isArabic =
        Get.find<LanguageController>().currentLanguage.value == 'ar';

    // Thèmes pour Pinput (définis au-dessus ou importés si dans un fichier séparé)
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: CustomTextStyle(
        fontSize: 22,
        color: Colors.black,
        fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF204FCF)),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.red),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'OTP'.tr,
          style: CustomTextStyle(
            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                "verify_otp_title".tr, // "رمز التحقق (OTP)"
                style: CustomTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "verify_otp_description".trArgs([
                  email ?? phone ?? '',
                ]), // "الرجاء إدخال الرمز المكون من 6 أرقام المرسل إلى \n..."
                textAlign: TextAlign.center,
                style: CustomTextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                ),
              ),
              const SizedBox(height: 40),

              // --- Champ de saisie OTP (Pinput) ---
              Obx(
                () => Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  errorPinTheme: errorPinTheme,
                  forceErrorState: controller.isOtpError.value,
                  onChanged: (pin) {
                    controller.otpCode.value = pin;
                    // Réinitialiser l'erreur si l'utilisateur commence à taper à nouveau
                    if (controller.isOtpError.value && pin.isNotEmpty) {
                      controller.isOtpError.value = false;
                      controller.errorMessage.value = '';
                    }
                  },
                  onCompleted: (pin) {
                    controller.otpCode.value = pin;
                    // Déclenche la vérification dès que l'OTP est complet
                    controller.verifyOtp();
                  },
                ),
              ),
              const SizedBox(height: 20),

              // --- Message d'erreur ---
              Obx(() {
                if (controller.isOtpError.value &&
                    controller.errorMessage.isNotEmpty) {
                  return Text(
                    controller.errorMessage.value, // Message d'erreur dynamique
                    style: CustomTextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 30),

              // --- Bouton "Activer le compte" ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null // Désactiver pendant le chargement
                        : () => controller.verifyOtp(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF204FCF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "activate_account_button".tr, // "تفعيل الحساب"
                            style: CustomTextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: isArabic
                                  ? 'NotoKufiArabic'
                                  : 'Roboto',
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Logique du bouton/texte de renvoi ---
              Obx(() {
                if (controller.canResend.value) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: controller.isLoading.value
                          ? null // Désactiver si une action est déjà en cours
                          : () => controller.resendOtp(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              "resend_code_button".tr, // "ارسل مجدداً"
                              style: CustomTextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: isArabic
                                    ? 'NotoKufiArabic'
                                    : 'Roboto',
                              ),
                            ),
                    ),
                  );
                } else {
                  return Text(
                    "resend_code_text".trArgs([
                      controller.countdown.value.toString(),
                    ]), // "لم يصلك الرمز؟ يمكنك طلبه مجدداً خلال XX ثانية."
                    textAlign: TextAlign.center,
                    style: CustomTextStyle(
                      color: Colors.grey.shade600,
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
