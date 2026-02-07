import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class InvoiceService {
  static final InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;
  InvoiceService._internal();

  String? _subscriptionTemplate;
  String? _withdrawalTemplate;
  String? _sessionSummaryTemplate;

  Future<void> _loadTemplates() async {
    try {
      _subscriptionTemplate ??= await rootBundle.loadString(
        'assets/email_templates/subscription_invoice.html',
      );
      _withdrawalTemplate ??= await rootBundle.loadString(
        'assets/email_templates/withdrawal_receipt.html',
      );
      _sessionSummaryTemplate ??= await rootBundle.loadString(
        'assets/email_templates/session_summary.html',
      );
    } catch (e) {
      loggerNoStack.e('Error loading email templates: $e');
    }
  }

  String _replaceTemplateVariables(
    String template,
    Map<String, String> variables,
  ) {
    String result = template;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }

  /// Get current app language code (en, ar, fr) for email language and RTL.
  String _getAppLanguageCode() {
    try {
      final languageController = Get.find<LanguageController>();
      final lang = languageController.currentLanguage.value;
      if (lang == 'ar' || lang == 'fr' || lang == 'en') return lang;
    } catch (_) {}
    final locale = Get.locale;
    if (locale != null) {
      if (locale.languageCode == 'ar' || locale.languageCode == 'fr') return locale.languageCode;
      return 'en';
    }
    return 'en';
  }

  /// Email subject by type and app language.
  String _getEmailSubject(String type, String lang) {
    switch (type) {
      case 'subscription_invoice':
        return lang == 'ar'
            ? 'فاتورة اشتراكك - Estaraht'
            : lang == 'fr'
                ? 'Votre facture d\'abonnement Estaraht'
                : 'Your Estaraht Subscription Invoice';
      case 'withdrawal_receipt':
        return lang == 'ar'
            ? 'إيصال السحب - Estaraht'
            : lang == 'fr'
                ? 'Votre reçu de retrait Estaraht'
                : 'Your Estaraht Withdrawal Receipt';
      case 'session_summary':
        return lang == 'ar'
            ? 'ملخص الجلسة - Estaraht'
            : lang == 'fr'
                ? 'Résumé de la séance - Estaraht'
                : 'Your Estaraht Session Summary';
      default:
        return 'Estaraht';
    }
  }

  /// Apply RTL to HTML when app language is Arabic (no new data/buttons).
  String _applyRtlSupport(String htmlContent, String appLanguageCode) {
    if (appLanguageCode != 'ar') return htmlContent;

    htmlContent = htmlContent.replaceAll('<html>', '<html dir="rtl" lang="ar">');
    htmlContent = htmlContent.replaceAll(
      '<body style="',
      '<body class="rtl" style="',
    );
    htmlContent = htmlContent.replaceAll(
      '<div style="background: #fff;',
      '<div class="rtl" style="background: #fff;',
    );
    return htmlContent;
  }

  String _generateInvoiceNumber() {
    final now = TimezoneService.getCurrentMauritaniaTime();
    return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  Future<bool> sendSubscriptionInvoice({
    required String patientEmail,
    required String patientName,
    required String planName,
    required int sessionsCount,
    required String amount,
    required String currency,
    String? paymentMethod,
  }) async {
    try {
      loggerNoStack.i(
        '📧 InvoiceService: Starting to send subscription invoice to $patientEmail',
      );

      await _loadTemplates();

      if (_subscriptionTemplate == null) {
        loggerNoStack.e('❌ InvoiceService: Subscription template not loaded');
        return false;
      }

      loggerNoStack.i(
        '📧 InvoiceService: Template loaded, preparing variables',
      );

      final variables = {
        'PATIENT_NAME': patientName,
        'INVOICE_NUMBER': _generateInvoiceNumber(),
        'DATE': _formatDate(TimezoneService.getCurrentMauritaniaTime()),
        'PLAN_NAME': planName,
        'SESSIONS_COUNT': sessionsCount.toString(),
        'PAYMENT_METHOD': paymentMethod ?? 'Credit Card',
        'AMOUNT': '$currency $amount',
        'APP_LINK': 'https://estaraht.com/app',
      };

      final appLang = _getAppLanguageCode();
      String htmlContent = _replaceTemplateVariables(
        _subscriptionTemplate!,
        variables,
      );

      htmlContent = _applyRtlSupport(htmlContent, appLang);

      loggerNoStack.i('📧 InvoiceService: Calling EmailService.sendEmail...');

      final success = await EmailService.sendEmail(
        to: patientEmail,
        toName: patientName,
        subject: _getEmailSubject('subscription_invoice', appLang),
        body: htmlContent,
        isHtml: true,
      );

      if (success) {
        loggerNoStack.i(
          '✅ InvoiceService: Subscription invoice sent successfully to $patientEmail',
        );
      } else {
        loggerNoStack.w(
          '⚠️ InvoiceService: EmailService returned false for $patientEmail',
        );
      }
      return success;
    } catch (e, stackTrace) {
      loggerNoStack.e(
        '❌ InvoiceService: Error sending subscription invoice: $e',
      );
      loggerNoStack.e('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> sendWithdrawalReceipt({
    required String doctorEmail,
    required String doctorName,
    required String amount,
    required String currency,
    required String remainingBalance,
    String? status,
  }) async {
    try {
      await _loadTemplates();

      if (_withdrawalTemplate == null) {
        loggerNoStack.e('Withdrawal template not loaded');
        return false;
      }

      final variables = {
        'DOCTOR_NAME': doctorName,
        'TRANSACTION_ID':
            'WTH-${TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch}',
        'DATE': _formatDate(TimezoneService.getCurrentMauritaniaTime()),
        'STATUS': status ?? 'Processing',
        'AMOUNT': '$currency $amount',
        'REMAINING_BALANCE': '$currency $remainingBalance',
      };

      final appLang = _getAppLanguageCode();
      String htmlContent = _replaceTemplateVariables(
        _withdrawalTemplate!,
        variables,
      );

      htmlContent = _applyRtlSupport(htmlContent, appLang);

      final success = await EmailService.sendEmail(
        to: doctorEmail,
        toName: doctorName,
        subject: _getEmailSubject('withdrawal_receipt', appLang),
        body: htmlContent,
        isHtml: true,
      );

      if (success) {
        loggerNoStack.i('Withdrawal receipt sent to $doctorEmail');
      }
      return success;
    } catch (e) {
      loggerNoStack.e('Error sending withdrawal receipt: $e');
      return false;
    }
  }

  Future<bool> sendSessionSummary({
    required String recipientEmail,
    required String recipientName,
    required bool isDoctor,
    required String sessionId,
    required String sessionDate,
    required String sessionTime,
    required String duration,
    required String doctorName,
    required String patientName,
    String? sessionsRemaining,
    String? sessionEarnings,
  }) async {
    try {
      await _loadTemplates();

      if (_sessionSummaryTemplate == null) {
        loggerNoStack.e('Session summary template not loaded');
        return false;
      }

      final variables = {
        'RECIPIENT_NAME': recipientName,
        'SESSION_ID': sessionId,
        'SESSION_DATE': sessionDate,
        'SESSION_TIME': sessionTime,
        'DURATION': duration,
        'DOCTOR_NAME': doctorName,
        'PATIENT_NAME': patientName,
        'SESSIONS_REMAINING': sessionsRemaining ?? 'N/A',
        'SESSION_EARNINGS': sessionEarnings ?? 'N/A',
        'APP_LINK': 'https://estaraht.com/app',
      };

      String htmlContent = _replaceTemplateVariables(
        _sessionSummaryTemplate!,
        variables,
      );

      if (isDoctor) {
        htmlContent = htmlContent
            .replaceAll('{{#IF_PATIENT}}', '<!-- ')
            .replaceAll('{{/IF_PATIENT}}', ' -->')
            .replaceAll('{{#IF_DOCTOR}}', '')
            .replaceAll('{{/IF_DOCTOR}}', '');
      } else {
        htmlContent = htmlContent
            .replaceAll('{{#IF_DOCTOR}}', '<!-- ')
            .replaceAll('{{/IF_DOCTOR}}', ' -->')
            .replaceAll('{{#IF_PATIENT}}', '')
            .replaceAll('{{/IF_PATIENT}}', '');
      }

      final appLang = _getAppLanguageCode();
      htmlContent = _applyRtlSupport(htmlContent, appLang);

      final success = await EmailService.sendEmail(
        to: recipientEmail,
        toName: recipientName,
        subject: _getEmailSubject('session_summary', appLang),
        body: htmlContent,
        isHtml: true,
      );

      if (success) {
        loggerNoStack.i('Session summary sent to $recipientEmail');
      }
      return success;
    } catch (e) {
      loggerNoStack.e('Error sending session summary: $e');
      return false;
    }
  }

  Future<void> sendSessionSummaryToBothParties({
    required String sessionId,
    required String sessionDate,
    required String sessionTime,
    required String duration,
    required String doctorId,
    required String doctorName,
    required String doctorEmail,
    required String patientId,
    required String patientName,
    required String patientEmail,
    String? sessionsRemaining,
    String? sessionEarnings,
  }) async {
    await sendSessionSummary(
      recipientEmail: patientEmail,
      recipientName: patientName,
      isDoctor: false,
      sessionId: sessionId,
      sessionDate: sessionDate,
      sessionTime: sessionTime,
      duration: duration,
      doctorName: doctorName,
      patientName: patientName,
      sessionsRemaining: sessionsRemaining,
    );

    await sendSessionSummary(
      recipientEmail: doctorEmail,
      recipientName: doctorName,
      isDoctor: true,
      sessionId: sessionId,
      sessionDate: sessionDate,
      sessionTime: sessionTime,
      duration: duration,
      doctorName: doctorName,
      patientName: patientName,
      sessionEarnings: sessionEarnings,
    );
  }
}

final invoiceService = InvoiceService();
