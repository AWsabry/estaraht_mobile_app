import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';
import 'package:videocalling/shared/services/review_service.dart';
import 'package:videocalling/shared/services/session_management_service.dart';
import 'package:videocalling/shared/services/agora_token_service.dart';
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

  /// Doctor's timezone offset (from doctors table). 0 for legacy doctors.
  int doctorTimezoneOffsetHours = 0;

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
              bio,
              timezone_offset_hours
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
      doctorTimezoneOffsetHours = doctorData?['timezone_offset_hours'] != null
          ? (doctorData!['timezone_offset_hours'] as num).toInt()
          : 0;
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
        s2: 'an_unexpected_error_occurred'.tr,
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
        s2: 'an_unexpected_error_occurred'.tr,
      );
      return false;
    }
  }

  Future<String?> fetchAgoraToken(String channelName, {int uid = 2}) async {
    try {
      // Generate token dynamically using Agora Token Generator
      // Patient uses UID 2 (doctor uses 1) to avoid collision
      final agoraTokenService = AgoraTokenService();

      final token = await agoraTokenService.generateToken(
        channelName: channelName,
        uid: uid,
        tokenExpireSeconds: 86400, // 24 hours
      );

      if (token != null) {
        developer.log('✅ Token generated for channel: $channelName uid=$uid');
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

  bool canJoinSession() {
    final bookingDate = doctorAppointmentDetailsClass?.data?.date;
    final bookingTime = doctorAppointmentDetailsClass?.data?.slot;
    if (bookingDate == null || bookingTime == null) return false;
    return TimezoneService.canJoinVideoSession(
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      doctorTimezoneOffsetHours: doctorTimezoneOffsetHours,
    );
  }

  String getTimeUntilCanJoin() {
    final bookingDate = doctorAppointmentDetailsClass?.data?.date;
    final bookingTime = doctorAppointmentDetailsClass?.data?.slot;
    if (bookingDate == null || bookingTime == null) return '';
    return TimezoneService.getTimeUntilCanJoinVideoSession(
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      doctorTimezoneOffsetHours: doctorTimezoneOffsetHours,
    );
  }

  /// Session must have started before showing confirm-completion card
  bool hasSessionStarted() {
    final bookingDate = doctorAppointmentDetailsClass?.data?.date;
    final bookingTime = doctorAppointmentDetailsClass?.data?.slot;
    if (bookingDate == null || bookingTime == null) return false;
    final timeStr = bookingTime.length >= 5
        ? bookingTime.substring(0, 5)
        : bookingTime;
    return TimezoneService.hasSessionStarted(
      bookingDate: bookingDate,
      bookingTime: timeStr,
      doctorTimezoneOffsetHours: doctorTimezoneOffsetHours,
    );
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

      // Use unique channel name per booking (normalized for consistency)
      final String normalizedId = id.toString().toLowerCase().trim();
      final String channelName = "booking_$normalizedId";
      final String doctorName =
          doctorAppointmentDetailsClass?.data?.doctorName ?? "Doctor";
      developer.log(
        "✅ Joining meeting room: '$channelName' (Booking ID: $id, Patient UID=2)",
      );

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final String? token = await fetchAgoraToken(channelName, uid: 2);
      Get.back();

      if (token != null) {
        developer.log("Launching video meeting screen...");
        final data = doctorAppointmentDetailsClass?.data;
        Get.to(
          () => CallScreen(
            channelName: channelName,
            token: token,
            isVideoCall: true,
            opponentName: doctorName,
            localUid: 2,
            bookingId: id.toString(),
            patientId: userId.value,
            doctorId: doctorId.value,
            bookingDate: data?.date,
            bookingTime: data?.slot,
            doctorTimezoneOffsetHours: doctorTimezoneOffsetHours,
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
