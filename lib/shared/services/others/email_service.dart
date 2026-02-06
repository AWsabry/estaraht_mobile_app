import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:videocalling/core/config/app_imports.dart';

class EmailService {
  // Use environment variables or secure storage
  static String get _username => 'noreply@estaraht.com';
  static String get _appPassword => 'tfwx iezx qdnu rxwg';
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
    final sanitizedUserType = userType == 'doctor' ? 'Therapist' : 'Patient';
    final userTypeEmoji = userType == 'doctor' ? '👨‍⚕️' : '💙';
    final userTypeDescription = userType == 'doctor'
        ? 'Connect with patients, manage appointments, and make a difference in people\'s lives.'
        : 'Connect with experienced therapists, book appointments, and start your journey to wellness.';

    final String featuresHtml = userType == 'doctor'
        ? '''
                        <div class="feature-item">
                            <div class="feature-icon">📋</div>
                            <div class="feature-content">
                                <h3>Manage Your Practice</h3>
                                <p>Access your patient list, manage schedules, and session records in one place</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">💬</div>
                            <div class="feature-content">
                                <h3>Secure Communication with Patients</h3>
                                <p>Stay connected with your patients via our privacy-compliant messaging system</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">💰</div>
                            <div class="feature-content">
                                <h3>Financial Management</h3>
                                <p>Track your revenue, manage invoices, and process patient payments easily</p>
                            </div>
                        </div>
        '''
        : '''
                        <div class="feature-item">
                            <div class="feature-icon">📅</div>
                            <div class="feature-content">
                                <h3>Book Appointments</h3>
                                <p>Schedule sessions with experienced therapists at your convenience</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">💬</div>
                            <div class="feature-content">
                                <h3>Secure Messaging</h3>
                                <p>Communicate with your therapist in a safe and private way</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">📋</div>
                            <div class="feature-content">
                                <h3>Track Progress</h3>
                                <p>Monitor your wellness journey and access your medical records</p>
                            </div>
                        </div>
        ''';

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 50px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
            }
            .welcome-icon {
                font-size: 64px;
                margin-bottom: 20px;
                position: relative;
                z-index: 1;
            }
            .header h1 {
                font-size: 32px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .content { 
                padding: 50px 40px;
                background: #ffffff;
            }
            .greeting {
                font-size: 28px;
                font-weight: 700;
                color: #1a1a1a;
                margin-bottom: 20px;
                text-align: center;
            }
            .welcome-message {
                font-size: 18px;
                color: #333333;
                line-height: 1.8;
                margin-bottom: 30px;
                text-align: center;
            }
            .user-type-badge {
                display: inline-block;
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white;
                padding: 12px 30px;
                border-radius: 50px;
                font-size: 16px;
                font-weight: 600;
                margin: 20px 0;
                box-shadow: 0 4px 15px rgba(32, 79, 207, 0.3);
            }
            .features-section {
                background: #f8f9fa;
                border-radius: 12px;
                padding: 30px;
                margin: 40px 0;
            }
            .features-title {
                font-size: 20px;
                font-weight: 700;
                color: #1a1a1a;
                margin-bottom: 20px;
                text-align: center;
            }
            .feature-item {
                display: flex;
                align-items: flex-start;
                margin-bottom: 20px;
                padding: 15px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }
            .feature-item:last-child {
                margin-bottom: 0;
            }
            .feature-icon {
                font-size: 28px;
                margin-right: 15px;
                flex-shrink: 0;
            }
            .feature-content h3 {
                font-size: 16px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 5px;
            }
            .feature-content p {
                font-size: 14px;
                color: #666666;
                line-height: 1.6;
                margin: 0;
            }
            .closing {
                text-align: center;
                margin-top: 40px;
                padding-top: 30px;
                border-top: 1px solid #e9ecef;
            }
            .closing p {
                font-size: 16px;
                color: #333333;
                line-height: 1.8;
                margin-bottom: 10px;
            }
            .signature {
                font-size: 16px;
                font-weight: 600;
                color: #204FCF;
                margin-top: 20px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            .social-links {
                margin: 20px 0;
            }
            .social-links a {
                display: inline-block;
                margin: 0 10px;
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 40px 20px; }
                .greeting { font-size: 24px; }
                .welcome-message { font-size: 16px; }
                .features-section { padding: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="welcome-icon">🎉</div>
                    <h1>Welcome to Estaraht!</h1>
                </div>
                <div class="content">
                    <div class="greeting">Hello $sanitizedUserName!</div>
                    <p class="welcome-message">
                        We're thrilled to have you join our community! Your account has been successfully created.
                    </p>
                    
                    <div style="text-align: center;">
                        <div class="user-type-badge">
                            $userTypeEmoji Registered as $sanitizedUserType
                        </div>
                    </div>

                    <p class="welcome-message" style="font-size: 16px; margin-top: 30px;">
                        $userTypeDescription
                    </p>

                    <div class="features-section">
                        <div class="features-title">What You Can Do</div>
                        
                        $featuresHtml
                    </div>

                    <div class="closing">
                        <p>We're here to support you every step of the way.</p>
                        <p>If you have any questions, our support team is ready to help.</p>
                        <div class="signature">The Estaraht Team 💙</div>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>Estaraht - Your Trusted Therapy Companion</strong></p>
                    <p>&copy; 2025 Estaraht. All rights reserved.</p>
                </div>
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 40px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            }
            .header h1 {
                font-size: 28px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .icon-wrapper {
                width: 80px;
                height: 80px;
                background: rgba(255,255,255,0.2);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 20px;
                position: relative;
                z-index: 1;
            }
            .icon-wrapper::before {
                content: '🔐';
                font-size: 40px;
            }
            .content { 
                padding: 50px 40px; 
                text-align: center;
                background: #ffffff;
            }
            .greeting {
                font-size: 24px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 15px;
            }
            .message {
                font-size: 16px;
                color: #666666;
                line-height: 1.6;
                margin-bottom: 30px;
            }
            .otp-container {
                margin: 40px 0;
            }
            .otp-label {
                font-size: 14px;
                color: #888888;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 15px;
                font-weight: 600;
            }
            .otp-code { 
                background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
                padding: 25px 30px; 
                border-radius: 12px; 
                font-size: 42px; 
                font-weight: 700; 
                color: #204FCF; 
                letter-spacing: 12px; 
                margin: 0 auto;
                display: inline-block;
                border: 2px dashed #204FCF;
                box-shadow: 0 4px 15px rgba(32, 79, 207, 0.1);
                font-family: 'Courier New', monospace;
            }
            .expiry-notice {
                background: #fff4e6;
                border-left: 4px solid #ffa726;
                padding: 15px 20px;
                border-radius: 8px;
                margin: 30px 0;
                text-align: left;
            }
            .expiry-notice p {
                font-size: 14px;
                color: #e65100;
                margin: 0;
                display: flex;
                align-items: center;
            }
            .expiry-notice p::before {
                content: '⏰';
                margin-right: 10px;
                font-size: 18px;
            }
            .security-tip {
                background: #f0f4ff;
                padding: 20px;
                border-radius: 8px;
                margin-top: 30px;
                text-align: left;
            }
            .security-tip p {
                font-size: 13px;
                color: #555555;
                margin: 0;
                line-height: 1.6;
            }
            .security-tip strong {
                color: #204FCF;
                display: block;
                margin-bottom: 8px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 30px 20px; }
                .otp-code { font-size: 32px; letter-spacing: 8px; padding: 20px 25px; }
                .greeting { font-size: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="icon-wrapper"></div>
                    <h1>Verify Your Account</h1>
                </div>
                <div class="content">
                    <div class="greeting">Hello $sanitizedUserName! 👋</div>
                    <p class="message">
                        We're excited to have you join Estaraht! To complete your registration, please use the verification code below.
                    </p>
                    
                    <div class="otp-container">
                        <div class="otp-label">Your Verification Code</div>
                        <div class="otp-code">$sanitizedOtpCode</div>
                    </div>

                    <div class="expiry-notice">
                        <p>This code will expire in 5 minutes for your security.</p>
                    </div>

                    <div class="security-tip">
                        <strong>🔒 Security Tip</strong>
                        <p>Never share this code with anyone. Estaraht staff will never ask for your verification code.</p>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>Estaraht - Your Trusted Therapy Companion</strong></p>
                    <p>If you didn't request this code, please ignore this email.</p>
                    <p>&copy; 2025 Estaraht. All rights reserved.</p>
                </div>
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 50px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
            }
            .icon-wrapper {
                width: 80px;
                height: 80px;
                background: rgba(255,255,255,0.2);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 20px;
                position: relative;
                z-index: 1;
            }
            .icon-wrapper::before {
                content: '🔑';
                font-size: 40px;
            }
            .header h1 {
                font-size: 32px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .content { 
                padding: 50px 40px;
                background: #ffffff;
            }
            .greeting {
                font-size: 24px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 15px;
            }
            .message {
                font-size: 16px;
                color: #666666;
                line-height: 1.8;
                margin-bottom: 30px;
            }
            .security-notice {
                background: #fff4e6;
                border-left: 4px solid #ffa726;
                padding: 20px;
                border-radius: 8px;
                margin: 30px 0;
                text-align: left;
            }
            .security-notice p {
                font-size: 14px;
                color: #e65100;
                margin: 0;
                line-height: 1.6;
                display: flex;
                align-items: flex-start;
            }
            .security-notice p::before {
                content: '⚠️';
                margin-right: 10px;
                font-size: 18px;
                flex-shrink: 0;
            }
            .info-box {
                background: #f0f4ff;
                padding: 20px;
                border-radius: 8px;
                margin-top: 30px;
            }
            .info-box p {
                font-size: 14px;
                color: #555555;
                margin: 0;
                line-height: 1.6;
            }
            .info-box strong {
                color: #204FCF;
                display: block;
                margin-bottom: 8px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 40px 20px; }
                .greeting { font-size: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="icon-wrapper"></div>
                    <h1>Reset Your Password</h1>
                </div>
                <div class="content">
                    <div class="greeting">Hello $sanitizedUserName!</div>
                    <p class="message">
                        We received a request to reset your password for your Estaraht account. Click the button below to create a new password.
                    </p>
                    <div style="text-align: center; margin: 24px 0;">
                        <a href="$resetLink" style="display: inline-block; background: linear-gradient(135deg, #204FCF 0%, #667eea 100%); color: white; padding: 14px 32px; text-decoration: none; border-radius: 8px; font-size: 16px; font-weight: 600;">Reset Password</a>
                    </div>

                    <div class="security-notice">
                        <p>This link will expire in 1 hour for your security. If you didn't request a password reset, please ignore this email.</p>
                    </div>

                    <div class="info-box">
                        <strong>🔒 Security Tips</strong>
                        <p>• Never share your password with anyone<br>
                        • Use a strong, unique password<br>
                        • If you didn't request this, your account may be at risk - contact support immediately</p>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>Estaraht - Your Trusted Therapy Companion</strong></p>
                    <p>If you're having trouble, you can also copy and paste this link into your browser:</p>
                    <p style="word-break: break-all; font-size: 11px; color: #666;">$resetLink</p>
                    <p>&copy; 2025 Estaraht. All rights reserved.</p>
                </div>
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 50px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
            }
            .icon-wrapper {
                font-size: 64px;
                margin-bottom: 20px;
                position: relative;
                z-index: 1;
            }
            .header h1 {
                font-size: 32px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .content { 
                padding: 50px 40px;
                background: #ffffff;
            }
            .greeting {
                font-size: 24px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 20px;
                text-align: center;
            }
            .confirmation-message {
                font-size: 18px;
                color: #333333;
                line-height: 1.8;
                margin-bottom: 40px;
                text-align: center;
                padding: 20px;
                background: #f0f9ff;
                border-radius: 12px;
                border-left: 4px solid #204FCF;
            }
            .appointment-details {
                background: #f8f9fa;
                border-radius: 12px;
                padding: 30px;
                margin: 30px 0;
            }
            .details-title {
                font-size: 20px;
                font-weight: 700;
                color: #1a1a1a;
                margin-bottom: 25px;
                text-align: center;
            }
            .detail-item {
                display: flex;
                align-items: center;
                margin-bottom: 20px;
                padding: 15px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }
            .detail-item:last-child {
                margin-bottom: 0;
            }
            .detail-icon {
                font-size: 28px;
                margin-right: 15px;
                flex-shrink: 0;
            }
            .detail-content {
                flex: 1;
            }
            .detail-label {
                font-size: 13px;
                color: #888888;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 5px;
                font-weight: 600;
            }
            .detail-value {
                font-size: 18px;
                font-weight: 600;
                color: #1a1a1a;
            }
            .reminder-box {
                background: #fff4e6;
                border-left: 4px solid #ffa726;
                padding: 20px;
                border-radius: 8px;
                margin: 30px 0;
            }
            .reminder-box p {
                font-size: 14px;
                color: #e65100;
                margin: 0;
                line-height: 1.6;
            }
            .reminder-box strong {
                display: block;
                margin-bottom: 8px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 40px 20px; }
                .greeting { font-size: 20px; }
                .appointment-details { padding: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="icon-wrapper">✅</div>
                    <h1>Appointment Confirmed!</h1>
                </div>
                <div class="content">
                    <div class="greeting">Hello $sanitizedUserName!</div>
                    <p class="confirmation-message">
                        Your appointment has been successfully confirmed. We look forward to seeing you!
                    </p>
                    
                    <div class="appointment-details">
                        <div class="details-title">Appointment Details</div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">👨‍⚕️</div>
                            <div class="detail-content">
                                <div class="detail-label">Therapist</div>
                                <div class="detail-value">$sanitizedDoctorName</div>
                            </div>
                        </div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">📅</div>
                            <div class="detail-content">
                                <div class="detail-label">Date</div>
                                <div class="detail-value">$appointmentDate</div>
                            </div>
                        </div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">🕐</div>
                            <div class="detail-content">
                                <div class="detail-label">Time</div>
                                <div class="detail-value">$appointmentTime</div>
                            </div>
                        </div>
                    </div>

                    <div class="reminder-box">
                        <strong>📝 Important Reminders</strong>
                        <p>• Please arrive 5 minutes before your scheduled time<br>
                        • Ensure you have a stable internet connection for video sessions<br>
                        • You can reschedule or cancel up to 24 hours before your appointment</p>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>Estaraht - Your Trusted Therapy Companion</strong></p>
                    <p>Need to make changes? Log in to your account to manage your appointments.</p>
                    <p>&copy; 2025 Estaraht. All rights reserved.</p>
                </div>
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
    final userTypeEmoji = userType == 'doctor' ? '👨‍⚕️' : '💙';
    final userTypeDescription = userType == 'doctor'
        ? 'Bienvenue sur votre plateforme professionnelle où vous pouvez fournir des soins de santé mentale de qualité, gérer votre pratique et avoir un impact positif sur la vie des patients.'
        : 'Connectez-vous avec des thérapeutes expérimentés, réservez des rendez-vous et commencez votre parcours vers le bien-être.';

    // Different features for doctors vs patients in French
    final String featuresHtml = userType == 'doctor'
        ? '''
                        <div class="feature-item">
                            <div class="feature-icon">📋</div>
                            <div class="feature-content">
                                <h3>Gérer Votre Pratique</h3>
                                <p>Accédez à votre liste de patients, gestion des horaires et dossiers de séances en un seul endroit</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">💬</div>
                            <div class="feature-content">
                                <h3>Communication Sécurisée avec Patients</h3>
                                <p>Restez connecté avec vos patients via notre système de messagerie conforme aux normes de confidentialité</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">💰</div>
                            <div class="feature-content">
                                <h3>Gestion Financière</h3>
                                <p>Suivez vos revenus, gérez les factures et traitez les paiements des patients en toute simplicité</p>
                            </div>
                        </div>
        '''
        : '''
                        <div class="feature-item">
                            <div class="feature-icon">📅</div>
                            <div class="feature-content">
                                <h3>Réserver des Rendez-vous</h3>
                                <p>Planifiez des séances avec des thérapeutes expérimentés à votre convenance</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">💬</div>
                            <div class="feature-content">
                                <h3>Messagerie Sécurisée</h3>
                                <p>Communiquez avec votre thérapeute de manière sûre et privée</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">📋</div>
                            <div class="feature-content">
                                <h3>Suivre les Progrès</h3>
                                <p>Surveillez votre parcours de bien-être et accédez à vos dossiers médicaux</p>
                            </div>
                        </div>
        ''';

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 50px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
            }
            .welcome-icon {
                font-size: 64px;
                margin-bottom: 20px;
                position: relative;
                z-index: 1;
            }
            .header h1 {
                font-size: 32px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .content { 
                padding: 50px 40px;
                background: #ffffff;
            }
            .greeting {
                font-size: 28px;
                font-weight: 700;
                color: #1a1a1a;
                margin-bottom: 20px;
                text-align: center;
            }
            .welcome-message {
                font-size: 18px;
                color: #333333;
                line-height: 1.8;
                margin-bottom: 30px;
                text-align: center;
            }
            .user-type-badge {
                display: inline-block;
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white;
                padding: 12px 30px;
                border-radius: 50px;
                font-size: 16px;
                font-weight: 600;
                margin: 20px 0;
                box-shadow: 0 4px 15px rgba(32, 79, 207, 0.3);
            }
            .features-section {
                background: #f8f9fa;
                border-radius: 12px;
                padding: 30px;
                margin: 40px 0;
            }
            .features-title {
                font-size: 20px;
                font-weight: 700;
                color: #1a1a1a;
                margin-bottom: 20px;
                text-align: center;
            }
            .feature-item {
                display: flex;
                align-items: flex-start;
                margin-bottom: 20px;
                padding: 15px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }
            .feature-item:last-child {
                margin-bottom: 0;
            }
            .feature-icon {
                font-size: 28px;
                margin-right: 15px;
                flex-shrink: 0;
            }
            .feature-content h3 {
                font-size: 16px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 5px;
            }
            .feature-content p {
                font-size: 14px;
                color: #666666;
                line-height: 1.6;
                margin: 0;
            }
            .closing {
                text-align: center;
                margin-top: 40px;
                padding-top: 30px;
                border-top: 1px solid #e9ecef;
            }
            .closing p {
                font-size: 16px;
                color: #333333;
                line-height: 1.8;
                margin-bottom: 10px;
            }
            .signature {
                font-size: 16px;
                font-weight: 600;
                color: #204FCF;
                margin-top: 20px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            .social-links {
                margin: 20px 0;
            }
            .social-links a {
                display: inline-block;
                margin: 0 10px;
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 40px 20px; }
                .greeting { font-size: 24px; }
                .welcome-message { font-size: 16px; }
                .features-section { padding: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="welcome-icon">🎉</div>
                    <h1>Bienvenue à Estaraht!</h1>
                </div>
                <div class="content">
                    <div class="greeting">Bonjour $sanitizedUserName!</div>
                    <p class="welcome-message">
                        Nous sommes ravis de vous accueillir dans notre communauté! Votre compte a été créé avec succès.
                    </p>
                    
                    <div style="text-align: center;">
                        <div class="user-type-badge">
                            $userTypeEmoji Inscrit en tant que $sanitizedUserType
                        </div>
                    </div>

                    <p class="welcome-message" style="font-size: 16px; margin-top: 30px;">
                        $userTypeDescription
                    </p>

                    <div class="features-section">
                        <div class="features-title">Ce Que Vous Pouvez Faire</div>
                        
                        $featuresHtml
                    </div>

                    <div class="closing">
                        <p>Nous sommes là pour vous soutenir à chaque étape.</p>
                        <p>Si vous avez des questions, notre équipe de support est prête à vous aider.</p>
                        <div class="signature">L'équipe Estaraht 💙</div>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>Estaraht - Votre Compagnon de Thérapie de Confiance</strong></p>
                    <p>&copy; 2025 Estaraht. Tous droits réservés.</p>
                </div>
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 40px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            }
            .header h1 {
                font-size: 28px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .icon-wrapper {
                width: 80px;
                height: 80px;
                background: rgba(255,255,255,0.2);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 20px;
                position: relative;
                z-index: 1;
            }
            .icon-wrapper::before {
                content: '🔐';
                font-size: 40px;
            }
            .content { 
                padding: 50px 40px; 
                text-align: center;
                background: #ffffff;
            }
            .greeting {
                font-size: 24px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 15px;
            }
            .message {
                font-size: 16px;
                color: #666666;
                line-height: 1.6;
                margin-bottom: 30px;
            }
            .otp-container {
                margin: 40px 0;
            }
            .otp-label {
                font-size: 14px;
                color: #888888;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 15px;
                font-weight: 600;
            }
            .otp-code { 
                background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
                padding: 25px 30px; 
                border-radius: 12px; 
                font-size: 42px; 
                font-weight: 700; 
                color: #204FCF; 
                letter-spacing: 12px; 
                margin: 0 auto;
                display: inline-block;
                border: 2px dashed #204FCF;
                box-shadow: 0 4px 15px rgba(32, 79, 207, 0.1);
                font-family: 'Courier New', monospace;
            }
            .expiry-notice {
                background: #fff4e6;
                border-left: 4px solid #ffa726;
                padding: 15px 20px;
                border-radius: 8px;
                margin: 30px 0;
                text-align: left;
            }
            .expiry-notice p {
                font-size: 14px;
                color: #e65100;
                margin: 0;
                display: flex;
                align-items: center;
            }
            .expiry-notice p::before {
                content: '⏰';
                margin-right: 10px;
                font-size: 18px;
            }
            .security-tip {
                background: #f0f4ff;
                padding: 20px;
                border-radius: 8px;
                margin-top: 30px;
                text-align: left;
            }
            .security-tip p {
                font-size: 13px;
                color: #555555;
                margin: 0;
                line-height: 1.6;
            }
            .security-tip strong {
                color: #204FCF;
                display: block;
                margin-bottom: 8px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 30px 20px; }
                .otp-code { font-size: 32px; letter-spacing: 8px; padding: 20px 25px; }
                .greeting { font-size: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="icon-wrapper"></div>
                    <h1>Vérifiez Votre Compte</h1>
                </div>
                <div class="content">
                    <div class="greeting">Bonjour $sanitizedUserName! 👋</div>
                    <p class="message">
                        Nous sommes ravis de vous accueillir chez Estaraht! Pour finaliser votre inscription, veuillez utiliser le code de vérification ci-dessous.
                    </p>
                    
                    <div class="otp-container">
                        <div class="otp-label">Votre Code de Vérification</div>
                        <div class="otp-code">$sanitizedOtpCode</div>
                    </div>

                    <div class="expiry-notice">
                        <p>Ce code expirera dans 5 minutes pour votre sécurité.</p>
                    </div>

                    <div class="security-tip">
                        <strong>🔒 Conseil de Sécurité</strong>
                        <p>Ne partagez jamais ce code avec qui que ce soit. Le personnel d'Estaraht ne vous demandera jamais votre code de vérification.</p>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>Estaraht - Votre Compagnon de Thérapie de Confiance</strong></p>
                    <p>Si vous n'avez pas demandé ce code, veuillez ignorer cet e-mail.</p>
                    <p>&copy; 2025 Estaraht. Tous droits réservés.</p>
                </div>
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 50px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
            }
            .icon-wrapper {
                width: 80px;
                height: 80px;
                background: rgba(255,255,255,0.2);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 20px;
                position: relative;
                z-index: 1;
            }
            .icon-wrapper::before {
                content: '🔑';
                font-size: 40px;
            }
            .header h1 {
                font-size: 32px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .content { 
                padding: 50px 40px;
                background: #ffffff;
            }
            .greeting {
                font-size: 24px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 15px;
            }
            .message {
                font-size: 16px;
                color: #666666;
                line-height: 1.8;
                margin-bottom: 30px;
            }
            .security-notice {
                background: #fff4e6;
                border-left: 4px solid #ffa726;
                padding: 20px;
                border-radius: 8px;
                margin: 30px 0;
                text-align: left;
            }
            .security-notice p {
                font-size: 14px;
                color: #e65100;
                margin: 0;
                line-height: 1.6;
                display: flex;
                align-items: flex-start;
            }
            .security-notice p::before {
                content: '⚠️';
                margin-right: 10px;
                font-size: 18px;
                flex-shrink: 0;
            }
            .info-box {
                background: #f0f4ff;
                padding: 20px;
                border-radius: 8px;
                margin-top: 30px;
            }
            .info-box p {
                font-size: 14px;
                color: #555555;
                margin: 0;
                line-height: 1.6;
            }
            .info-box strong {
                color: #204FCF;
                display: block;
                margin-bottom: 8px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 40px 20px; }
                .greeting { font-size: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="icon-wrapper"></div>
                    <h1>Réinitialiser Votre Mot de Passe</h1>
                </div>
                <div class="content">
                    <div class="greeting">Bonjour $sanitizedUserName!</div>
                    <p class="message">
                        Nous avons reçu une demande de réinitialisation du mot de passe pour votre compte Estaraht. Cliquez sur le bouton ci-dessous pour créer un nouveau mot de passe.
                    </p>
                    <div style="text-align: center; margin: 24px 0;">
                        <a href="$resetLink" style="display: inline-block; background: linear-gradient(135deg, #204FCF 0%, #667eea 100%); color: white; padding: 14px 32px; text-decoration: none; border-radius: 8px; font-size: 16px; font-weight: 600;">Réinitialiser le Mot de Passe</a>
                    </div>

                    <div class="security-notice">
                        <p>Ce lien expirera dans 1 heure pour votre sécurité. Si vous n'avez pas demandé de réinitialisation de mot de passe, veuillez ignorer cet e-mail.</p>
                    </div>

                    <div class="info-box">
                        <strong>🔒 Conseils de Sécurité</strong>
                        <p>• Ne partagez jamais votre mot de passe avec qui que ce soit<br>
                        • Utilisez un mot de passe fort et unique<br>
                        • Si vous n'avez pas demandé cela, votre compte peut être en danger - contactez le support immédiatement</p>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>Estaraht - Votre Compagnon de Thérapie de Confiance</strong></p>
                    <p>Si vous avez des difficultés, vous pouvez également copier et coller ce lien dans votre navigateur:</p>
                    <p style="word-break: break-all; font-size: 11px; color: #666;">$resetLink</p>
                    <p>&copy; 2025 Estaraht. Tous droits réservés.</p>
                </div>
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 50px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
            }
            .icon-wrapper {
                font-size: 64px;
                margin-bottom: 20px;
                position: relative;
                z-index: 1;
            }
            .header h1 {
                font-size: 32px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .content { 
                padding: 50px 40px;
                background: #ffffff;
            }
            .greeting {
                font-size: 24px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 20px;
                text-align: center;
            }
            .confirmation-message {
                font-size: 18px;
                color: #333333;
                line-height: 1.8;
                margin-bottom: 40px;
                text-align: center;
                padding: 20px;
                background: #f0f9ff;
                border-radius: 12px;
                border-left: 4px solid #204FCF;
            }
            .appointment-details {
                background: #f8f9fa;
                border-radius: 12px;
                padding: 30px;
                margin: 30px 0;
            }
            .details-title {
                font-size: 20px;
                font-weight: 700;
                color: #1a1a1a;
                margin-bottom: 25px;
                text-align: center;
            }
            .detail-item {
                display: flex;
                align-items: center;
                margin-bottom: 20px;
                padding: 15px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }
            .detail-item:last-child {
                margin-bottom: 0;
            }
            .detail-icon {
                font-size: 28px;
                margin-right: 15px;
                flex-shrink: 0;
            }
            .detail-content {
                flex: 1;
            }
            .detail-label {
                font-size: 13px;
                color: #888888;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 5px;
                font-weight: 600;
            }
            .detail-value {
                font-size: 18px;
                font-weight: 600;
                color: #1a1a1a;
            }
            .reminder-box {
                background: #fff4e6;
                border-left: 4px solid #ffa726;
                padding: 20px;
                border-radius: 8px;
                margin: 30px 0;
            }
            .reminder-box p {
                font-size: 14px;
                color: #e65100;
                margin: 0;
                line-height: 1.6;
            }
            .reminder-box strong {
                display: block;
                margin-bottom: 8px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 40px 20px; }
                .greeting { font-size: 20px; }
                .appointment-details { padding: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="icon-wrapper">✅</div>
                    <h1>Rendez-vous Confirmé!</h1>
                </div>
                <div class="content">
                    <div class="greeting">Bonjour $sanitizedUserName!</div>
                    <p class="confirmation-message">
                        Votre rendez-vous a été confirmé avec succès. Nous avons hâte de vous voir!
                    </p>
                    
                    <div class="appointment-details">
                        <div class="details-title">Détails du Rendez-vous</div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">👨‍⚕️</div>
                            <div class="detail-content">
                                <div class="detail-label">Thérapeute</div>
                                <div class="detail-value">$sanitizedDoctorName</div>
                            </div>
                        </div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">📅</div>
                            <div class="detail-content">
                                <div class="detail-label">Date</div>
                                <div class="detail-value">$appointmentDate</div>
                            </div>
                        </div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">🕐</div>
                            <div class="detail-content">
                                <div class="detail-label">Heure</div>
                                <div class="detail-value">$appointmentTime</div>
                            </div>
                        </div>
                    </div>

                    <div class="reminder-box">
                        <strong>📝 Rappels Importants</strong>
                        <p>• Veuillez arriver 5 minutes avant votre heure prévue<br>
                        • Assurez-vous d'avoir une connexion Internet stable pour les séances vidéo<br>
                        • Vous pouvez reporter ou annuler jusqu'à 24 heures avant votre rendez-vous</p>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>Estaraht - Votre Compagnon de Thérapie de Confiance</strong></p>
                    <p>Besoin de faire des modifications? Connectez-vous à votre compte pour gérer vos rendez-vous.</p>
                    <p>&copy; 2025 Estaraht. Tous droits réservés.</p>
                </div>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // Arabic Templates
  static String _getArabicWelcomeTemplate(String userName, String userType) {
    final sanitizedUserName = userName.replaceAll(RegExp(r'[<>"\x27]'), '');
    final sanitizedUserType = userType == 'doctor' ? 'طبيب نفسي' : 'مريض';
    final userTypeEmoji = userType == 'doctor' ? '👨‍⚕️' : '💙';
    final userTypeDescription = userType == 'doctor'
        ? 'تواصل مع مرضاك، أدر المواعيد، واصنع فرقاً في حياة الناس.'
        : 'تواصل مع أطباء نفسيين ذوي خبرة، احجز المواعيد، وابدأ رحلتك نحو العافية.';

    final String featuresHtml = userType == 'doctor'
        ? '''
                        <div class="feature-item">
                            <div class="feature-icon">📋</div>
                            <div class="feature-content">
                                <h3>إدارة عيادتك</h3>
                                <p>الوصول إلى قائمة مرضاك وإدارة الجدول الزمني وملفات الجلسات في مكان واحد</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">💬</div>
                            <div class="feature-content">
                                <h3>التواصل الآمن مع المرضى</h3>
                                <p>ابق على اتصال مع مرضاك من خلال نظام المراسلة الخاص بنا الذي يتوافق مع معايير الخصوصية</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">💰</div>
                            <div class="feature-content">
                                <h3>الإدارة المالية</h3>
                                <p>تتبع إيراداتك وإدارة الفواتير ومعالجة مدفوعات المرضى بسهولة</p>
                            </div>
                        </div>
        '''
        : '''
                        <div class="feature-item">
                            <div class="feature-icon">📅</div>
                            <div class="feature-content">
                                <h3>حجز المواعيد</h3>
                                <p>حدد موعداً مع أطباء نفسيين ذوي خبرة في الوقت المناسب لك</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">💬</div>
                            <div class="feature-content">
                                <h3>المراسلة الآمنة</h3>
                                <p>تواصل مع طبيبك النفسي بطريقة آمنة وخاصة</p>
                            </div>
                        </div>
                        
                        <div class="feature-item">
                            <div class="feature-icon">📋</div>
                            <div class="feature-content">
                                <h3>تتبع التقدم</h3>
                                <p>راقب رحلة عافيتك والوصول إلى ملفاتك الطبية</p>
                            </div>
                        </div>
        ''';

    return '''
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: 'Tajawal', 'Noto Kufi Arabic', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                direction: rtl;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 50px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                left: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
            }
            .welcome-icon {
                font-size: 64px;
                margin-bottom: 20px;
                position: relative;
                z-index: 1;
            }
            .header h1 {
                font-size: 32px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .content { 
                padding: 50px 40px;
                background: #ffffff;
            }
            .greeting {
                font-size: 28px;
                font-weight: 700;
                color: #1a1a1a;
                margin-bottom: 20px;
                text-align: center;
            }
            .welcome-message {
                font-size: 18px;
                color: #333333;
                line-height: 1.8;
                margin-bottom: 30px;
                text-align: center;
            }
            .user-type-badge {
                display: inline-block;
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white;
                padding: 12px 30px;
                border-radius: 50px;
                font-size: 16px;
                font-weight: 600;
                margin: 20px 0;
                box-shadow: 0 4px 15px rgba(32, 79, 207, 0.3);
            }
            .features-section {
                background: #f8f9fa;
                border-radius: 12px;
                padding: 30px;
                margin: 40px 0;
            }
            .features-title {
                font-size: 20px;
                font-weight: 700;
                color: #1a1a1a;
                margin-bottom: 20px;
                text-align: center;
            }
            .feature-item {
                display: flex;
                align-items: flex-start;
                margin-bottom: 20px;
                padding: 15px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }
            .feature-item:last-child {
                margin-bottom: 0;
            }
            .feature-icon {
                font-size: 28px;
                margin-left: 15px;
                flex-shrink: 0;
            }
            .feature-content {
                text-align: right;
            }
            .feature-content h3 {
                font-size: 16px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 5px;
            }
            .feature-content p {
                font-size: 14px;
                color: #666666;
                line-height: 1.8;
                margin: 0;
            }
            .closing {
                text-align: center;
                margin-top: 40px;
                padding-top: 30px;
                border-top: 1px solid #e9ecef;
            }
            .closing p {
                font-size: 16px;
                color: #333333;
                line-height: 1.8;
                margin-bottom: 10px;
            }
            .signature {
                font-size: 16px;
                font-weight: 600;
                color: #204FCF;
                margin-top: 20px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            .social-links {
                margin: 20px 0;
            }
            .social-links a {
                display: inline-block;
                margin: 0 10px;
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 40px 20px; }
                .greeting { font-size: 24px; }
                .welcome-message { font-size: 16px; }
                .features-section { padding: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="welcome-icon">🎉</div>
                    <h1>!مرحباً بك في استرحت</h1>
                </div>
                <div class="content">
                    <div class="greeting">!مرحباً $sanitizedUserName</div>
                    <p class="welcome-message">
                        .يسعدنا انضمامك إلى مجتمعنا! تم إنشاء حسابك بنجاح
                    </p>
                    
                    <div style="text-align: center;">
                        <div class="user-type-badge">
                            $userTypeEmoji مسجل كـ $sanitizedUserType
                        </div>
                    </div>

                    <p class="welcome-message" style="font-size: 16px; margin-top: 30px;">
                        $userTypeDescription
                    </p>

                    <div class="features-section">
                        <div class="features-title">ما يمكنك فعله</div>
                        
                        $featuresHtml
                    </div>

                    <div class="closing">
                        <p>.نحن هنا لدعمك في كل خطوة</p>
                        <p>.إذا كان لديك أي أسئلة، فريق الدعم لدينا جاهز لمساعدتك</p>
                        <div class="signature">💙 فريق استرحت</div>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>استرحت - رفيقك الموثوق في العلاج النفسي</strong></p>
                    <p>&copy; 2025 استرحت. جميع الحقوق محفوظة.</p>
                </div>
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
    <html dir="rtl" lang="ar">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: 'Tajawal', 'Noto Kufi Arabic', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                direction: rtl;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 40px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                left: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            }
            .header h1 {
                font-size: 28px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .icon-wrapper {
                width: 80px;
                height: 80px;
                background: rgba(255,255,255,0.2);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 20px;
                position: relative;
                z-index: 1;
            }
            .icon-wrapper::before {
                content: '🔐';
                font-size: 40px;
            }
            .content { 
                padding: 50px 40px; 
                text-align: center;
                background: #ffffff;
            }
            .greeting {
                font-size: 24px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 15px;
            }
            .message {
                font-size: 16px;
                color: #666666;
                line-height: 1.8;
                margin-bottom: 30px;
            }
            .otp-container {
                margin: 40px 0;
            }
            .otp-label {
                font-size: 14px;
                color: #888888;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 15px;
                font-weight: 600;
            }
            .otp-code { 
                background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
                padding: 25px 30px; 
                border-radius: 12px; 
                font-size: 42px; 
                font-weight: 700; 
                color: #204FCF; 
                letter-spacing: 12px; 
                margin: 0 auto;
                display: inline-block;
                border: 2px dashed #204FCF;
                box-shadow: 0 4px 15px rgba(32, 79, 207, 0.1);
                font-family: 'Courier New', monospace;
            }
            .expiry-notice {
                background: #fff4e6;
                border-right: 4px solid #ffa726;
                padding: 15px 20px;
                border-radius: 8px;
                margin: 30px 0;
                text-align: right;
            }
            .expiry-notice p {
                font-size: 14px;
                color: #e65100;
                margin: 0;
                display: flex;
                align-items: center;
                justify-content: flex-end;
            }
            .expiry-notice p::after {
                content: '⏰';
                margin-right: 10px;
                font-size: 18px;
            }
            .security-tip {
                background: #f0f4ff;
                padding: 20px;
                border-radius: 8px;
                margin-top: 30px;
                text-align: right;
            }
            .security-tip p {
                font-size: 13px;
                color: #555555;
                margin: 0;
                line-height: 1.8;
            }
            .security-tip strong {
                color: #204FCF;
                display: block;
                margin-bottom: 8px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 30px 20px; }
                .otp-code { font-size: 32px; letter-spacing: 8px; padding: 20px 25px; }
                .greeting { font-size: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="icon-wrapper"></div>
                    <h1>تحقق من حسابك</h1>
                </div>
                <div class="content">
                    <div class="greeting">مرحباً $sanitizedUserName! 👋</div>
                    <p class="message">
                        يسعدنا انضمامك إلى استرحت! لإكمال تسجيلك، يرجى استخدام رمز التحقق أدناه.
                    </p>
                    
                    <div class="otp-container">
                        <div class="otp-label">رمز التحقق الخاص بك</div>
                        <div class="otp-code">$sanitizedOtpCode</div>
                    </div>

                    <div class="expiry-notice">
                        <p>سينتهي هذا الرمز خلال 5 دقائق لأمانك.</p>
                    </div>

                    <div class="security-tip">
                        <strong>🔒 نصيحة أمنية</strong>
                        <p>لا تشارك هذا الرمز مع أي شخص. لن يطلب منك موظفو استرحت أبداً رمز التحقق الخاص بك.</p>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>استرحت - رفيقك الموثوق في العلاج النفسي</strong></p>
                    <p>إذا لم تطلب هذا الرمز، يرجى تجاهل هذا البريد الإلكتروني.</p>
                    <p>&copy; 2025 استرحت. جميع الحقوق محفوظة.</p>
                </div>
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
    <html dir="rtl" lang="ar">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: 'Tajawal', 'Noto Kufi Arabic', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                direction: rtl;
                text-align: right;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
                direction: rtl;
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 50px 30px; 
                text-align: center;
                direction: rtl;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
            }
            .icon-wrapper {
                width: 80px;
                height: 80px;
                background: rgba(255,255,255,0.2);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 20px;
                position: relative;
                z-index: 1;
            }
            .icon-wrapper::before {
                content: '🔑';
                font-size: 40px;
            }
            .header h1 {
                font-size: 32px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .content { 
                padding: 50px 40px;
                background: #ffffff;
                direction: rtl;
                text-align: right;
            }
            .content .greeting {
                font-size: 24px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 15px;
                text-align: right;
            }
            .content .message {
                font-size: 16px;
                color: #666666;
                line-height: 1.8;
                margin-bottom: 30px;
                text-align: right;
            }
            .security-notice {
                background: #fff4e6;
                border-right: 4px solid #ffa726;
                padding: 20px;
                border-radius: 8px;
                margin: 30px 0;
                text-align: right;
            }
            .security-notice p {
                font-size: 14px;
                color: #e65100;
                margin: 0;
                line-height: 1.8;
                display: flex;
                align-items: flex-start;
                justify-content: flex-end;
            }
            .security-notice p::after {
                content: '⚠️';
                margin-right: 10px;
                font-size: 18px;
                flex-shrink: 0;
            }
            .info-box {
                background: #f0f4ff;
                padding: 20px;
                border-radius: 8px;
                margin-top: 30px;
                text-align: right;
            }
            .info-box p {
                font-size: 14px;
                color: #555555;
                margin: 0;
                line-height: 1.8;
            }
            .info-box strong {
                color: #204FCF;
                display: block;
                margin-bottom: 8px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                direction: rtl;
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 40px 20px; }
                .greeting { font-size: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="icon-wrapper"></div>
                    <h1>إعادة تعيين كلمة المرور</h1>
                </div>
                <div class="content">
                    <div class="greeting">مرحباً $sanitizedUserName!</div>
                    <p class="message">
                        تلقينا طلباً لإعادة تعيين كلمة المرور لحسابك في استرحت. انقر على الزر أدناه لإنشاء كلمة مرور جديدة.
                    </p>
                    <div style="text-align: center; margin: 24px 0;">
                        <a href="$resetLink" style="display: inline-block; background: linear-gradient(135deg, #204FCF 0%, #667eea 100%); color: white; padding: 14px 32px; text-decoration: none; border-radius: 8px; font-size: 16px; font-weight: 600;">إعادة تعيين كلمة المرور</a>
                    </div>

                    <div class="security-notice">
                        <p>سينتهي هذا الرابط خلال ساعة واحدة لأمانك. إذا لم تطلب إعادة تعيين كلمة المرور، يرجى تجاهل هذا البريد الإلكتروني.</p>
                    </div>

                    <div class="info-box">
                        <strong>🔒 نصائح أمنية</strong>
                        <p>• لا تشارك كلمة المرور الخاصة بك مع أي شخص أبداً<br>
                        • استخدم كلمة مرور قوية وفريدة<br>
                        • إذا لم تطلب ذلك، قد يكون حسابك في خطر - اتصل بالدعم فوراً</p>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>استرحت - رفيقك الموثوق في العلاج النفسي</strong></p>
                    <p>إذا كنت تواجه مشكلة، يمكنك أيضاً نسخ ولصق هذا الرابط في متصفحك:</p>
                    <p style="word-break: break-all; font-size: 11px; color: #666;">$resetLink</p>
                    <p>&copy; 2025 استرحت. جميع الحقوق محفوظة.</p>
                </div>
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
    <html dir="rtl" lang="ar">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: 'Tajawal', 'Noto Kufi Arabic', Arial, sans-serif; 
                margin: 0; 
                padding: 0; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                direction: rtl;
            }
            .email-wrapper { 
                padding: 40px 20px; 
            }
            .container { 
                max-width: 600px; 
                margin: 0 auto; 
                background: #ffffff; 
                border-radius: 16px; 
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #204FCF 0%, #667eea 100%);
                color: white; 
                padding: 50px 30px; 
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                left: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
            }
            .icon-wrapper {
                font-size: 64px;
                margin-bottom: 20px;
                position: relative;
                z-index: 1;
            }
            .header h1 {
                font-size: 32px;
                font-weight: 700;
                margin: 0;
                position: relative;
                z-index: 1;
            }
            .content { 
                padding: 50px 40px;
                background: #ffffff;
            }
            .greeting {
                font-size: 24px;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: 20px;
                text-align: center;
            }
            .confirmation-message {
                font-size: 18px;
                color: #333333;
                line-height: 1.8;
                margin-bottom: 40px;
                text-align: center;
                padding: 20px;
                background: #f0f9ff;
                border-radius: 12px;
                border-right: 4px solid #204FCF;
            }
            .appointment-details {
                background: #f8f9fa;
                border-radius: 12px;
                padding: 30px;
                margin: 30px 0;
            }
            .details-title {
                font-size: 20px;
                font-weight: 700;
                color: #1a1a1a;
                margin-bottom: 25px;
                text-align: center;
            }
            .detail-item {
                display: flex;
                align-items: center;
                margin-bottom: 20px;
                padding: 15px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }
            .detail-item:last-child {
                margin-bottom: 0;
            }
            .detail-icon {
                font-size: 28px;
                margin-left: 15px;
                flex-shrink: 0;
            }
            .detail-content {
                flex: 1;
                text-align: right;
            }
            .detail-label {
                font-size: 13px;
                color: #888888;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 5px;
                font-weight: 600;
            }
            .detail-value {
                font-size: 18px;
                font-weight: 600;
                color: #1a1a1a;
            }
            .reminder-box {
                background: #fff4e6;
                border-right: 4px solid #ffa726;
                padding: 20px;
                border-radius: 8px;
                margin: 30px 0;
                text-align: right;
            }
            .reminder-box p {
                font-size: 14px;
                color: #e65100;
                margin: 0;
                line-height: 1.8;
            }
            .reminder-box strong {
                display: block;
                margin-bottom: 8px;
            }
            .footer { 
                background: #f8f9fa; 
                padding: 30px 40px; 
                text-align: center; 
                color: #888888;
                border-top: 1px solid #e9ecef;
            }
            .footer p {
                font-size: 13px;
                margin: 5px 0;
            }
            .footer a {
                color: #204FCF;
                text-decoration: none;
            }
            @media only screen and (max-width: 600px) {
                .content { padding: 30px 20px; }
                .header { padding: 40px 20px; }
                .greeting { font-size: 20px; }
                .appointment-details { padding: 20px; }
            }
        </style>
    </head>
    <body>
        <div class="email-wrapper">
            <div class="container">
                <div class="header">
                    <div class="icon-wrapper">✅</div>
                    <h1>تم تأكيد الموعد!</h1>
                </div>
                <div class="content">
                    <div class="greeting">مرحباً $sanitizedUserName!</div>
                    <p class="confirmation-message">
                        تم تأكيد موعدك بنجاح. نتطلع إلى رؤيتك!
                    </p>
                    
                    <div class="appointment-details">
                        <div class="details-title">تفاصيل الموعد</div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">👨‍⚕️</div>
                            <div class="detail-content">
                                <div class="detail-label">الطبيب النفسي</div>
                                <div class="detail-value">$sanitizedDoctorName</div>
                            </div>
                        </div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">📅</div>
                            <div class="detail-content">
                                <div class="detail-label">التاريخ</div>
                                <div class="detail-value">$appointmentDate</div>
                            </div>
                        </div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">🕐</div>
                            <div class="detail-content">
                                <div class="detail-label">الوقت</div>
                                <div class="detail-value">$appointmentTime</div>
                            </div>
                        </div>
                    </div>

                    <div class="reminder-box">
                        <strong>📝 تذكيرات مهمة</strong>
                        <p>• يرجى الوصول قبل 5 دقائق من وقتك المحدد<br>
                        • تأكد من وجود اتصال إنترنت مستقر للجلسات المرئية<br>
                        • يمكنك إعادة الجدولة أو الإلغاء حتى 24 ساعة قبل موعدك</p>
                    </div>
                </div>
                <div class="footer">
                    <p><strong>استرحت - رفيقك الموثوق في العلاج النفسي</strong></p>
                    <p>تحتاج إلى إجراء تغييرات؟ سجل الدخول إلى حسابك لإدارة مواعيدك.</p>
                    <p>&copy; 2025 استرحت. جميع الحقوق محفوظة.</p>
                </div>
            </div>
        </div>
    </body>
    </html>
    ''';
  }
}
