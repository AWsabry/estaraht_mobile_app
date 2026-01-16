import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            Icon(
              Icons.search_off_rounded,
              size: 100.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20.h),
            Text(
              'unable_to_load_data'.tr,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF3366FF),
              ),
              strokeWidth: 3.w,
            ),
            SizedBox(height: 20.h),
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
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0.h),
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
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
        if (appointmentsController.isLoadingMore.value)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF3366FF),
                  ),
                  strokeWidth: 3.w,
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
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),

      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey[200]!, width: 1.w),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () async {
          final result = await Get.toNamed(
            Routes.dAppointmentDetailScreen,
            arguments: {'id': appointment.id.toString()},
          );
          Get.delete<DAppointmentDetailsController>();

          // Refresh list if changes were made
          if (result == true) {
            appointmentsController.fetchPastAppointments();
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              _buildPatientAvatar(appointment),
              SizedBox(width: 16.w),
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
                              fontSize: 16.sp,
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
                    SizedBox(height: 4.h),

                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3366FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14.sp,
                                    color: const Color(0xFF3366FF),
                                  ),
                                  SizedBox(width: 6.w),
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
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF3366FF),
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3366FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14.sp,
                                    color: const Color(0xFF3366FF),
                                  ),
                                  SizedBox(width: 6.w),
                                  Flexible(
                                    child: Text(
                                      appointment.bookingTime ?? "",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF3366FF),
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
      borderRadius: BorderRadius.circular(16.r),
      child: CachedNetworkImage(
        imageUrl: appointment.image ?? "",
        height: 80.h,
        width: 80.w,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
        errorWidget: (context, url, err) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.person, size: 40.sp, color: Colors.grey[400]),
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8.sp, color: statusColor),
          SizedBox(width: 6.w),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12.sp,
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
      // margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 120.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24.h),
            Text(
              'doctor_not_appointment_text'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                fontFamily: AppFontStyleTextStrings.regular,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      alignment: Alignment.center,
      child: SizedBox(
        height: 30.h,
        width: 30.w,
        child: CircularProgressIndicator(
          strokeWidth: 3.w,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
        ),
      ),
    );
  }
}
