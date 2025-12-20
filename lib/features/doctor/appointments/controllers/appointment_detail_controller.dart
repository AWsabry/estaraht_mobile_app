// =======================================================================
// ==================== IMPORTS NÉCESSAIRES ==========================
// =======================================================================
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'dart:developer' as developer;

// Imports de votre projet
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:dio/dio.dart' as d;
import 'package:videocalling/features/doctor/more/dmy_photo_viewer_controller.dart';

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
    final response1 = await supabaseHelper.client.from('agora_tokens').select();

    loggerNoStack.i('Fetched all tokens: $response1');
    final response = await supabaseHelper.client
        .from('agora_tokens')
        .select('token')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    loggerNoStack.i('Fetched Agora token response: $response');
    return response?['token'] as String?;
  }

  void initiateVideoCall() async {
    developer.log(
      "============== START VIDEO MEETING (DOCTOR SIDE) ==============",
    );
    try {
      // Force channel name to "Estarht" for meeting room
      const String channelName = "Estarht";
      final String patientName =
          doctorAppointmentDetailsClass.data?.userName ?? "Patient";
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
            ''' id, patient_id, doctor_id, booking_date, booking_time, status, price, doctors!fk_bookings_doctor (doctor_id, full_name, email, phone_number, specialization, profile_img_url), patients!fk_bookings_patient (id, name, email, phone, profile_img_url) ''',
          )
          .eq('id', id)
          .single();

      final doctorData = response['doctors'];
      final patientData = response['patients'];

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
                onTap: () => customDialog2(
                  s1: 'confirmation'.tr,
                  s2: 'complete_appointment_subtitle'.tr,
                  onPressedYes: () {
                    Get.back();
                    changeStatus("4");
                  },
                  onPressedNo: () => Get.back(),
                ),
                btnText: 'btn_complete'.tr /* ...styles */,
              ),
              const SizedBox(height: 10),
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

      Get.back();
      fetchAppointmentDetails();
      areChangesMade.value = true;
    } catch (e) {
      Get.back();
      loggerNoStack.e('Error changing status: $e');
      messageDialog('error'.tr, 'Failed to update appointment status');
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
                                              style: TextStyle(
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
}
