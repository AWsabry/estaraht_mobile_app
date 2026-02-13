import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/shared/services/notifications/push_notification_service.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

/// Service to handle payment-related notifications
class PaymentNotificationService {
  /// Send notification when payment is completed successfully
  static Future<bool> notifyPaymentCompleted({
    required String doctorToken,
    required String patientName,
    required String appointmentId,
    required double amount,
    String? doctorName,
    String? appointmentDate,
    String? appointmentTime,
  }) async {
    try {
      loggerNoStack.i('💳 Sending payment completion notification...');

      // Send notification to doctor
      bool success =
          await PushNotificationService.sendPaymentCompletionNotification(
            doctorToken: doctorToken,
            patientName: patientName,
            appointmentId: appointmentId,
            amount: amount,
          );

      if (success) {
        loggerNoStack.i('✅ Payment notification sent successfully to doctor');

        // Optional: Send confirmation to patient as well
        await _sendPaymentConfirmationToPatient(
          patientName: patientName,
          doctorName: doctorName ?? 'Doctor',
          appointmentId: appointmentId,
          amount: amount,
          appointmentDate: appointmentDate,
          appointmentTime: appointmentTime,
        );

        return true;
      } else {
        loggerNoStack.e('❌ Failed to send payment notification to doctor');
        return false;
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error in payment notification: $e');
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Payment notification failed',
      );
      return false;
    }
  }

  /// Send payment confirmation to patient
  static Future<void> _sendPaymentConfirmationToPatient({
    required String patientName,
    required String doctorName,
    required String appointmentId,
    required double amount,
    String? appointmentDate,
    String? appointmentTime,
  }) async {
    try {
      // Get patient's FCM token (you'll need to implement this based on your user system)
      String? patientToken = await _getPatientFCMToken(patientName);

      if (patientToken != null) {
        await PushNotificationService.sendPushNotification(
          deviceToken: patientToken,
          title: 'Payment Successful! ✅',
          body:
              'Your payment of \$${amount.toStringAsFixed(2)} for appointment with Dr. $doctorName has been processed successfully.',
          data: {
            'type': 'payment_confirmation',
            'appointment_id': appointmentId,
            'doctor_name': doctorName,
            'amount': amount.toString(),
            if (appointmentDate != null) 'appointment_date': appointmentDate,
            if (appointmentTime != null) 'appointment_time': appointmentTime,
            'timestamp': TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch.toString(),
          },
        );

        loggerNoStack.i('✅ Payment confirmation sent to patient');
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error sending payment confirmation to patient: $e');
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Patient payment confirmation failed',
      );
    }
  }

  /// Get patient FCM token (implement based on your user management system)
  static Future<String?> _getPatientFCMToken(String patientName) async {
    // TODO: Implement this method to retrieve patient's FCM token from your database
    // This could be from Supabase, Firebase Firestore, or your preferred database

    // Example implementation:
    try {
      // Query your database to get patient's FCM token
      // final supabase = Supabase.instance.client;
      // final response = await supabase
      //     .from('users')
      //     .select('fcm_token')
      //     .eq('name', patientName)
      //     .single();
      // return response['fcm_token'] as String?;

      // For now, return null - you'll need to implement this
      return null;
    } catch (e) {
      loggerNoStack.e('❌ Error getting patient FCM token: $e');
      return null;
    }
  }

  /// Send payment failed notification
  static Future<bool> notifyPaymentFailed({
    required String patientToken,
    required String doctorName,
    required String appointmentId,
    required double amount,
    String? errorReason,
  }) async {
    try {
      bool success = await PushNotificationService.sendPushNotification(
        deviceToken: patientToken,
        title: 'Payment Failed ❌',
        body:
            'Your payment of \$${amount.toStringAsFixed(2)} for appointment with Dr. $doctorName could not be processed. Please try again.',
        data: {
          'type': 'payment_failed',
          'appointment_id': appointmentId,
          'doctor_name': doctorName,
          'amount': amount.toString(),
          if (errorReason != null) 'error_reason': errorReason,
          'timestamp': TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch.toString(),
        },
      );

      if (success) {
        loggerNoStack.i('✅ Payment failed notification sent to patient');
      } else {
        loggerNoStack.e('❌ Failed to send payment failed notification');
      }

      return success;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error sending payment failed notification: $e');
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Payment failed notification error',
      );
      return false;
    }
  }

  /// Send payment reminder notification
  static Future<bool> notifyPaymentReminder({
    required String patientToken,
    required String doctorName,
    required String appointmentId,
    required double amount,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    try {
      bool success = await PushNotificationService.sendPushNotification(
        deviceToken: patientToken,
        title: 'Payment Reminder 💳',
        body:
            'Don\'t forget to complete your payment of \$${amount.toStringAsFixed(2)} for your appointment with Dr. $doctorName on $appointmentDate at $appointmentTime.',
        data: {
          'type': 'payment_reminder',
          'appointment_id': appointmentId,
          'doctor_name': doctorName,
          'amount': amount.toString(),
          'appointment_date': appointmentDate,
          'appointment_time': appointmentTime,
          'timestamp': TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch.toString(),
        },
      );

      if (success) {
        loggerNoStack.i('✅ Payment reminder sent to patient');
      } else {
        loggerNoStack.e('❌ Failed to send payment reminder');
      }

      return success;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error sending payment reminder: $e');
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Payment reminder notification error',
      );
      return false;
    }
  }

  /// Example method to demonstrate usage after successful payment
  static Future<void> handleSuccessfulPayment({
    required String doctorId,
    required String patientName,
    required String appointmentId,
    required double amount,
    String? doctorName,
    String? appointmentDate,
    String? appointmentTime,
  }) async {
    try {
      // Get doctor's FCM token (you'll need to implement this)
      String? doctorToken = await _getDoctorFCMToken(doctorId);

      if (doctorToken != null) {
        await notifyPaymentCompleted(
          doctorToken: doctorToken,
          patientName: patientName,
          appointmentId: appointmentId,
          amount: amount,
          doctorName: doctorName,
          appointmentDate: appointmentDate,
          appointmentTime: appointmentTime,
        );
      } else {
        loggerNoStack.w(
          '⚠️ Doctor FCM token not found for doctorId: $doctorId',
        );
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error handling successful payment: $e');
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Handle successful payment error',
      );
    }
  }

  /// Get doctor FCM token (implement based on your user management system)
  static Future<String?> _getDoctorFCMToken(String doctorId) async {
    // TODO: Implement this method to retrieve doctor's FCM token from your database

    try {
      // Example implementation:
      // final supabase = Supabase.instance.client;
      // final response = await supabase
      //     .from('doctors')
      //     .select('fcm_token')
      //     .eq('id', doctorId)
      //     .single();
      // return response['fcm_token'] as String?;

      // For now, return null - you'll need to implement this
      return null;
    } catch (e) {
      loggerNoStack.e('❌ Error getting doctor FCM token: $e');
      return null;
    }
  }
}
