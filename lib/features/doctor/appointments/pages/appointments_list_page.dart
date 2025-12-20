import 'package:videocalling/core/config/app_imports.dart';
class DoctorAllAppointments extends GetView<DAllAppointmentsController> {
  final DAllAppointmentsController appointmentsController = Get.put(
    DAllAppointmentsController(),
  );

  DoctorAllAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: const CustomAppBar(title: ''),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
        ),
      ),
      body: Obx(
        () => appointmentsController.isErrorInLoading.value
            ? _buildErrorState()
            : appointmentsController.isLoaded.value
            ? _buildAppointmentList(context, isArabic)
            : _buildLoadingState(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(BuildContext context, bool isArabic) {
    if (!appointmentsController.isAppointmentAvailable.value) {
      return _buildEmptyAppointments();
    }

    return Stack(
      children: [
        SingleChildScrollView(
          controller: appointmentsController.scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              ListView.builder(
                itemCount: appointmentsController.nextUrl.value != "null"
                    ? appointmentsController.list.length + 1
                    : appointmentsController.list.length,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (appointmentsController.list.length == index &&
                      appointmentsController.nextUrl.value != "null") {
                    return _buildLoadMoreIndicator();
                  } else {
                    return _buildAppointmentCard(context, index, isArabic);
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        if (appointmentsController.isLoadingMore.value)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAppointmentCard(BuildContext context, int index, bool isArabic) {
    final appointment = appointmentsController.list[index];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 34, vertical: 8),

      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Get.toNamed(
            Routes.dAppointmentDetailScreen,
            arguments: {'id': appointment.id.toString()},
          );
          Get.delete<DAppointmentDetailsController>();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildPatientAvatar(appointment),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            appointment.name ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFontStyleTextStrings.medium,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(appointment, context),
                      ],
                    ),
                    const SizedBox(height: 4),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3366FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Color(0xFF3366FF),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      appointment.bookingDate != null
                                          ? DateFormat('dd-MM-yyyy').format(
                                              DateTime.tryParse(
                                                    appointment.bookingDate
                                                        .toString(),
                                                  ) ??
                                                  DateTime.now(),
                                            )
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF3366FF),
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3366FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Color(0xFF3366FF),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      appointment.bookingTime ?? "",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF3366FF),
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildPatientAvatar(dynamic appointment) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: appointment.image ?? "",
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

  Widget _buildStatusBadge(dynamic appointment, BuildContext context) {
    Color statusColor;
    String statusText;

    switch (appointment.status?.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'appointment_status_1'.tr;
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusText = 'appointment_status_2'.tr;
        break;
      case 'accepted':
        statusColor = Colors.orangeAccent;
        statusText = 'appointment_status_3'.tr;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'appointment_status_4'.tr;
        break;
      case 'completed':
        statusColor = Colors.purple;
        statusText = 'appointment_status_5'.tr;
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusText = 'appointment_status_6'.tr;
        break;
      case 'absent':
        statusColor = Colors.brown;
        statusText = 'appointment_status_7'.tr;
        break;
      default:
        statusColor = Colors.grey;
        statusText = appointment.status ?? "";
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

  Widget _buildEmptyAppointments() {
    return Container(
      padding: const EdgeInsets.all(120),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_outlined, size: 120, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'doctor_not_appointment_text'.tr,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontFamily: AppFontStyleTextStrings.regular,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
        ),
      ),
    );
  }
}
