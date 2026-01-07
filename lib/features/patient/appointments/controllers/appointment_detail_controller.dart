import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/review_service.dart';
import 'package:videocalling/shared/services/session_management_service.dart';
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
    // On garde le token pour "Estarht"
    const tempTokenForEstarhtChannel =
        "007eJxTYJBg+bXy+vM/D+qNdO8dzatft/NEQivDru/bg+rNFNsePv2qwGBommaeZJZkkJhkYmFilGJgYWZpYphiYJJmnpqSaJRm+NL7U0ZDICOD+OubLIwMEAjiszO4FpckFmWUMDAAAMqIJJ4=";
    return tempTokenForEstarhtChannel;
  }

  void initiateVideoCall() async {
    developer.log(
      "============== START VIDEO MEETING (PATIENT SIDE) ==============",
    );
    try {
      // Force channel name to "Estarht" for meeting room
      const String channelName = "Estarht";
      final String doctorName =
          doctorAppointmentDetailsClass?.data?.doctorName ?? "Doctor";
      developer.log("Joining meeting room: '$channelName'");

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
