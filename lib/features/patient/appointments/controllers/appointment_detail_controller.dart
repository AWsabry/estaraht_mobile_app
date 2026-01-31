import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/review_service.dart';
import 'package:videocalling/shared/services/session_management_service.dart';
import 'package:videocalling/shared/services/agora_token_service.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';
import 'package:videocalling/shared/widgets/rating_dialog.dart';

class UserAppointmentDetailsController extends GetxController {
  String id = Get.arguments['id'];

  DoctorAppointmentDetailsClass? doctorAppointmentDetailsClass;
  Future? getAppointmentDetails;
  RxBool isErrorInLoading = false.obs;
  RxString doctorSpeciality = "".obs;
  RxString doctorId = "".obs;
  RxString userId = "".obs;
  Timer? countdownTimer;
  Duration myDuration = const Duration(hours: 01, seconds: 60);
  RxBool isSecondNagetive = false.obs;

  // Session completion tracking
  RxBool isConfirmingSession = false.obs;
  RxBool patientConfirmed = false.obs;
  RxBool doctorConfirmed = false.obs;
  RxString bookingStatus = ''.obs;

  fetchAppointmentDetails() async {
    try {
      isErrorInLoading.value = false;

      // Fetch appointment details from Supabase
      final response = await supabaseHelper.client
          .from('bookings')
          .select('''
            id,
            patient_id,
            doctor_id,
            booking_date,
            booking_time,
            status,
            price,
            payment_intent_id,
            video_session_id,
            doctor_confirmed,
            patient_confirmed,
            completed_at,
            doctors!fk_bookings_doctor (
              doctor_id,
              full_name,
              email,
              phone_number,
              specialization,
              profile_img_url,
              booking_price,
              bio
            ),
            patients!fk_bookings_patient (
              id,
              name,
              email,
              phone,
              profile_img_url
            )
          ''')
          .eq('id', id)
          .single();

      // Track confirmation status
      bookingStatus.value = response['status']?.toString() ?? '';
      patientConfirmed.value = response['patient_confirmed'] ?? false;
      doctorConfirmed.value = response['doctor_confirmed'] ?? false;

      // Map Supabase response to DoctorAppointmentDetailsClass format
      final doctorData = response['doctors'];
      final patientData = response['patients'];

      // Get doctor bio from Supabase doctors.bio
      final doctorBio = doctorData?['bio']?.toString() ?? '';

      print('📋 Doctor bio from Supabase: $doctorBio');

      // Map Supabase status to numeric codes (same as appointments list)
      String statusStr = response['status']?.toString() ?? 'confirmed';
      int mappedStatus;
      if (statusStr == 'confirmed' || statusStr == 'pending') {
        mappedStatus = 1; // Received
      } else if (statusStr == 'approved') {
        mappedStatus = 2;
      } else if (statusStr == 'in_progress') {
        mappedStatus = 3;
      } else if (statusStr == 'completed') {
        mappedStatus = 4;
      } else if (statusStr == 'cancelled' || statusStr == 'rejected') {
        mappedStatus = 5;
      } else if (statusStr == 'refunded') {
        mappedStatus = 6;
      } else if (statusStr == 'absent') {
        mappedStatus = 0;
      } else {
        mappedStatus = 1; // Default to received for unknown statuses
      }

      final appointmentData = {
        'success': 1,
        'register': 'success',
        'prescription': '',
        'image': [],
        'data': {
          'id': int.tryParse(response['id']?.toString() ?? '0'),
          'doctor_id': int.tryParse(response['doctor_id']?.toString() ?? '0'),
          'user_id': int.tryParse(response['patient_id']?.toString() ?? '0'),
          'doctor_name': doctorData?['full_name']?.toString(),
          'doctor_image': doctorData?['profile_img_url']?.toString(),
          'user_name': patientData?['name']?.toString(),
          'user_image': patientData?['profile_img_url']?.toString(),
          'date': response['booking_date']?.toString(),
          'slot': response['booking_time']?.toString(),
          'status': mappedStatus,
          'phone': patientData?['phone']?.toString(),
          'email': doctorData?['email']?.toString(),
          'description': doctorBio,
          'prescription': '',
          'device_token': [],
          'remain_time': '',
          'is_appointment_time': 0,
        },
      };

      doctorAppointmentDetailsClass = DoctorAppointmentDetailsClass.fromJson(
        appointmentData,
      );
      doctorSpeciality.value = doctorData?['specialization']?.toString() ?? '';
      doctorId.value = response['doctor_id']?.toString() ?? '';
      userId.value = response['patient_id']?.toString() ?? '';
    } catch (e) {
      loggerNoStack.e('Error fetching appointment details', error: e);
      isErrorInLoading.value = true;
    }
  }

  Future<bool> downloadAndSaveImage(String url) async {
    http.Client client = http.Client();
    var req = await client
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: Apis.timeOut));
    if (req.statusCode >= 400) {
      Get.back();
      customDialog(
        onPressed: () {
          Get.back();
        },
        s1: 'error'.tr,
        s2: '${req.reasonPhrase}'.tr,
      );
      return false;
    }
    var bytes = req.bodyBytes;
    try {
      String dir = '/storage/emulated/0/Dcim/${url.split("/").last}';
      File file = File(dir);
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      Get.back();
      customDialog(
        onPressed: () {
          Get.back();
        },
        s1: 'error'.tr,
        s2: e.toString(),
      );
      return false;
    }
  }

  Future<String?> fetchAgoraToken(String channelName) async {
    try {
      // Generate token dynamically using Agora Token Generator
      // App ID and Certificate are loaded from .env file
      final agoraTokenService = AgoraTokenService();

      final token = await agoraTokenService.generateToken(
        channelName: channelName,
        uid: 0,
        tokenExpireSeconds: 86400, // 24 hours
      );

      if (token != null) {
        developer.log('✅ Token generated for channel: $channelName');
        return token;
      } else {
        developer.log('❌ Failed to generate token for channel: $channelName');
        return null;
      }
    } catch (e) {
      developer.log('❌ Error generating token: $e');
      return null;
    }
  }

  /// Check if the current time is within 5 minutes before the appointment
  bool canJoinSession() {
    try {
      final bookingDate = doctorAppointmentDetailsClass?.data?.date;
      final bookingTime = doctorAppointmentDetailsClass?.data?.slot;

      if (bookingDate == null || bookingTime == null) {
        developer.log("❌ Missing booking date or time");
        return false;
      }

      // Parse booking date and time
      final dateParts = bookingDate.split('-');
      final timeParts = bookingTime.split(':');

      final appointmentDateTime = DateTime(
        int.parse(dateParts[0]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[2]), // day
        int.parse(timeParts[0]), // hour
        int.parse(timeParts[1]), // minute
      );

      // Get current time using Mauritania timezone
      final now = TimezoneService.getCurrentMauritaniaTime();

      // Calculate time difference
      final difference = appointmentDateTime.difference(now);

      developer.log(
        "⏰ Appointment: $appointmentDateTime | Now (Mauritania): $now | Difference: ${difference.inMinutes} minutes",
      );

      // Allow joining if within 5 minutes before appointment or after appointment time
      // This gives a 5-minute window before and unlimited time after
      return difference.inMinutes <= 5;
    } catch (e) {
      developer.log("❌ Error checking session join time: $e");
      return false; // Deny access if there's an error
    }
  }

  /// Get time remaining until user can join the session (5 minutes before appointment)
  String getTimeUntilCanJoin() {
    try {
      final bookingDate = doctorAppointmentDetailsClass?.data?.date;
      final bookingTime = doctorAppointmentDetailsClass?.data?.slot;

      if (bookingDate == null || bookingTime == null) {
        return "";
      }

      // Parse booking date and time
      final dateParts = bookingDate.split('-');
      final timeParts = bookingTime.split(':');

      final appointmentDateTime = DateTime(
        int.parse(dateParts[0]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[2]), // day
        int.parse(timeParts[0]), // hour
        int.parse(timeParts[1]), // minute
      );

      // Calculate when user can join (5 minutes before appointment)
      final canJoinTime = appointmentDateTime.subtract(const Duration(minutes: 5));

      // Get current time using Mauritania timezone
      final now = TimezoneService.getCurrentMauritaniaTime();

      // Calculate difference from now to when user can join
      final difference = canJoinTime.difference(now);

      if (difference.isNegative) {
        return 'now'.tr; // Can join now (5-minute window already started or appointment passed)
      }

      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;

      // If 24 hours or more, show in days and hours
      if (days > 0) {
        final dayText = days == 1 ? 'day'.tr : 'days'.tr;
        final hourText = hours == 1 ? 'hour'.tr : 'hours'.tr;

        if (hours > 0) {
          return "$days $dayText ${'and'.tr} $hours $hourText";
        } else {
          return "$days $dayText";
        }
      }
      // If more than 90 minutes (1.5 hours), show in hours and minutes
      else if (difference.inMinutes >= 90) {
        final hourText = hours == 1 ? 'hour'.tr : 'hours'.tr;
        final minuteText = minutes == 1 ? 'minute'.tr : 'minutes'.tr;

        if (minutes > 0) {
          return "$hours $hourText ${'and'.tr} $minutes $minuteText";
        } else {
          return "$hours $hourText";
        }
      }
      // Less than 90 minutes, show only minutes
      else {
        final totalMinutes = difference.inMinutes;
        final minuteText = totalMinutes == 1 ? 'minute'.tr : 'minutes'.tr;
        return "$totalMinutes $minuteText";
      }
    } catch (e) {
      developer.log("❌ Error calculating time until can join: $e");
      return "";
    }
  }

  void initiateVideoCall() async {
    developer.log(
      "============== START VIDEO MEETING (PATIENT SIDE) ==============",
    );
    try {
      // Check if user can join the session (5 minutes before appointment)
      if (!canJoinSession()) {
        final timeRemaining = getTimeUntilCanJoin();
        Get.snackbar(
          'session_available_soon'.tr,
          '${'session_available_in_5_minutes'.tr}\n${'time_remaining'.tr}: $timeRemaining',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        developer.log(
          "❌ Too early to join session. Time remaining: $timeRemaining",
        );
        return;
      }

      // Use unique channel name per booking for privacy
      final String channelName = "booking_$id";
      final String doctorName =
          doctorAppointmentDetailsClass?.data?.doctorName ?? "Doctor";
      developer.log("✅ Joining meeting room: '$channelName' (Booking ID: $id)");

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final String? token = await fetchAgoraToken(channelName);
      Get.back();

      if (token != null) {
        developer.log("Launching video meeting screen...");
        Get.to(
          () => CallScreen(
            channelName: channelName,
            token: token,
            isVideoCall: true,
            opponentName: doctorName,
          ),
        );
      } else {
        Get.snackbar(
          'error'.tr,
          'failed_to_get_video_token'.tr,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      developer.log("Error initiating video meeting: $e");
      Get.back(); // Close loading dialog if open
      Get.snackbar(
        'error'.tr,
        'video_call_failed'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      developer.log(
        "============== END VIDEO MEETING (PATIENT SIDE) ==============",
      );
    }
  }

  /// Confirm session completion from patient side
  Future<void> confirmSessionCompletion() async {
    try {
      isConfirmingSession.value = true;

      loggerNoStack.i('Patient confirming session completion for booking: $id');

      // Use session management service
      final sessionService = SessionManagementService();
      final result = await sessionService.confirmSessionFromPatient(
        bookingId: id,
        patientId: userId.value,
      );

      if (result.success) {
        // Update local state
        patientConfirmed.value = true;

        if (result.bothConfirmed) {
          // Both confirmed - session completed
          bookingStatus.value = 'completed';

          // Refresh appointment details
          await fetchAppointmentDetails();

          // Show rating dialog if not already reviewed
          _showRatingDialogIfNeeded();
        } else {
          // Waiting for doctor confirmation
        }
      } else {}
    } catch (e, stackTrace) {
      loggerNoStack.e('Error confirming session: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    } finally {
      isConfirmingSession.value = false;
    }
  }

  Future<void> _showRatingDialogIfNeeded() async {
    try {
      // Check if already reviewed
      final hasReviewed = await reviewService.hasReviewedBooking(id);
      if (hasReviewed) {
        loggerNoStack.i('Booking already reviewed, skipping rating dialog');
        return;
      }

      // Get doctor name from appointment details
      final doctorName =
          doctorAppointmentDetailsClass?.data?.doctorName ?? 'the doctor';

      // Show rating dialog with slight delay
      await Future.delayed(const Duration(milliseconds: 500));

      showRatingDialog(
        bookingId: id,
        doctorId: doctorId.value,
        patientId: userId.value,
        doctorName: doctorName,
        onSubmitted: () {
          loggerNoStack.i('Review submitted for booking: $id');
        },
      );
    } catch (e) {
      loggerNoStack.e('Error showing rating dialog: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    loggerNoStack.i('Appointment ID: $id');
    getAppointmentDetails = fetchAppointmentDetails();
  }
}
