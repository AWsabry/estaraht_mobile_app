import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/appointments/pages/add_medicine_page.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';
import 'package:videocalling/features/doctor/more/search_medicine_controller.dart';
import 'package:videocalling/features/doctor/more/search_medicine_model.dart';
import 'package:videocalling/shared/widgets/file_picker_widget.dart';

class DoctorAppointmentDetails extends GetView<DAppointmentDetailsController> {
  final DAppointmentDetailsController detailsController = Get.put(
    DAppointmentDetailsController(),
  );

  DoctorAppointmentDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return WillPopScope(
      onWillPop: detailsController.willPopScope,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'appointment'.tr,
            style: CustomTextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFontStyleTextStrings.medium,
            ),
          ),
          centerTitle: false,
          leading: IconButton(
            padding: const EdgeInsets.only(left: 8, right: 8),
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () =>
                Get.back(result: detailsController.areChangesMade.value),
          ),
          titleSpacing: 0,
        ),
        body: Obx(
          () => detailsController.isErrorInLoading.value
              ? _buildErrorState()
              : detailsController.isLoaded.value
              ? _buildAppointmentDetails(context, isArabic)
              : _buildLoadingState(),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'unable_to_load_data'.tr,
              textAlign: TextAlign.center,
              style: CustomTextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentDetails(BuildContext context, bool isArabic) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildPatientInfoCard(context, isArabic),
          const SizedBox(height: 16),
          _buildContactInfoCard(context, isArabic),
          const SizedBox(height: 16),
          _buildSessionCompletionCard(context),
          const SizedBox(height: 16),
          _buildSessionFilesCard(context),
          const SizedBox(height: 16),
          /* if (detailsController.apStatus.value == 4) ...[
            _buildPrescriptionCard(context, isArabic),
            const SizedBox(height: 16),
            _buildReportsCard(context, isArabic),
          ],*/
          const SizedBox(height: 24),

          // Action buttons now integrated directly in the scrollview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: detailsController.button(context: context),
          ),
          const SizedBox(height: 24), // Add space after buttons
        ],
      ),
    );
  }

  Widget _buildSessionFilesCard(BuildContext context) {
    return Obx(() {
      final status = detailsController.bookingStatus.value;
      final isCompleted = status == 'completed';
      final isAccepted = status == 'accepted' || status == 'confirmed';

      // Show files section for both accepted and completed sessions
      if (!isAccepted && !isCompleted) {
        return const SizedBox.shrink();
      }

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SessionFilesWidget(
          bookingId: detailsController.id,
          currentUserId: detailsController.doctorId.value,
          currentUserType: 'doctor',
          canUpload: true,
        ),
      );
    });
  }

  Widget _buildPatientInfoCard(BuildContext context, bool isArabic) {
    final dateStr =
        detailsController.doctorAppointmentDetailsClass.data?.date ?? '';
    final slot =
        detailsController.doctorAppointmentDetailsClass.data?.slot ?? '';
    final timeStr = slot.length >= 5 ? slot.substring(0, 5) : slot;
    final dateTimeFormatted = (dateStr.isNotEmpty && timeStr.isNotEmpty)
        ? TimezoneService.formatAppointmentForDoctor(
            dateStr: dateStr,
            timeStr: timeStr,
            isArabic: isArabic,
            doctorTimezoneOffsetHours:
                detailsController.doctorTimezoneOffsetHours,
          )
        : null;
    final parts = dateTimeFormatted?.split(' - ') ?? [];
    final dateFormatted = parts.isNotEmpty
        ? parts.first
        : (dateStr.length >= 10
              ? '${dateStr.substring(8, 10)}-${dateStr.substring(5, 7)}-${dateStr.substring(0, 4)}'
              : dateStr);
    final timeFormatted = parts.length > 1
        ? parts.last
        : (timeStr.isNotEmpty ? timeStr : '');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPatientAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detailsController
                            .doctorAppointmentDetailsClass
                            .data!
                            .userName!,
                        style: CustomTextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusChip(context, isArabic),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF3366FF)),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'appointment_date'.tr,
                          style: CustomTextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormatted,
                          style: CustomTextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, color: Color(0xFF3366FF)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'session_time'.tr,
                        style: CustomTextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeFormatted,
                        style: const CustomTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl:
            detailsController.doctorAppointmentDetailsClass.data?.userImage ??
            "",
        height: 80,
        width: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
        errorWidget: (context, url, err) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isArabic) {
    // Use raw DB status (bookingStatus) to match consultations list and database
    final status = detailsController.bookingStatus.value.toLowerCase();
    String statusText;
    Color statusColor;
    switch (status) {
      case 'pending':
        statusText = 'appointment_status_2'.tr; // Received
        statusColor = Colors.orange;
        break;
      case 'confirmed':
        statusText = 'appointment_status_3'.tr; // Approved
        statusColor = Colors.green;
        break;
      case 'accepted':
        statusText = 'appointment_status_4'.tr; // In Process
        statusColor = Colors.orangeAccent;
        break;
      case 'completed':
        statusText = 'appointment_status_5'.tr; // Completed
        statusColor = Colors.purple;
        break;
      case 'rejected':
        statusText = 'appointment_status_6'.tr; // Rejected
        statusColor = Colors.red;
        break;
      case 'cancelled':
        statusText = 'appointment_status_7'.tr; // Cancelled
        statusColor = Colors.grey;
        break;
      case 'absent':
        statusText = 'appointment_status_1'.tr; // Absent
        statusColor = Colors.brown;
        break;
      default:
        statusText = status.isNotEmpty ? status : 'appointment_status_2'.tr;
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: statusColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: CustomTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context, bool isArabic) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'contact_info'.tr,
              style: const CustomTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),
            _buildContactItem(
              context: context,
              icon: Icons.email,
              title: 'email_address'.tr,
              value:
                  detailsController.doctorAppointmentDetailsClass.data!.email!,
              onTap: () {
                launch(
                  Uri(
                    scheme: 'mailto',
                    path: detailsController
                        .doctorAppointmentDetailsClass
                        .data!
                        .email,
                  ).toString(),
                );
              },
              isArabic: isArabic,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'description'.tr,
                  style: CustomTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detailsController
                      .doctorAppointmentDetailsClass
                      .data!
                      .description!,
                  style: CustomTextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (![
              4, // completed
              5, // cancelled
              6, // absent
              7, // rejected
            ].contains(
              detailsController.doctorAppointmentDetailsClass.data!.status,
            )) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.video_call,
                      label: 'video_call'.tr,
                      onTap: () {
                        detailsController.initiateVideoCall();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.chat,
                      label: 'chat'.tr,
                      onTap: () async {
                        // Get patient ID from appointment data
                        final patientId =
                            detailsController
                                .doctorAppointmentDetailsClass
                                .data
                                ?.userId
                                ?.toString() ??
                            detailsController.userId.value;

                        if (patientId.isEmpty) {
                          Get.snackbar(
                            'error'.tr,
                            'patient_id_not_found'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        await Get.toNamed(
                          Routes.chatScreen,
                          arguments: {
                            'userName':
                                detailsController
                                    .doctorAppointmentDetailsClass
                                    .data
                                    ?.userName ??
                                '',
                            'uid': '117$patientId',
                            'isUser': true,
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Function onTap,
    required bool isArabic,
  }) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3366FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF3366FF), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CustomTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: CustomTextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => onTap(),
          icon: Icon(
            icon == Icons.phone ? Icons.call : Icons.email_outlined,
            color: const Color(0xFF3366FF),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Function onTap,
  }) {
    return ElevatedButton(
      onPressed: () => onTap(),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3366FF),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const CustomTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, bool isArabic) {
    final hasPrescriptions =
        detailsController.doctorAppointmentDetailsClass.prescription != null &&
        (detailsController
                .doctorAppointmentDetailsClass
                .prescription
                ?.medicine
                ?.isNotEmpty ??
            false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3366FF), Color(0xFF00CCFF)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppImages.medicineIcon,
                      height: 20,
                      width: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'prescription'.tr,
                        style: const CustomTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasPrescriptions
                            ? 'd_add_prescription_msg'.tr
                            : 'd_no_prescription_msg'.tr,
                        style: CustomTextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF3366FF),
                  ),
                  onPressed: () async {
                    List<Map<String, dynamic>>? jsonData = detailsController
                        .doctorAppointmentDetailsClass
                        .prescription
                        ?.medicine
                        ?.map(
                          (e) => {
                            "time":
                                e.time?.map((e) {
                                  var h = e.tTime?.split(":");
                                  var m = h?.last.split(" ").first;
                                  return {
                                    "t_time":
                                        "${h?.first.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
                                  };
                                }).toList() ??
                                [],
                            "medicine_name": e.medicine_name.toString(),
                            "repeat_days": e.repeatDays.toString(),
                            "dosage": e.dosage.toString(),
                            "type": e.type.toString(),
                          },
                        )
                        .toList();

                    await Get.toNamed(
                      Routes.dSearchMedicineScreen,
                      arguments: {
                        'medicineMap': jsonData == null
                            ? null
                            : jsonEncode(
                                jsonData.isEmpty ? "No Data" : jsonData,
                              ),
                        'id': int.parse(detailsController.id),
                      },
                    )?.then((value) {
                      if ((value != "false")) {
                        detailsController.fetchAppointmentDetails();
                      }
                      Get.delete<SearchMedicineController>();
                    });
                  },
                ),
              ],
            ),
            if (hasPrescriptions) ...[
              const SizedBox(height: 16),
              _buildPrescriptionList(context, isArabic),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionList(BuildContext context, bool isArabic) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: detailsController
          .doctorAppointmentDetailsClass
          .prescription!
          .medicine!
          .length,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.grey[300], thickness: 1, height: 32),
      itemBuilder: (context, i) {
        final medicine = detailsController
            .doctorAppointmentDetailsClass
            .prescription!
            .medicine![i];

        return Column(
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    medicine.medicine_name ?? "",
                    style: const CustomTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3366FF).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF3366FF),
                          size: 16,
                        ),
                      ),
                      onPressed: () async {
                        List<TimeOfDay> timeListLocal = medicine.time!
                            .map(
                              (e) => TimeOfDay(
                                hour: int.parse(
                                  e.tTime?.split(":").first ?? "00",
                                ),
                                minute: int.parse(
                                  e.tTime?.split(":").last.split(" ").first ??
                                      "00",
                                ),
                              ),
                            )
                            .toList();
                        int repeatDaysLocal = medicine.repeatDays!;

                        MedicineData medicineDataLocal = MedicineData(
                          name: medicine.medicine_name,
                          id: medicine.medicineId,
                          dosage: medicine.dosage,
                          medicineType: medicine.type.toString(),
                        );

                        detailsController.localData = detailsController
                            .doctorAppointmentDetailsClass
                            .prescription!
                            .medicine!;
                        detailsController.localData.removeAt(i);

                        List<Map<String, dynamic>>? jsonData = detailsController
                            .localData
                            .map(
                              (e) => {
                                "time":
                                    e.time?.map((e) {
                                      var h = e.tTime?.split(":");
                                      var m = h?.last.split(" ").first;
                                      return {
                                        "t_time":
                                            "${h?.first.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
                                      };
                                    }).toList() ??
                                    [],
                                "medicine_name": e.medicine_name.toString(),
                                "repeat_days": e.repeatDays.toString(),
                                "dosage": e.dosage.toString(),
                                "type": e.type.toString(),
                              },
                            )
                            .toList();

                        Get.to(
                          MedicinseScreen(
                            updateValue2: true,
                            updateRepeatDays: repeatDaysLocal,
                            timeList: [timeListLocal],
                            ll: [medicineDataLocal],
                            id: int.parse(detailsController.id),
                            oldData: jsonEncode(
                              jsonData.isEmpty ? "No Data" : jsonData,
                            ),
                          ),
                        )!.then((value) {
                          Get.delete<AddMedicineToAppointmentController>();
                          if (value != "false") {
                            detailsController.fetchAppointmentDetails();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              'confirmation'.tr,
                              style: const CustomTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              'delete_medicine'.tr,
                              style: CustomTextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text(
                                  'cancel'.tr,
                                  style: CustomTextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  detailsController.localData =
                                      detailsController
                                          .doctorAppointmentDetailsClass
                                          .prescription!
                                          .medicine!;
                                  detailsController.localData.removeAt(i);

                                  List<Map<String, dynamic>>?
                                  jsonData = detailsController.localData
                                      .map(
                                        (e) => {
                                          "time":
                                              e.time?.map((e) {
                                                var h = e.tTime?.split(":");
                                                var m = h?.last
                                                    .split(" ")
                                                    .first;
                                                return {
                                                  "t_time":
                                                      "${h?.first.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
                                                };
                                              }).toList() ??
                                              [],
                                          "medicine_name": e.medicine_name
                                              .toString(),
                                          "repeat_days": e.repeatDays
                                              .toString(),
                                          "dosage": e.dosage.toString(),
                                          "type": e.type.toString(),
                                        },
                                      )
                                      .toList();

                                  Get.back();
                                  detailsController.deleteMedicine(
                                    jsonData: jsonData,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3366FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'delete'.tr,
                                  style: const CustomTextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              title: 'medicine_param_1'.tr,
              value:
                  "${medicine.type.toString()[0].toUpperCase()}${medicine.type.toString().substring(1)}",
              isArabic: isArabic,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              title: 'medicine_param_2'.tr,
              value: medicine.dosage ?? "",
              isArabic: isArabic,
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  'medicine_param_3'.tr,
                  style: CustomTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int j = 0; j < medicine.time!.length; j++)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF3366FF)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          medicine.time![j].tTime ?? "",
                          style: const CustomTextStyle(
                            fontSize: 12,
                            color: Color(0xFF3366FF),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${'medicine_param_4'.tr}: ${medicine.repeatDays} ${'days'.tr}',
              style: const CustomTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required bool isArabic,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Text(
          title,
          style: CustomTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            height: 1.3,
          ),
        ),
        Text(
          value,
          style: CustomTextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildReportsCard(BuildContext context, bool isArabic) {
    final hasReports = detailsController.imageList.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.appointmentDetailsReportBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppImages.reportIcon,
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'reports'.tr,
                        style: const CustomTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasReports
                            ? 'd_add_report_msg'.tr
                            : 'd_no_report_msg'.tr,
                        style: CustomTextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF3366FF),
                  ),
                  onPressed: () {
                    detailsController.textEditingController.clear();
                    detailsController.fImage = null;
                    detailsController.showUploadPrescriptionSheetNew();
                  },
                ),
              ],
            ),
            if (hasReports) ...[
              const SizedBox(height: 16),
              _buildReportGrid(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportGrid(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: detailsController.imageList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            await Get.toNamed(
              Routes.photoViewerScreen,
              arguments: {
                'url':
                    ("${Apis.reportImagePath}${detailsController.imageList[index].image}"),
                'id': detailsController.imageList[index].id.toString(),
                'isDeleteShown': true,
                'reportName': detailsController.imageList[index].name,
              },
            )?.then((value) {
              Get.delete<MyPhotoViewerController>();
              if (value ?? false) {
                detailsController.fetchAppointmentDetails();
              }
            });
          },
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl:
                        ("${Apis.reportImagePath}${detailsController.imageList[index].image}"),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detailsController.imageList[index].name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: CustomTextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Session completion confirmation card for doctor
  Widget _buildSessionCompletionCard(BuildContext context) {
    return Obx(() {
      // Only show for accepted/confirmed bookings that haven't been completed yet
      final status = detailsController.bookingStatus.value;
      final isCompleted = status == 'completed';
      final isAccepted = status == 'accepted' || status == 'confirmed';

      // Don't show before session has started - both must confirm after session
      if (!detailsController.hasSessionStarted()) {
        return const SizedBox.shrink();
      }
      if (!isAccepted || isCompleted) {
        return const SizedBox.shrink();
      }

      final patientConfirmed = detailsController.patientConfirmed.value;
      final doctorConfirmed = detailsController.doctorConfirmed.value;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blue.shade100, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'confirm_session_completion'.tr,
                      style: CustomTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'both_parties_must_confirm'.tr,
                style: CustomTextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),

              // Confirmation status indicators
              Row(
                children: [
                  _buildConfirmationIndicator(
                    icon: Icons.person,
                    label: 'patient'.tr,
                    isConfirmed: patientConfirmed,
                  ),
                  const SizedBox(width: 24),
                  _buildConfirmationIndicator(
                    icon: Icons.medical_services,
                    label: 'you'.tr,
                    isConfirmed: doctorConfirmed,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Confirmation button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: doctorConfirmed
                      ? null
                      : () => detailsController.confirmSessionCompletion(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: doctorConfirmed
                        ? Colors.grey
                        : Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: doctorConfirmed ? 0 : 2,
                  ),
                  child: detailsController.isConfirmingSession.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          doctorConfirmed
                              ? 'session_already_confirmed'.tr
                              : 'confirm_session_completion'.tr,
                          style: const CustomTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildConfirmationIndicator({
    required IconData icon,
    required String label,
    required bool isConfirmed,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isConfirmed ? Colors.green.shade50 : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isConfirmed ? Colors.green.shade700 : Colors.grey.shade400,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: CustomTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  isConfirmed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 14,
                  color: isConfirmed
                      ? Colors.green.shade700
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  isConfirmed ? 'confirmed'.tr : 'pending',
                  style: CustomTextStyle(
                    fontSize: 12,
                    color: isConfirmed
                        ? Colors.green.shade700
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
