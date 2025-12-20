import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/core/utils/logger.dart';

class EmailService {
  // Use environment variables or secure storage
  static String get _username => 'a.cheikh@estaraht.com';
  static String get _appPassword => 'hjdv jtln rovz vohm';
  static const String _appName = 'Estaraht';

  /// Validate email format
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Send an email using Gmail SMTP with improved error handling
  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? toName,
    bool isHtml = true,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    // Validate email format
    if (!_isValidEmail(to)) {
      if (kDebugMode) print('❌ Invalid email format: $to');
      return false;
    }

    // Validate required fields
    if (subject.isEmpty || body.isEmpty) {
      if (kDebugMode) print('❌ Subject or body cannot be empty');
      return false;
    }

    try {
      loggerNoStack.i(
        "the data of gmail as username and apppaswword before sending email is :$_username  $_appPassword",
      );

      // Configure Gmail SMTP server
      final smtpServer = gmail(_username, _appPassword);

      // Create the message
      final message = mailer.Message()
        ..from = mailer.Address(_username, _appName)
        ..recipients.add(mailer.Address(to, toName ?? ''))
        ..subject = subject;

      // Add CC and BCC if provided and valid
      if (cc != null && cc.isNotEmpty) {
        final validCc = cc.where(_isValidEmail).toList();
        if (validCc.isNotEmpty) {
          message.ccRecipients.addAll(
            validCc.map((email) => mailer.Address(email)),
          );
        }
      }
      if (bcc != null && bcc.isNotEmpty) {
        final validBcc = bcc.where(_isValidEmail).toList();
        if (validBcc.isNotEmpty) {
          message.bccRecipients.addAll(
            validBcc.map((email) => mailer.Address(email)),
          );
        }
      }

      // Set body content
      if (isHtml) {
        message.html = body;
      } else {
        message.text = body;
      }

      // Send the email with timeout
      final sendReport = await send(
        message,
        smtpServer,
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('✅ Email sent successfully to $to');
        print('📧 Message ID: ${sendReport.toString()}');
      }

      return true;
    } on TimeoutException {
      if (kDebugMode) print('❌ Email sending timeout for $to');
      return false;
    } on MailerException catch (e) {
      if (kDebugMode) print('❌ Mailer error for $to: ${e.message}');
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ Failed to send email to $to: $e');
      return false;
    }
  }

  /// Send Welcome Email to new users with retry mechanism
  static Future<bool> sendWelcomeEmail({
    required String to,
    required String userName,
    required String userType, // 'doctor' or 'patient'
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final languageController = Get.find<LanguageController>();
        final currentLang = languageController.currentLanguage.value;

        String subject;
        String body;

        if (currentLang == 'ar') {
          subject = 'مرحباً بك في استرحت - تطبيق العلاج النفسي';
          body = _getArabicWelcomeTemplate(userName, userType);
        } else if (currentLang == 'fr') {
          subject = 'Bienvenue à Estaraht - Application de Thérapie';
          body = _getFrenchWelcomeTemplate(userName, userType);
        } else {
          subject = 'Welcome to Estaraht - Therapy App';
          body = _getEnglishWelcomeTemplate(userName, userType);
        }

        final success = await sendEmail(
          to: to,
          toName: userName,
          subject: subject,
          body: body,
          isHtml: true,
        );

        if (success) return true;

        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } catch (e) {
        if (kDebugMode) print('❌ Welcome email attempt $attempt failed: $e');
      }
    }
    return false;
  }

  /// Send OTP Email with retry mechanism and rate limiting
  static Future<bool> sendOtpEmail({
    required String to,
    required String otpCode,
    required String userName,
    int maxRetries = 3,
  }) async {
    if (!_isValidEmail(to) || otpCode.length != 6) {
      if (kDebugMode) print('❌ Invalid email or OTP format');
      return false;
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final languageController = Get.find<LanguageController>();
        final currentLang = languageController.currentLanguage.value;

        String subject;
        String body;

        if (currentLang == 'ar') {
          subject = 'رمز التحقق الخاص بك - استرحت';
          body = _getArabicOtpTemplate(userName, otpCode);
        } else if (currentLang == 'fr') {
          subject = 'Votre Code de Vérification - Estaraht';
          body = _getFrenchOtpTemplate(userName, otpCode);
        } else {
          subject = 'Your Verification Code - Estaraht';
          body = _getEnglishOtpTemplate(userName, otpCode);
        }

        final success = await sendEmail(
          to: to,
          toName: userName,
          subject: subject,
          body: body,
          isHtml: true,
        );

        if (success) return true;

        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } catch (e) {
        if (kDebugMode) print('❌ OTP email attempt $attempt failed: $e');
      }
    }
    return false;
  }

  /// Send Password Reset Email with validation
  static Future<bool> sendPasswordResetEmail({
    required String to,
    required String resetLink,
    required String userName,
    int maxRetries = 3,
  }) async {
    // Fix nullable boolean issue
    final uri = Uri.tryParse(resetLink);
    if (uri == null || !uri.isAbsolute) {
      if (kDebugMode) print('❌ Invalid reset link format');
      return false;
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final languageController = Get.find<LanguageController>();
        final currentLang = languageController.currentLanguage.value;

        String subject;
        String body;

        if (currentLang == 'ar') {
          subject = 'إعادة تعيين كلمة المرور - استرحت';
          body = _getArabicPasswordResetTemplate(userName, resetLink);
        } else if (currentLang == 'fr') {
          subject = 'Réinitialisation du Mot de Passe - Estaraht';
          body = _getFrenchPasswordResetTemplate(userName, resetLink);
        } else {
          subject = 'Password Reset - Estaraht';
          body = _getEnglishPasswordResetTemplate(userName, resetLink);
        }

        final success = await sendEmail(
          to: to,
          toName: userName,
          subject: subject,
          body: body,
          isHtml: true,
        );

        if (success) return true;

        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Password reset email attempt $attempt failed: $e');
        }
      }
    }
    return false;
  }

  /// Send Appointment Confirmation Email with validation
  static Future<bool> sendAppointmentConfirmationEmail({
    required String to,
    required String userName,
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
    required String userType,
    int maxRetries = 3,
  }) async {
    if (doctorName.isEmpty ||
        appointmentDate.isEmpty ||
        appointmentTime.isEmpty) {
      if (kDebugMode) print('❌ Missing appointment details');
      return false;
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final languageController = Get.find<LanguageController>();
        final currentLang = languageController.currentLanguage.value;

        String subject;
        String body;

        if (currentLang == 'ar') {
          subject = 'تأكيد الموعد - استرحت';
          body = _getArabicAppointmentTemplate(
            userName,
            doctorName,
            appointmentDate,
            appointmentTime,
            userType,
          );
        } else if (currentLang == 'fr') {
          subject = 'Confirmation de Rendez-vous - Estaraht';
          body = _getFrenchAppointmentTemplate(
            userName,
            doctorName,
            appointmentDate,
            appointmentTime,
            userType,
          );
        } else {
          subject = 'Appointment Confirmation - Estaraht';
          body = _getEnglishAppointmentTemplate(
            userName,
            doctorName,
            appointmentDate,
            appointmentTime,
            userType,
          );
        }

        final success = await sendEmail(
          to: to,
          toName: userName,
          subject: subject,
          body: body,
          isHtml: true,
        );

        if (success) return true;

        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Appointment email attempt $attempt failed: $e');
        }
      }
    }
    return false;
  }

  // English Templates
  static String _getEnglishWelcomeTemplate(String userName, String userType) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');
    final sanitizedUserType = userType == 'doctor' ? 'Doctor' : 'Patient';

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Roboto', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Welcome to Estaraht!</h1>
            </div>
            <div class="content">
                <h2>Hello $sanitizedUserName!</h2>
                <p>Welcome to Estaraht, your trusted therapy companion.</p>
                <p>You have successfully registered as a <strong>$sanitizedUserType</strong>.</p>
                <p>Thank you for choosing Estaraht for your therapy needs.</p>
                <p>Best regards,<br>The Estaraht Team</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 Estaraht. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static String _getEnglishOtpTemplate(String userName, String otpCode) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');
    final sanitizedOtpCode = otpCode.replaceAll(RegExp(r'[^0-9]'), '');

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Roboto', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; text-align: center; }
            .otp-code { background: #f8f9fa; padding: 20px; border-radius: 10px; font-size: 32px; font-weight: bold; color: #204FCF; letter-spacing: 8px; margin: 20px 0; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Verification Code</h1>
            </div>
            <div class="content">
                <h2>Hello $sanitizedUserName!</h2>
                <p>Your verification code for Estaraht is:</p>
                <div class="otp-code">$sanitizedOtpCode</div>
                <p>This code will expire in 10 minutes.</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 Estaraht. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static String _getEnglishPasswordResetTemplate(
    String userName,
    String resetLink,
  ) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Roboto', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; }
            .button { background: #204FCF; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Password Reset</h1>
            </div>
            <div class="content">
                <h2>Hello $sanitizedUserName!</h2>
                <p>We received a request to reset your password.</p>
                <a href="$resetLink" class="button">Reset Password</a>
                <p>If you didn't request this, please ignore this email.</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 Estaraht. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static String _getEnglishAppointmentTemplate(
    String userName,
    String doctorName,
    String appointmentDate,
    String appointmentTime,
    String userType,
  ) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');
    final sanitizedDoctorName = doctorName.replaceAll(RegExp(r'[<>"\x27]'), '');

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Roboto', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Appointment Confirmation</h1>
            </div>
            <div class="content">
                <h2>Hello $sanitizedUserName!</h2>
                <p>Your appointment has been confirmed.</p>
                <p><strong>Doctor:</strong> $sanitizedDoctorName</p>
                <p><strong>Date:</strong> $appointmentDate</p>
                <p><strong>Time:</strong> $appointmentTime</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 Estaraht. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // French Templates
  static String _getFrenchWelcomeTemplate(String userName, String userType) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');
    final sanitizedUserType = userType == 'doctor' ? 'Thérapeute' : 'Patient';

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Roboto', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Bienvenue à Estaraht!</h1>
            </div>
            <div class="content">
                <h2>Bonjour $sanitizedUserName!</h2>
                <p>Bienvenue à Estaraht, votre compagnon de thérapie de confiance.</p>
                <p>Vous vous êtes inscrit avec succès en tant que <strong>$sanitizedUserType</strong>.</p>
                <p>Merci d'avoir choisi Estaraht pour vos besoins en thérapie.</p>
                <p>Cordialement,<br>L'équipe Estaraht</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 Estaraht. Tous droits réservés.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static String _getFrenchOtpTemplate(String userName, String otpCode) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');
    final sanitizedOtpCode = otpCode.replaceAll(RegExp(r'[^0-9]'), '');

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Roboto', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; text-align: center; }
            .otp-code { background: #f8f9fa; padding: 20px; border-radius: 10px; font-size: 32px; font-weight: bold; color: #204FCF; letter-spacing: 8px; margin: 20px 0; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Code de Vérification</h1>
            </div>
            <div class="content">
                <h2>Bonjour $sanitizedUserName!</h2>
                <p>Votre code de vérification pour Estaraht est :</p>
                <div class="otp-code">$sanitizedOtpCode</div>
                <p>Ce code expirera dans 10 minutes.</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 Estaraht. Tous droits réservés.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static String _getFrenchPasswordResetTemplate(
    String userName,
    String resetLink,
  ) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Roboto', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; }
            .button { background: #204FCF; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Réinitialisation du Mot de Passe</h1>
            </div>
            <div class="content">
                <h2>Bonjour $sanitizedUserName!</h2>
                <p>Nous avons reçu une demande de réinitialisation de votre mot de passe.</p>
                <a href="$resetLink" class="button">Réinitialiser le Mot de Passe</a>
                <p>Si vous n'avez pas demandé cela, veuillez ignorer cet e-mail.</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 Estaraht. Tous droits réservés.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static String _getFrenchAppointmentTemplate(
    String userName,
    String doctorName,
    String appointmentDate,
    String appointmentTime,
    String userType,
  ) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');
    final sanitizedDoctorName = doctorName.replaceAll(RegExp(r'[<>"\x27]'), '');

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Roboto', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Confirmation de Rendez-vous</h1>
            </div>
            <div class="content">
                <h2>Bonjour $sanitizedUserName!</h2>
                <p>Votre rendez-vous a été confirmé.</p>
                <p><strong>Thérapeute:</strong> $sanitizedDoctorName</p>
                <p><strong>Date:</strong> $appointmentDate</p>
                <p><strong>Heure:</strong> $appointmentTime</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 Estaraht. Tous droits réservés.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // Arabic Templates
  static String _getArabicWelcomeTemplate(String userName, String userType) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');
    final sanitizedUserType = userType == 'doctor' ? 'طبيب' : 'مريض';

    return '''
    <!DOCTYPE html>
    <html dir="rtl">
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Tajawal', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; direction: rtl; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>مرحباً بك في استرحت!</h1>
            </div>
            <div class="content">
                <h2>مرحباً $sanitizedUserName!</h2>
                <p>مرحباً بك في استرحت، رفيقك الموثوق في العلاج النفسي.</p>
                <p>لقد تم تسجيلك بنجاح كـ <strong>$sanitizedUserType</strong>.</p>
                <p>شكراً لاختيارك استرحت لاحتياجاتك في العلاج النفسي.</p>
                <p>مع أطيب التحيات،<br>فريق استرحت</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 استرحت. جميع الحقوق محفوظة.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static String _getArabicOtpTemplate(String userName, String otpCode) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');
    final sanitizedOtpCode = otpCode.replaceAll(RegExp(r'[^0-9]'), '');

    return '''
    <!DOCTYPE html>
    <html dir="rtl">
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Tajawal', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; direction: rtl; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; text-align: center; }
            .otp-code { background: #f8f9fa; padding: 20px; border-radius: 10px; font-size: 32px; font-weight: bold; color: #204FCF; letter-spacing: 8px; margin: 20px 0; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>رمز التحقق</h1>
            </div>
            <div class="content">
                <h2>مرحباً $sanitizedUserName!</h2>
                <p>رمز التحقق الخاص بك في استرحت هو:</p>
                <div class="otp-code">$sanitizedOtpCode</div>
                <p>سينتهي هذا الرمز خلال 10 دقائق.</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 استرحت. جميع الحقوق محفوظة.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static String _getArabicPasswordResetTemplate(
    String userName,
    String resetLink,
  ) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');

    return '''
    <!DOCTYPE html>
    <html dir="rtl">
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Tajawal', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; direction: rtl; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; }
            .button { background: #204FCF; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>إعادة تعيين كلمة المرور</h1>
            </div>
            <div class="content">
                <h2>مرحباً $sanitizedUserName!</h2>
                <p>تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بك.</p>
                <a href="$resetLink" class="button">إعادة تعيين كلمة المرور</a>
                <p>إذا لم تطلب ذلك، يرجى تجاهل هذا البريد الإلكتروني.</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 استرحت. جميع الحقوق محفوظة.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static String _getArabicAppointmentTemplate(
    String userName,
    String doctorName,
    String appointmentDate,
    String appointmentTime,
    String userType,
  ) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');
    final sanitizedDoctorName = doctorName.replaceAll(RegExp(r'[<>"\x27]'), '');

    return '''
    <!DOCTYPE html>
    <html dir="rtl">
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Tajawal', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; direction: rtl; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; }
            .header { background: #204FCF; color: white; padding: 30px; text-align: center; }
            .content { padding: 30px; }
            .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>تأكيد الموعد</h1>
            </div>
            <div class="content">
                <h2>مرحباً $sanitizedUserName!</h2>
                <p>تم تأكيد موعدك.</p>
                <p><strong>الطبيب:</strong> $sanitizedDoctorName</p>
                <p><strong>التاريخ:</strong> $appointmentDate</p>
                <p><strong>الوقت:</strong> $appointmentTime</p>
            </div>
            <div class="footer">
                <p>&copy; 2025 استرحت. جميع الحقوق محفوظة.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }
}
