import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:videocalling/core/config/app_imports.dart';

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
            doctors!fk_bookings_doctor (
              doctor_id,
              full_name,
              email,
              phone_number,
              specialization,
              profile_img_url,
              booking_price
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

      // Map Supabase response to DoctorAppointmentDetailsClass format
      final doctorData = response['doctors'];
      final patientData = response['patients'];

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
          'status': response['status'] == 'confirmed'
              ? 1
              : (response['status'] == 'completed' ? 2 : 0),
          'phone': patientData?['phone']?.toString(),
          'email': patientData?['email']?.toString(),
          'description': '',
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

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loggerNoStack.i('Appointment ID: $id');
    getAppointmentDetails = fetchAppointmentDetails();
  }
}
