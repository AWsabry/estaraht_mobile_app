import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/shared/services/invoice_service.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

/// Service for managing patient sessions (available and pending)
class SessionManagementService {
  final supabase = Supabase.instance.client;

  /// Deduct a session from available and add to pending
  /// Called when booking an appointment
  Future<bool> deductSessionOnBooking(String patientId) async {
    try {
      loggerNoStack.i(
        '📉 Deducting session on booking for patient: $patientId',
      );

      // Get current counts
      final patientData = await supabase
          .from('patients')
          .select('sessions_available, sessions_pending')
          .eq('id', patientId)
          .single();

      final available = patientData['sessions_available'] ?? 0;
      final pending = patientData['sessions_pending'] ?? 0;

      if (available <= 0) {
        loggerNoStack.w('⚠️ No sessions available to deduct');
        return false;
      }

      // Update counts
      await supabase
          .from('patients')
          .update({
            'sessions_available': available - 1,
            'sessions_pending': pending + 1,
          })
          .eq('id', patientId);

      loggerNoStack.i(
        '✅ Session deducted: Available $available → ${available - 1}, '
        'Pending $pending → ${pending + 1}',
      );

      return true;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error deducting session: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Return a session from pending to available
  /// Called when canceling an appointment
  Future<bool> returnSessionOnCancellation(String patientId) async {
    try {
      loggerNoStack.i(
        '📈 Returning session on cancellation for patient: $patientId',
      );

      // Get current counts
      final patientData = await supabase
          .from('patients')
          .select('sessions_available, sessions_pending')
          .eq('id', patientId)
          .single();

      final available = patientData['sessions_available'] ?? 0;
      final pending = patientData['sessions_pending'] ?? 0;

      if (pending <= 0) {
        loggerNoStack.w('⚠️ No pending sessions to return');
        return false;
      }

      // Update counts
      await supabase
          .from('patients')
          .update({
            'sessions_available': available + 1,
            'sessions_pending': pending - 1,
          })
          .eq('id', patientId);

      loggerNoStack.i(
        '✅ Session returned: Available $available → ${available + 1}, '
        'Pending $pending → ${pending - 1}',
      );

      return true;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error returning session: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Remove a session from pending
  /// Called when both doctor and patient confirm session completion
  Future<bool> completeSession(String patientId) async {
    try {
      loggerNoStack.i('✅ Completing session for patient: $patientId');

      // Get current pending count
      final patientData = await supabase
          .from('patients')
          .select('sessions_pending')
          .eq('id', patientId)
          .single();

      final pending = patientData['sessions_pending'] ?? 0;

      if (pending <= 0) {
        loggerNoStack.w('⚠️ No pending sessions to complete');
        return false;
      }

      // Decrease pending count (session is consumed)
      await supabase
          .from('patients')
          .update({'sessions_pending': pending - 1})
          .eq('id', patientId);

      loggerNoStack.i('✅ Session completed: Pending $pending → ${pending - 1}');

      return true;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error completing session: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Mark session as complete from doctor side
  Future<SessionConfirmationResult> confirmSessionFromDoctor({
    required String bookingId,
    required String patientId,
    required String doctorId,
  }) async {
    try {
      loggerNoStack.i('👨‍⚕️ Doctor confirming session: $bookingId');

      // Get current booking status
      final booking = await supabase
          .from('bookings')
          .select('doctor_confirmed, patient_confirmed, status, doctor_id')
          .eq('id', bookingId)
          .single();

      final patientConfirmed = booking['patient_confirmed'] ?? false;
      final status = booking['status'] ?? '';

      if (status == 'completed') {
        return SessionConfirmationResult(
          success: true,
          bothConfirmed: true,
          message: 'Session already completed',
        );
      }

      // Mark doctor as confirmed
      await supabase
          .from('bookings')
          .update({'doctor_confirmed': true})
          .eq('id', bookingId);

      // Check if both confirmed
      final bothConfirmed = patientConfirmed;

      if (bothConfirmed) {
        // Both confirmed - complete the session
        await supabase
            .from('bookings')
            .update({
              'status': 'completed',
              'completed_at': TimezoneService.getCurrentMauritaniaTime().toIso8601String(),
            })
            .eq('id', bookingId);

        // Deduct from pending sessions
        await completeSession(patientId);

        // Transfer payment to doctor
        await _transferPaymentToDoctor(
          bookingId: bookingId,
          doctorId: doctorId,
          patientId: patientId,
        );

        // Send session summary emails to both parties
        await _sendSessionCompletionEmails(
          bookingId: bookingId,
          doctorId: doctorId,
          patientId: patientId,
        );

        loggerNoStack.i('✅ Both parties confirmed - session completed');

        return SessionConfirmationResult(
          success: true,
          bothConfirmed: true,
          message: 'Session completed successfully',
        );
      } else {
        loggerNoStack.i('⏳ Waiting for patient confirmation');

        return SessionConfirmationResult(
          success: true,
          bothConfirmed: false,
          message: 'Waiting for patient to confirm',
        );
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error confirming session from doctor: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      return SessionConfirmationResult(
        success: false,
        bothConfirmed: false,
        message: 'Failed to confirm session',
      );
    }
  }

  /// Mark session as complete from patient side
  Future<SessionConfirmationResult> confirmSessionFromPatient({
    required String bookingId,
    required String patientId,
  }) async {
    try {
      loggerNoStack.i('👤 Patient confirming session: $bookingId');

      // Get current booking status
      final booking = await supabase
          .from('bookings')
          .select('doctor_confirmed, patient_confirmed, status, doctor_id')
          .eq('id', bookingId)
          .single();

      final doctorConfirmed = booking['doctor_confirmed'] ?? false;
      final status = booking['status'] ?? '';
      final doctorId = booking['doctor_id'] ?? '';

      if (status == 'completed') {
        return SessionConfirmationResult(
          success: true,
          bothConfirmed: true,
          message: 'Session already completed',
        );
      }

      // Mark patient as confirmed
      await supabase
          .from('bookings')
          .update({'patient_confirmed': true})
          .eq('id', bookingId);

      // Check if both confirmed
      final bothConfirmed = doctorConfirmed;

      if (bothConfirmed) {
        // Both confirmed - complete the session
        await supabase
            .from('bookings')
            .update({
              'status': 'completed',
              'completed_at': TimezoneService.getCurrentMauritaniaTime().toIso8601String(),
            })
            .eq('id', bookingId);

        // Deduct from pending sessions
        await completeSession(patientId);

        // Transfer payment to doctor
        await _transferPaymentToDoctor(
          bookingId: bookingId,
          doctorId: doctorId,
          patientId: patientId,
        );

        // Send session summary emails to both parties
        await _sendSessionCompletionEmails(
          bookingId: bookingId,
          doctorId: doctorId,
          patientId: patientId,
        );

        loggerNoStack.i('✅ Both parties confirmed - session completed');

        return SessionConfirmationResult(
          success: true,
          bothConfirmed: true,
          message: 'Session completed successfully',
        );
      } else {
        loggerNoStack.i('⏳ Waiting for doctor confirmation');

        return SessionConfirmationResult(
          success: true,
          bothConfirmed: false,
          message: 'Waiting for doctor to confirm',
        );
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error confirming session from patient: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      return SessionConfirmationResult(
        success: false,
        bothConfirmed: false,
        message: 'Failed to confirm session',
      );
    }
  }

  /// Transfer payment to doctor when session is completed
  /// Fixed amount: 30 USD per session
  Future<void> _transferPaymentToDoctor({
    required String bookingId,
    required String doctorId,
    required String patientId,
  }) async {
    try {
      loggerNoStack.i(
        '💰 Transferring payment to doctor for session: $bookingId',
      );

      // Get doctor's fee per session (default 30 USD)
      final doctorData = await supabase
          .from('doctors')
          .select('doctor_fee_per_session')
          .eq('doctor_id', doctorId)
          .single();

      final feePerSession = doctorData['doctor_fee_per_session'] ?? 30.0;

      loggerNoStack.i(
        'Doctor fee per session: \$${feePerSession.toStringAsFixed(2)}',
      );

      // Create payment history record for doctor
      await supabase.from('payment_history').insert({
        'doctor_id': doctorId,
        'patient_id': patientId,
        'total_amount': feePerSession,
        'total_actual_amount': feePerSession,
        'income_history': feePerSession,
        'withrowl_history': 0,
        'action_type': 'income',
        'operation_status': 'success',
        'payment_date': TimezoneService.getCurrentMauritaniaTime().toIso8601String(),
        'booking_id': bookingId,
        'payment_gateway': 'session_completion',
        'payment_currency': 'USD',
      });

      loggerNoStack.i(
        '✅ Payment of \$${feePerSession.toStringAsFixed(2)} transferred to doctor $doctorId',
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error transferring payment to doctor: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      // Don't throw - session completion should succeed even if payment record fails
    }
  }

  /// Send session completion emails to both doctor and patient
  Future<void> _sendSessionCompletionEmails({
    required String bookingId,
    required String doctorId,
    required String patientId,
  }) async {
    try {
      loggerNoStack.i('📧 Sending session completion emails for: $bookingId');

      // Get booking details
      final bookingData = await supabase
          .from('bookings')
          .select('booking_date, booking_time, completed_at')
          .eq('id', bookingId)
          .single();

      // Get doctor details
      final doctorData = await supabase
          .from('doctors')
          .select('email, full_name, doctor_fee_per_session')
          .eq('doctor_id', doctorId)
          .single();

      // Get patient details
      final patientData = await supabase
          .from('patients')
          .select('email, name, sessions_available')
          .eq('id', patientId)
          .single();

      final doctorEmail = doctorData['email']?.toString();
      final doctorName = doctorData['full_name']?.toString() ?? 'Doctor';
      final patientEmail = patientData['email']?.toString();
      final patientName = patientData['name']?.toString() ?? 'Patient';
      final sessionsRemaining = patientData['sessions_available']?.toString() ?? '0';
      final sessionEarnings = '\$${(doctorData['doctor_fee_per_session'] ?? 30.0).toStringAsFixed(2)}';

      final sessionDate = bookingData['booking_date']?.toString() ?? '';
      final sessionTime = bookingData['booking_time']?.toString() ?? '';

      if (doctorEmail != null && patientEmail != null) {
        await invoiceService.sendSessionSummaryToBothParties(
          sessionId: bookingId,
          sessionDate: sessionDate,
          sessionTime: sessionTime,
          duration: '30 minutes',
          doctorId: doctorId,
          doctorName: doctorName,
          doctorEmail: doctorEmail,
          patientId: patientId,
          patientName: patientName,
          patientEmail: patientEmail,
          sessionsRemaining: sessionsRemaining,
          sessionEarnings: sessionEarnings,
        );
        loggerNoStack.i('✅ Session summary emails sent to both parties');
      } else {
        loggerNoStack.w('⚠️ Missing email addresses - Doctor: $doctorEmail, Patient: $patientEmail');
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error sending session completion emails: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      // Don't throw - session completion should succeed even if email fails
    }
  }

  /// Cancel a booking and return the session
  Future<bool> cancelBooking({
    required String bookingId,
    required String patientId,
  }) async {
    try {
      loggerNoStack.i('❌ Canceling booking: $bookingId');

      // Update booking status
      await supabase
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);

      // Return session to available
      await returnSessionOnCancellation(patientId);

      loggerNoStack.i('✅ Booking canceled successfully');

      return true;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error canceling booking: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get patient session counts
  Future<PatientSessionCounts?> getSessionCounts(String patientId) async {
    try {
      final patientData = await supabase
          .from('patients')
          .select(
            'sessions_available, sessions_pending, subscribed, subscribed_before',
          )
          .eq('id', patientId)
          .single();

      return PatientSessionCounts(
        available: patientData['sessions_available'] ?? 0,
        pending: patientData['sessions_pending'] ?? 0,
        subscribed: patientData['subscribed'] ?? false,
        subscribedBefore: patientData['subscribed_before'] ?? false,
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error getting session counts: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return null;
    }
  }
}

/// Result of session confirmation operation
class SessionConfirmationResult {
  final bool success;
  final bool bothConfirmed;
  final String message;

  SessionConfirmationResult({
    required this.success,
    required this.bothConfirmed,
    required this.message,
  });
}

/// Patient session counts
class PatientSessionCounts {
  final int available;
  final int pending;
  final bool subscribed;
  final bool subscribedBefore;

  PatientSessionCounts({
    required this.available,
    required this.pending,
    required this.subscribed,
    required this.subscribedBefore,
  });

  bool get hasAvailableSessions => available > 0;
  bool get hasPendingSessions => pending > 0;
}
