import 'package:videocalling/core/config/app_imports.dart';

class UserAppointmentDetailsScreen
    extends GetView<UserAppointmentDetailsController> {
  final UserAppointmentDetailsController detailsController = Get.put(
    UserAppointmentDetailsController(),
  );

  UserAppointmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'appointment'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppFontStyleTextStrings.medium,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 8, right: 30),
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
      ),
      body: Obx(
        () => detailsController.isErrorInLoading.value
            ? _buildErrorState()
            : FutureBuilder(
                future: detailsController.getAppointmentDetails,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.connectionState == ConnectionState.none) {
                    return Container();
                  } else {
                    return _buildAppointmentDetails(context, isArabic);
                  }
                },
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
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
            // Text(
            //   'loading_appointment'.tr,
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Colors.grey[600],
            //   ),
            // ),
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
          _buildDoctorInfoCard(context, isArabic),
          const SizedBox(height: 16),
          _buildContactInfoCard(context, isArabic),
          const SizedBox(height: 16),
          _buildPrescriptionCard(context, isArabic),
          const SizedBox(height: 16),
          _buildReportsCard(context, isArabic),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoCard(BuildContext context, bool isArabic) {
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
                _buildDoctorAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detailsController
                            .doctorAppointmentDetailsClass!
                            .data!
                            .doctorName!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (detailsController.doctorSpeciality.isNotEmpty)
                        Text(
                          detailsController.doctorSpeciality.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'appointment_date'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${detailsController.doctorAppointmentDetailsClass!.data!.date.toString().substring(8)}-${detailsController.doctorAppointmentDetailsClass!.data!.date.toString().substring(5, 7)}-${detailsController.doctorAppointmentDetailsClass!.data!.date.toString().substring(0, 4)}",
                          style: const TextStyle(
                            fontSize: 16,
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
                        'time'.tr,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detailsController
                            .doctorAppointmentDetailsClass!
                            .data!
                            .slot!,
                        style: const TextStyle(
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

  Widget _buildDoctorAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: detailsController
            .doctorAppointmentDetailsClass!
            .data!
            .doctorImage
            .toString(),
        height: 80,
        width: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Image.asset(
          AppImages.getDoctorPlaceholder(
            detailsController.doctorAppointmentDetailsClass!.data!.doctorGender,
          ),
          height: 80,
          width: 80,
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, err) => Image.asset(
          AppImages.getDoctorPlaceholder(
            detailsController.doctorAppointmentDetailsClass!.data!.doctorGender,
          ),
          height: 80,
          width: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isArabic) {
    String statusText = '';
    Color statusColor;

    switch (detailsController.doctorAppointmentDetailsClass!.data!.status!) {
      case 0:
        statusText = 'appointment_status_1'.tr;
        statusColor = Colors.blue;
        break;
      case 1:
        statusText = 'appointment_status_2'.tr;
        statusColor = Colors.green;
        break;
      case 2:
        statusText = 'appointment_status_3'.tr;
        statusColor = Colors.orange;
        break;
      case 3:
        statusText = 'appointment_status_4'.tr;
        statusColor = Colors.red;
        break;
      case 4:
        statusText = 'appointment_status_5'.tr;
        statusColor = Colors.purple;
        break;
      default:
        statusText = 'appointment_status_6'.tr;
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
            style: TextStyle(
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            /*    _buildContactItem(
              context: context,
              icon: Icons.phone,
              title: 'phone_number'.tr,
              value: detailsController
                  .doctorAppointmentDetailsClass!.data!.phone!
                  .toString(),
              onTap: () {
                launch(
                    "tel:${detailsController.doctorAppointmentDetailsClass!.data!.phone!}");
              },
              isArabic: isArabic,
            ),*/
            const SizedBox(height: 16),
            _buildContactItem(
              context: context,
              icon: Icons.email,
              title: 'email_address'.tr,
              value:
                  detailsController.doctorAppointmentDetailsClass!.data!.email!,
              onTap: () {
                launch(
                  Uri(
                    scheme: 'mailto',
                    path: detailsController
                        .doctorAppointmentDetailsClass!
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
                  'bio'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detailsController
                          .doctorAppointmentDetailsClass!
                          .data!
                          .description!
                          .isNotEmpty
                      ? detailsController
                            .doctorAppointmentDetailsClass!
                            .data!
                            .description!
                      : 'bio_not_available'.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      await Get.toNamed(
                        Routes.chatScreen,
                        arguments: {
                          'userName': detailsController
                              .doctorAppointmentDetailsClass!
                              .data!
                              .doctorName,
                          'uid': '100${detailsController.doctorId.value}',
                          'isUser': false,
                        },
                      );
                      Get.delete<ChatController>();
                    },
                  ),
                ),
              ],
            ),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            style: const TextStyle(
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
        !(detailsController.doctorAppointmentDetailsClass!.prescription
                    .toString() ==
                "null" ||
            detailsController
                .doctorAppointmentDetailsClass!
                .prescription!
                .medicine!
                .isEmpty);

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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasPrescriptions
                            ? 'user_no_prescription_msg1'.tr
                            : 'user_no_prescription_msg'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasPrescriptions) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 8),
              _buildPrescriptionList(context, isArabic),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await Get.toNamed(
                    Routes.uAppointmentPdfScreen,
                    arguments: {
                      'appointmentId': int.parse(detailsController.id),
                    },
                  );
                  Get.delete<AppointmentDetailsScreenPdfController>();
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: Text(
                  'download_prescription'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
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
          .doctorAppointmentDetailsClass!
          .prescription!
          .medicine!
          .length,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.grey[300], thickness: 1, height: 32),
      itemBuilder: (context, i) {
        final medicine = detailsController
            .doctorAppointmentDetailsClass!
            .prescription!
            .medicine![i];

        return Column(
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              medicine.medicine_name ?? "",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              title: 'medicine_param1'.tr,
              value:
                  "${medicine.type.toString().substring(0, 1).toUpperCase()}${medicine.type.toString().substring(1).toLowerCase()}",
              isArabic: isArabic,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              title: 'medicine_param2'.tr,
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
                  'medicine_param3'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
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
                          style: const TextStyle(
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
              'consume_it_days'.trParams({'days': '${medicine.repeatDays}'}),
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildReportsCard(BuildContext context, bool isArabic) {
    final hasReports =
        (detailsController.doctorAppointmentDetailsClass!.image?.length ?? 0) !=
        0;

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
                        'report'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasReports
                            ? 'user_no_report_msg1'.tr
                            : 'user_no_report_msg'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasReports) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    detailsController
                        .doctorAppointmentDetailsClass!
                        .image
                        ?.length ??
                    0,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[300], thickness: 1, height: 24),
                itemBuilder: (context, i) {
                  final report = detailsController
                      .doctorAppointmentDetailsClass!
                      .image![i];

                  return Row(
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: "${Apis.reportImagePath}${report.image}",
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            height: 70,
                            width: 70,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          report.name ?? "",
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Color(0xFF3366FF),
                        ),
                        onPressed: () async {
                          customDialog1(
                            s1: 'reporting_dialog1'.tr,
                            s2: 'please_wait_while_processing'.tr,
                          );

                          await detailsController
                              .downloadAndSaveImage(
                                "${Apis.reportImagePath}${report.image}",
                              )
                              .then((value) {
                                if (value) {
                                  Get.back();
                                  customDialog(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    s1: 'success'.tr,
                                    s2: 'image_save_success'.tr,
                                  );
                                }
                              });
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
