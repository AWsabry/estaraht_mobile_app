import 'package:get/get.dart';
import 'package:videocalling/shared/services/others/email_service.dart';

/// Service to send booking email notifications in multiple languages
class BookingEmailService {
  /// Get current app language code
  static String getCurrentLanguageCode() {
    final locale = Get.locale;
    if (locale == null) return 'ar'; // Default to Arabic

    // Extract language code (e.g., 'en' from 'en_US')
    final languageCode = locale.languageCode;

    // Support ar, en, fr
    if (languageCode == 'en') return 'en';
    if (languageCode == 'fr') return 'fr';
    return 'ar'; // Default to Arabic
  }

  /// Timezone note for doctor email - indicates time is in their local timezone
  static String _getTimezoneNote(String languageCode, int offsetHours) {
    if (offsetHours == 0) {
      return languageCode == 'ar'
          ? '(بتوقيتك المحلي)'
          : languageCode == 'fr'
          ? '(votre heure locale)'
          : '(Your local time)';
    }
    final gmt = offsetHours >= 0 ? 'GMT+$offsetHours' : 'GMT$offsetHours';
    return languageCode == 'ar'
        ? '(توقيتك: $gmt)'
        : languageCode == 'fr'
        ? '(Votre fuseau: $gmt)'
        : '(Your timezone: $gmt)';
  }

  /// Get email content in the appropriate language
  static Map<String, String> getEmailContent(String languageCode) {
    switch (languageCode) {
      case 'en':
        return {
          'doctor_subject': 'New Appointment Booking - Estaraht',
          'doctor_title': '🗓️ New Appointment Booking',
          'doctor_greeting': 'Hello Dr.',
          'doctor_message':
              'A new appointment has been booked with you successfully.',
          'patient_label': 'Patient Name:',
          'date_label': 'Date:',
          'time_label': 'Time:',
          'booking_id_label': 'Booking ID:',
          'doctor_footer_message':
              'You can view the appointment details through the app.',
          'doctor_note':
              'Please make sure to be present at the scheduled time.',
          'patient_subject': 'Appointment Confirmation - Estaraht',
          'patient_title': '✓ Appointment Confirmed',
          'patient_greeting': 'Hello',
          'patient_message':
              'Your appointment has been confirmed successfully.',
          'doctor_label': 'Therapist:',
          'patient_footer_message':
              'The session link will be sent before the scheduled time.',
          'patient_note': 'We wish you a useful and enjoyable session!',
          'app_name': 'Estaraht App - Mental Health Platform',
          'rights': 'All rights reserved.',
        };

      case 'fr':
        return {
          'doctor_subject': 'Nouvelle Réservation de Rendez-vous - Estaraht',
          'doctor_title': '🗓️ Nouvelle Réservation de Rendez-vous',
          'doctor_greeting': 'Bonjour Dr.',
          'doctor_message':
              'Un nouveau rendez-vous a été réservé avec vous avec succès.',
          'patient_label': 'Nom du Patient:',
          'date_label': 'Date:',
          'time_label': 'Heure:',
          'booking_id_label': 'ID de Réservation:',
          'doctor_footer_message':
              'Vous pouvez consulter les détails du rendez-vous via l\'application.',
          'doctor_note':
              'Veuillez vous assurer d\'être présent à l\'heure prévue.',
          'patient_subject': 'Confirmation de Rendez-vous - Estaraht',
          'patient_title': '✓ Rendez-vous Confirmé',
          'patient_greeting': 'Bonjour',
          'patient_message': 'Votre rendez-vous a été confirmé avec succès.',
          'doctor_label': 'Thérapeute:',
          'patient_footer_message':
              'Le lien de la séance sera envoyé avant l\'heure prévue.',
          'patient_note': 'Nous vous souhaitons une séance utile et agréable!',
          'app_name': 'Application Estaraht - Plateforme de Santé Mentale',
          'rights': 'Tous droits réservés.',
        };

      default: // Arabic
        return {
          'doctor_subject': 'حجز جلسة جديدة - Estaraht',
          'doctor_title': '🗓️ حجز جلسة جديدة',
          'doctor_greeting': 'مرحباً د.',
          'doctor_message': 'تم حجز جلسة جديدة معك بنجاح.',
          'patient_label': 'اسم المفحوص:',
          'date_label': 'التاريخ:',
          'time_label': 'الوقت:',
          'booking_id_label': 'رقم الحجز:',
          'doctor_footer_message':
              'يمكنك الاطلاع على تفاصيل الجلسة من خلال التطبيق.',
          'doctor_note': 'يرجى التأكد من الحضور في الموعد المحدد.',
          'patient_subject': 'تأكيد حجز الجلسة - Estaraht',
          'patient_title': '✓ تم تأكيد حجز الجلسة',
          'patient_greeting': 'مرحباً',
          'patient_message': 'تم تأكيد حجز جلستك بنجاح.',
          'doctor_label': 'المعالج:',
          'patient_footer_message': 'يرجى التأكد من الحضور في الموعد المحدد.',
          'patient_note': 'نتمنى لك جلسة مفيدة وممتعة!',
          'app_name': 'تطبيق استراحة - منصة الصحة النفسية',
          'rights': 'جميع الحقوق محفوظة.',
        };
    }
  }

  /// Send booking notification email to doctor
  /// [doctorTimezoneOffsetHours] - doctor's UTC offset; time shown is in doctor's local timezone
  static Future<bool> sendDoctorEmail({
    required String doctorEmail,
    required String doctorName,
    required String patientName,
    required String bookingId,
    required String formattedDate,
    required String timeOnly,
    int doctorTimezoneOffsetHours = 0,
  }) async {
    final languageCode = getCurrentLanguageCode();
    final content = getEmailContent(languageCode);
    final isRTL = languageCode == 'ar';
    final dir = isRTL ? 'rtl' : 'ltr';
    final lang = isRTL ? 'ar' : (languageCode == 'fr' ? 'fr' : 'en');
    final comma = isRTL ? '،' : ',';
    final textAlign = isRTL ? 'right' : 'left';

    // Timezone note for doctor - time is already in their timezone
    final timezoneNote = _getTimezoneNote(
      languageCode,
      doctorTimezoneOffsetHours,
    );

    final emailBody =
        '''
<!DOCTYPE html>
<html dir="$dir" lang="$lang">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; padding: 20px; direction: $dir; text-align: $textAlign; }
    .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }
    .header h1 { margin: 0; font-size: 24px; }
    .content { padding: 30px; direction: $dir; text-align: $textAlign; }
    .info-box { background-color: #f8f9fa; border-${isRTL ? 'right' : 'left'}: 4px solid #667eea; padding: 15px; margin: 20px 0; border-radius: 5px; }
    .info-row { display: flex; justify-content: space-between; margin: 10px 0; flex-direction: ${isRTL ? 'row-reverse' : 'row'}; }
    .label { font-weight: bold; color: #555; }
    .value { color: #333; }
    .footer { background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px; }
    .time-note { font-size: 11px; color: #888; margin-top: 4px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>${content['doctor_title']}</h1>
    </div>
    <div class="content">
      <p>${content['doctor_greeting']} $doctorName$comma</p>
      <p>${content['doctor_message']}</p>

      <div class="info-box">
        <div class="info-row">
          <span class="label">${content['patient_label']}</span>
          <span class="value">$patientName</span>
        </div>
        <div class="info-row">
          <span class="label">${content['date_label']}</span>
          <span class="value">$formattedDate</span>
        </div>
        <div class="info-row">
          <span class="label">${content['time_label']}</span>
          <span class="value">$timeOnly${timezoneNote.isNotEmpty ? '<br><span class="time-note">$timezoneNote</span>' : ''}</span>
        </div>
        <div class="info-row">
          <span class="label">${content['booking_id_label']}</span>
          <span class="value">$bookingId</span>
        </div>
      </div>

      <p>${content['doctor_footer_message']}</p>
      <p style="color: #666; font-size: 14px; margin-top: 20px;">${content['doctor_note']}</p>
    </div>
    <div class="footer">
      <p>${content['app_name']}</p>
      <p>© ${DateTime.now().year} Estaraht. ${content['rights']}</p>
    </div>
  </div>
</body>
</html>
''';

    try {
      return await EmailService.sendEmail(
        to: doctorEmail,
        subject: content['doctor_subject']!,
        body: emailBody,
        toName: doctorName,
        isHtml: true,
      );
    } catch (error) {
      print('Failed to send email to doctor: $error');
      return false;
    }
  }

  /// Send booking notification email to patient
  static Future<bool> sendPatientEmail({
    required String patientEmail,
    required String patientName,
    required String doctorName,
    required String bookingId,
    required String formattedDate,
    required String timeOnly,
  }) async {
    final languageCode = getCurrentLanguageCode();
    final content = getEmailContent(languageCode);
    final isRTL = languageCode == 'ar';
    final dir = isRTL ? 'rtl' : 'ltr';
    final lang = isRTL ? 'ar' : (languageCode == 'fr' ? 'fr' : 'en');
    final comma = isRTL ? '،' : ',';
    final textAlign = isRTL ? 'right' : 'left';
    final doctorPrefix = isRTL
        ? 'د. '
        : (languageCode == 'fr' ? 'Dr. ' : 'Dr. ');

    final emailBody =
        '''
<!DOCTYPE html>
<html dir="$dir" lang="$lang">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; padding: 20px; direction: $dir; text-align: $textAlign; }
    .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }
    .header h1 { margin: 0; font-size: 24px; }
    .success-icon { font-size: 48px; margin-bottom: 10px; }
    .content { padding: 30px; direction: $dir; text-align: $textAlign; }
    .info-box { background-color: #f8f9fa; border-${isRTL ? 'right' : 'left'}: 4px solid #667eea; padding: 15px; margin: 20px 0; border-radius: 5px; }
    .info-row { display: flex; justify-content: space-between; margin: 10px 0; flex-direction: ${isRTL ? 'row-reverse' : 'row'}; }
    .label { font-weight: bold; color: #555; }
    .value { color: #333; }
    .footer { background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="success-icon">✓</div>
      <h1>${content['patient_title']}</h1>
    </div>
    <div class="content">
      <p>${content['patient_greeting']} $patientName$comma</p>
      <p>${content['patient_message']}</p>

      <div class="info-box">
        <div class="info-row">
          <span class="label">${content['doctor_label']}</span>
          <span class="value">$doctorPrefix$doctorName</span>
        </div>
        <div class="info-row">
          <span class="label">${content['date_label']}</span>
          <span class="value">$formattedDate</span>
        </div>
        <div class="info-row">
          <span class="label">${content['time_label']}</span>
          <span class="value">$timeOnly</span>
        </div>
        <div class="info-row">
          <span class="label">${content['booking_id_label']}</span>
          <span class="value">$bookingId</span>
        </div>
      </div>

      <p>${content['patient_footer_message']}</p>
      <p style="color: #666; font-size: 14px; margin-top: 20px;">${content['patient_note']}</p>
    </div>
    <div class="footer">
      <p>${content['app_name']}</p>
      <p>© ${DateTime.now().year} Estaraht. ${content['rights']}</p>
    </div>
  </div>
</body>
</html>
''';

    try {
      return await EmailService.sendEmail(
        to: patientEmail,
        subject: content['patient_subject']!,
        body: emailBody,
        toName: patientName,
        isHtml: true,
      );
    } catch (error) {
      print('Failed to send email to patient: $error');
      return false;
    }
  }
}
