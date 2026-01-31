import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class SubscriptionExpiryService extends GetxService {
  final supabase = Supabase.instance.client;

  /// Check if subscription has expired and update accordingly
  Future<void> checkSubscriptionExpiry(String patientId) async {
    try {
      // Get patient's current subscription info
      final patientData = await supabase
          .from('patients')
          .select(
              'subscription_expires_at, current_subscription_id, sessions_available')
          .eq('id', patientId)
          .maybeSingle();

      if (patientData == null) return;

      final expiresAtStr = patientData['subscription_expires_at'];
      if (expiresAtStr == null) return; // No active subscription

      final expiresAt = DateTime.parse(expiresAtStr);

      // Check if subscription has expired
      if (TimezoneService.getCurrentMauritaniaTime().isAfter(expiresAt)) {
        loggerNoStack.i('Subscription expired for patient $patientId');

        // Reset sessions to 0 (subscription expired)
        await supabase.from('patients').update({
          'sessions_available': 0,
          'subscribed': false,
          'subscription_expires_at': null,
          'current_subscription_id': null,
        }).eq('id', patientId);

        // Mark subscription as expired
        final subscriptionId = patientData['current_subscription_id'];
        if (subscriptionId != null) {
          await supabase.from('patient_plan_subscriptions').update({
            'status': 'expired',
          }).eq('id', subscriptionId);
        }

        loggerNoStack.i('Patient sessions reset to 0 due to expiry');
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('Error checking subscription expiry: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    }
  }
}
