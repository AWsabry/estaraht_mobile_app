// =======================================================================
// ==================== IMPORTS NÉCESSAIRES ==========================
// =======================================================================
import 'dart:developer' as developer;

import 'package:dio/dio.dart' as d;
import 'package:logger/logger.dart';
// Imports de votre projet
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/more/dmy_photo_viewer_controller.dart';
import 'package:videocalling/shared/services/agora_token_service.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';
import 'package:videocalling/shared/services/session_management_service.dart';

// =======================================================================
// ==================== DÉBUT DE LA CLASSE CORRIGÉE ====================
// =======================================================================
class DAppointmentDetailsController extends GetxController {
  // ==========================
  //      VARIABLES
  // ==========================

  // Variables de base
  late String id;
  RxBool isLoaded = false.obs;
  RxBool isErrorInLoading = false.obs;
  RxInt apStatus = 0.obs;
  DoctorAppointmentDetailsClass doctorAppointmentDetailsClass =
      DoctorAppointmentDetailsClass();
  RxBool areChangesMade = false.obs;

  // Variables pour l'upload de fichiers
  RxBool isTextFieldEmpty = false.obs;
  File? fImage;
  RxString userId = "".obs;
  RxList<PrescriptionImage> imageList = <PrescriptionImage>[].obs;
  final formKey = GlobalKey<FormState>();
  var jr;
  UploadImageModel uploadImageModel = UploadImageModel();
  List<Medicine> localData = [];
  TextEditingController textEditingController = TextEditingController();

  // Session completion tracking
  RxBool isConfirmingSession = false.obs;
  RxBool patientConfirmed = false.obs;
  RxBool doctorConfirmed = false.obs;
  RxString bookingStatus = ''.obs;
  RxString patientId = ''.obs;
  RxString doctorId = ''.obs;

  // ==========================
  // MÉTHODE D'INITIALISATION
  // ==========================

  @override
  void onInit() {
    super.onInit();
    // On récupère l'ID une seule fois au début
    id = Get.arguments['id'];
    fetchAppointmentDetails();
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
        loggerNoStack.i('✅ Token generated for channel: $channelName');
        return token;
      } else {
        loggerNoStack.e('❌ Failed to generate token for channel: $channelName');
        return null;
      }
    } catch (e) {
      loggerNoStack.e('❌ Error generating token: $e');
      return null;
    }
  }

  /// Check if the current time is within 5 minutes before the appointment
  bool canJoinSession() {
    try {
      final bookingDate = doctorAppointmentDetailsClass.data?.date;
      final bookingTime = doctorAppointmentDetailsClass.data?.slot;

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
      final bookingDate = doctorAppointmentDetailsClass.data?.date;
      final bookingTime = doctorAppointmentDetailsClass.data?.slot;

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
      final canJoinTime = appointmentDateTime.subtract(
        const Duration(minutes: 5),
      );

      // Get current time using Mauritania timezone
      final now = TimezoneService.getCurrentMauritaniaTime();

      // Calculate difference from now to when user can join
      final difference = canJoinTime.difference(now);

      if (difference.isNegative) {
        return 'now'
            .tr; // Can join now (5-minute window already started or appointment passed)
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
      "============== START VIDEO MEETING (DOCTOR SIDE) ==============",
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
      final String patientName =
          doctorAppointmentDetailsClass.data?.userName ?? "Patient";
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
            opponentName: patientName,
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
      Get.back();
      Get.snackbar(
        'error'.tr,
        'video_call_failed'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      developer.log(
        "============== END VIDEO MEETING (DOCTOR SIDE) ==============",
      );
    }
  }

  fetchAppointmentDetails() async {
    try {
      isLoaded.value = false;
      isErrorInLoading.value = false;

      final response = await supabaseHelper.client
          .from('bookings')
          .select(
            ''' id, patient_id, doctor_id, booking_date, booking_time, status, price, doctor_confirmed, patient_confirmed, completed_at, doctors!fk_bookings_doctor (doctor_id, full_name, email, phone_number, specialization, profile_img_url), patients!fk_bookings_patient (id, name, email, phone, profile_img_url) ''',
          )
          .eq('id', id)
          .single();

      final doctorData = response['doctors'];
      final patientData = response['patients'];

      // Track confirmation status
      bookingStatus.value = response['status']?.toString() ?? '';
      patientConfirmed.value = response['patient_confirmed'] ?? false;
      doctorConfirmed.value = response['doctor_confirmed'] ?? false;
      patientId.value = response['patient_id']?.toString() ?? '';
      doctorId.value = response['doctor_id']?.toString() ?? '';

      int statusValue = 0;
      switch (response['status']?.toString().toLowerCase()) {
        case 'confirmed':
          statusValue = 1;
          break;
        case 'pending':
          statusValue = 2;
          break;
        case 'accepted':
          statusValue = 3;
          break;
        case 'completed':
          statusValue = 4;
          break;
        case 'cancelled':
          statusValue = 5;
          break;
        case 'absent':
          statusValue = 6;
          break;
        case 'rejected':
          statusValue = 7;
          break;
        default:
          statusValue = 0;
      }

      final appointmentData = {
        'success': 1,
        'register': 'success',
        'prescription': '',
        'image': [],
        'data': {
          'id': response['id']?.toString(),
          'doctor_id': response['doctor_id']?.toString(),
          'user_id': response['patient_id']?.toString(),
          'doctor_name': doctorData?['full_name'],
          'doctor_image': doctorData?['profile_img_url'],
          'user_name': patientData?['name'],
          'user_image': patientData?['profile_img_url'],
          'date': response['booking_date'],
          'slot': response['booking_time'],
          'status': statusValue,
          'phone': patientData?['phone'],
          'email': patientData?['email'],
          'description': '',
          'prescription': '',
          'device_token': [],
        },
      };

      doctorAppointmentDetailsClass = DoctorAppointmentDetailsClass.fromJson(
        appointmentData,
      );
      apStatus.value = doctorAppointmentDetailsClass.data?.status ?? 0;

      imageList.clear();
      if (doctorAppointmentDetailsClass.image != null) {
        imageList.addAll(doctorAppointmentDetailsClass.image!);
      }

      userId.value = response['patient_id']?.toString() ?? '';
      isLoaded.value = true;
    } catch (e) {
      loggerNoStack.e('Error fetching appointment details: $e');
      isErrorInLoading.value = true;
      isLoaded.value =
          true; // Mettre à true pour sortir de l'état de chargement et afficher l'erreur
    }
  }

  Future<bool> willPopScope() async {
    Get.back(result: areChangesMade.value);
    return false;
  }

  Widget button({required BuildContext context}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Obx(() {
        if (apStatus.value == 1 || apStatus.value == 2) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                onTap: () => changeStatus("3"),
                btnText: 'btn_accept'.tr /* ...styles */,
              ),
              const SizedBox(height: 10),
              CustomButton(
                onTap: () {
                  changeStatus("5");
                },
                btnText: 'btn_cancel'.tr /* ...styles */,
              ),
            ],
          );
        } else if (apStatus.value == 3) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                onTap: () => changeStatus("0"),
                btnText: 'btn_absent'.tr /* ...styles */,
              ),
            ],
          );
        }
        return const SizedBox.shrink(); // Retourne un widget vide si aucune condition n'est remplie
      }),
    );
  }

  changeStatus(status) async {
    customDialog1(
      s1: 'reporting_dialog1'.tr,
      s2: 'please_wait_while_processing'.tr,
    );

    try {
      // Map status numbers to Supabase status strings
      String statusString;
      switch (status) {
        case "0":
          statusString = "absent";
          break;
        case "1":
          statusString = "confirmed";
          break;
        case "2":
          statusString = "pending";
          break;
        case "3":
          statusString = "accepted";
          break;
        case "4":
          statusString = "completed";
          break;
        case "5":
          statusString = "cancelled";
          break;
        case "6":
          statusString = "absent";
          break;
        case "7":
          statusString = "rejected";
          break;
        default:
          statusString = "pending";
      }

      // Update the booking status in Supabase
      await supabaseHelper.client
          .from('bookings')
          .update({'status': statusString})
          .eq('id', id);

      // Get patient ID from booking
      final bookingData = await supabaseHelper.client
          .from('bookings')
          .select('patient_id')
          .eq('id', id)
          .single();
      final patientId = bookingData['patient_id']?.toString() ?? '';

      // Update patient session counts based on status change
      await _updatePatientSessions(status, patientId);

      Get.back();
      fetchAppointmentDetails();
      areChangesMade.value = true;
    } catch (e) {
      Get.back();
      loggerNoStack.e('Error changing status: $e');
      messageDialog('error'.tr, 'failed_to_update_appointment'.tr);
    }
  }

  /// Update patient session counts based on appointment status change
  Future<void> _updatePatientSessions(String status, String patientId) async {
    try {
      // Get current patient session counts
      final patientData = await supabaseHelper.client
          .from('patients')
          .select('sessions_available, sessions_pending')
          .eq('id', patientId)
          .single();
      Logger().d(patientData);
      Logger().e(status);
      Logger().d("a7a");

      final currentAvailable = patientData['sessions_available'] ?? 0;
      final currentPending = patientData['sessions_pending'] ?? 0;

      int newAvailable = currentAvailable;
      int newPending = currentPending;

      switch (status) {
        case "3": // Accepted - deduct from pending (session is now active)
          newPending = (currentPending - 1).clamp(0, 999);
          loggerNoStack.i(
            'Session accepted: pending $currentPending -> $newPending',
          );
          break;

        case "4": // Completed - deduct from pending (session was used)
          newPending = (currentPending - 1).clamp(0, 999);
          loggerNoStack.i(
            'Session completed: pending $currentPending -> $newPending',
          );
          break;

        case "5": // Cancelled - refund session back to available
        case "7": // Rejected - refund session back to available
          newPending = (currentPending - 1).clamp(0, 999);
          newAvailable = currentAvailable + 1;
          loggerNoStack.i(
            'Session cancelled/rejected: available $currentAvailable -> $newAvailable, '
            'pending $currentPending -> $newPending',
          );
          break;

        case "0": // Absent - refund session back to available
        case "6": // Absent - refund session back to available
          newPending = (currentPending - 1).clamp(0, 999);
          newAvailable = currentAvailable + 1;
          loggerNoStack.i(
            'Patient absent: available $currentAvailable -> $newAvailable, '
            'pending $currentPending -> $newPending',
          );
          break;
      }

      // Update patient session counts if changed
      if (newAvailable != currentAvailable || newPending != currentPending) {
        await supabaseHelper.client
            .from('patients')
            .update({
              'sessions_available': newAvailable,
              'sessions_pending': newPending,
            })
            .eq('id', patientId);

        loggerNoStack.i('Patient session counts updated successfully');
      }
    } catch (e) {
      loggerNoStack.e('Error updating patient sessions: $e');
    }
  }

  messageDialog(String s1, String s2) {
    customDialog(
      s1: s1,
      s2: s2,
      onPressed: () {
        if (s1 == 'error'.tr) {
          Get.back();
        } else {
          fetchAppointmentDetails();
        }
      },
    );
  }

  showUploadPrescriptionSheetNew() {
    Get.bottomSheet(
      ignoreSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      backgroundColor: AppColors.WHITE,
      Form(
        key: formKey,
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      width: Get.width,
                      alignment: Alignment.center,
                      child: AppTextWidgets.regularText(
                        text: 'upload_report'.tr,
                        color: AppColors.BLACK,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        fImage == null
                            ? DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(12),
                                padding: const EdgeInsets.all(6),
                                dashPattern: const [5, 3, 5, 3],
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      final pickedFile = await picker.pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 25,
                                      );

                                      if (pickedFile != null) {
                                        setState(() {
                                          fImage = File(pickedFile.path);
                                        });
                                      }
                                    },
                                    child: SizedBox(
                                      height: 144,
                                      width: double.maxFinite,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              size: 50,
                                              color: AppColors.AMBER,
                                            ),
                                            Text(
                                              'choose_gallery'.tr,
                                              style: CustomTextStyle(
                                                fontSize: 12,
                                                fontFamily:
                                                    AppFontStyleTextStrings
                                                        .regular,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  fImage!,
                                  height: 166,
                                  fit: BoxFit.cover,
                                  width: double.maxFinite,
                                ),
                              ),
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.AMBER_NORMAL,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            final pickedFile = await picker
                                                .pickImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 25,
                                                );

                                            if (pickedFile != null) {
                                              setState(() {
                                                fImage = File(pickedFile.path);
                                              });
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            color: AppColors.WHITE,
                                          ),
                                          iconSize: 20,
                                          constraints: const BoxConstraints(
                                            maxHeight: 40,
                                            maxWidth: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  fImage == null
                                      ? const SizedBox()
                                      : Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.AMBER_NORMAL,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  final pickedFile =
                                                      await picker.pickImage(
                                                        source:
                                                            ImageSource.gallery,
                                                        imageQuality: 25,
                                                      );

                                                  if (pickedFile != null) {
                                                    setState(() {
                                                      fImage = File(
                                                        pickedFile.path,
                                                      );
                                                    });
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.photo,
                                                  color: AppColors.WHITE,
                                                ),
                                                iconSize: 20,
                                                constraints:
                                                    const BoxConstraints(
                                                      maxHeight: 40,
                                                      maxWidth: 40,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  fImage == null
                                      ? const SizedBox()
                                      : Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.AMBER_NORMAL,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  await Get.toNamed(
                                                    Routes.dMyPhotoViewerScreen,
                                                    arguments: {
                                                      'imagePath': fImage!.path,
                                                      'isFromFile': true,
                                                    },
                                                  );
                                                  Get.delete<
                                                    DMyPhotoViewController
                                                  >();
                                                },
                                                icon: const Icon(
                                                  Icons.open_in_full,
                                                  color: AppColors.WHITE,
                                                ),
                                                iconSize: 20,
                                                constraints:
                                                    const BoxConstraints(
                                                      maxHeight: 40,
                                                      maxWidth: 40,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: textEditingController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          isTextFieldEmpty.value = true;
                          setState(() {});
                        }
                      },
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).colorScheme.surface,
                        filled: true,
                        labelText: 'enter_report_hint'.tr,
                        errorText: isTextFieldEmpty.value
                            ? 'enter_report_error'.tr
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          if (val.isNotEmpty) {
                            isTextFieldEmpty.value = false;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CustomButtonExpanded(
                            onTap: () {
                              Get.focusScope!.unfocus();
                              Get.back();
                            },
                            btnText: 'btn_cancel'.tr,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButtonExpanded(
                            onTap: () {
                              Get.focusScope!.unfocus();
                              if (fImage == null) {
                                Fluttertoast.showToast(
                                  msg: 'please_select_image'.tr,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: AppColors.WHITE,
                                  textColor: AppColors.BLACK,
                                  fontSize: 16.0,
                                );
                              } else if (textEditingController.text.isEmpty) {
                                isTextFieldEmpty.value = true;
                                Fluttertoast.showToast(
                                  msg: 'enter_report_error'.tr,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: AppColors.WHITE,
                                  textColor: AppColors.BLACK,
                                  fontSize: 16.0,
                                );
                              } else {
                                uploadPrescriptionImage();
                              }
                            },
                            btnText: 'btn_upload'.tr,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  deleteMedicine({required List<Map<String, dynamic>> jsonData}) async {
    Map<String, dynamic> r = {"medicine": jsonData};
    customDialog1(
      s1: 'reporting_dialog1'.tr,
      s2: 'please_wait_while_processing'.tr,
    );
    var response = await post(
      Uri.parse("${Apis.ServerAddress}/api/add_medicine_to_app"),
      body: {"appointment_id": id.toString(), "medicine_id": jsonEncode(r)},
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['status'].toString() == "0") {
        Get.back();
        messageDialog('error'.tr, jsonDecode(response.body)['msg']);
      } else {
        uploadImageModel = UploadImageModel.fromJson(jsonDecode(response.body));
        Get.back();
        fetchAppointmentDetails();
      }
    } else {
      Get.back();
      messageDialog('error'.tr, jr['msg']);
    }
    Client().close();
  }

  uploadPrescriptionImage() async {
    if (fImage == null) return;
    Get.back();
    customDialog1(
      s1: 'reporting_dialog1'.tr,
      s2: 'please_wait_while_processing'.tr,
    );

    d.FormData data = d.FormData.fromMap({
      'image': await d.MultipartFile.fromFile(
        fImage!.path,
        filename: fImage?.path.split("/").last,
      ),
      "name": textEditingController.text,
      "appointment_id": id,
    });

    d.Dio dio = d.Dio();
    dio.post("${Apis.ServerAddress}/api/upload_image", data: data).then((
      response,
    ) async {
      if (response.statusCode == 200) {
        jr = await response.data;
        uploadImageModel = UploadImageModel.fromJson(jr!);
        Get.back();
        fetchAppointmentDetails();
      } else {
        Get.back();
        messageDialog('error'.tr, jr['msg']);
      }
      d.Dio().close();
    });
  }

  /// Confirm session completion from doctor side
  Future<void> confirmSessionCompletion() async {
    try {
      isConfirmingSession.value = true;

      loggerNoStack.i('Doctor confirming session completion for booking: $id');

      // Use session management service
      final sessionService = SessionManagementService();
      final result = await sessionService.confirmSessionFromDoctor(
        bookingId: id,
        patientId: patientId.value,
        doctorId: doctorId.value,
      );

      if (result.success) {
        // Update local state
        doctorConfirmed.value = true;

        if (result.bothConfirmed) {
          // Both confirmed - session completed
          bookingStatus.value = 'completed';

          // Refresh appointment details
          await fetchAppointmentDetails();
        } else {
          // Waiting for patient confirmation
        }
      } else {}
    } catch (e, stackTrace) {
      loggerNoStack.e('Error confirming session: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      ('error'.tr, 'failed_to_confirm_session'.tr, Colors.red);
    } finally {
      isConfirmingSession.value = false;
    }
  }
}
