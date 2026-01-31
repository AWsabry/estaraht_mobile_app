import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';

class DoctorDashboard extends GetView<DoctorDashboardController> {
  final DoctorDashboardController dashboardController = Get.put(
    DoctorDashboardController(),
  );

  DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: const CustomAppBar(title: ''),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
          ),
        ),
      ),
      body: SmartRefresher(
        controller: dashboardController.refreshController,
        onRefresh: dashboardController.onRefresh,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 36.h),
                child: Column(
                  children: [
                    Text(
                      'manage_appointments_easily'.tr,
                      style: CustomTextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontFamily: AppFontStyleTextStrings.medium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'communicate_with_patients_flexibly'.tr,
                      style: CustomTextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        fontFamily: AppFontStyleTextStrings.regular,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 47.h),
              // Upcoming Sessions Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.w),
                child: Container(
                  width: 150.w,
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 12.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[800]!),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Center(
                    child: Text(
                      'upcoming_sessions'.tr,
                      style: CustomTextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: AppFontStyleTextStrings.medium,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Appointments Section
              Obx(
                () => dashboardController.isErrorInLoading.value
                    ? _buildErrorView()
                    : dashboardController.isLoaded.value
                    ? dashboardController.isAppointmentAvailable.value
                          ? _buildPatientCardsHorizontalList(isUpcoming: true)
                          : _buildEmptyAppointmentsView(context)
                    : _buildLoadingView(),
              ),

              // Previous Sessions
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.w),
                child: Container(
                  width: 150.w,
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 12.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[800]!),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Center(
                    child: Text(
                      'previous_sessions'.tr,
                      style: CustomTextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: AppFontStyleTextStrings.medium,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Previous appointments
              Obx(
                () => dashboardController.isErrorInLoading.value
                    ? _buildErrorView()
                    : dashboardController.isLoaded.value
                    ? dashboardController.isAppointmentAvailable.value
                          ? _buildPatientCardsHorizontalList(isUpcoming: false)
                          : _buildEmptyAppointmentsView(context)
                    : _buildLoadingView(),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCardsHorizontalList({required bool isUpcoming}) {
    // Filter appointments based on whether they are upcoming or previous
    // For demonstration, we'll use index % 2 to separate, but you should
    // implement proper filtering based on your data structure
    final List<dynamic> filteredAppointments = dashboardController
        .doctorAppointmentsClass!
        .data!
        .doctorAppointmentData!
        .where(
          (appointment) => isUpcoming
              ? (appointment.status != 'completed' &&
                    appointment.status != 'cancelled')
              : (appointment.status == 'completed' ||
                    appointment.status == 'cancelled'),
        )
        .toList();

    return SizedBox(
      height: 210.h,
      child: filteredAppointments.isEmpty
          ? _buildEmptyAppointmentsView(Get.context!)
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 36.w),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredAppointments.length,
              itemBuilder: (context, index) {
                final appointment = filteredAppointments[index];
                loggerNoStack.i(
                  'Building appointment card for ID: ${appointment.toString()}',
                );
                return _buildPatientCard(appointment, index, isUpcoming);
              },
            ),
    );
  }

  Widget _buildPatientCard(dynamic appointment, int index, bool isUpcoming) {
    return InkWell(
      onTap: () async {
        loggerNoStack.i(
          'Returned from Appointment Detail Screen with value: ${appointment.id.toString()}',
        );
        // Preserve the original navigation functionality
        await Get.toNamed(
          Routes.dAppointmentDetailScreen,
          arguments: {'id': appointment.id.toString()},
        )?.then((value) {
          Get.delete<DAppointmentDetailsController>();
          if (value ?? false) {
            dashboardController.fetchDoctorAppointment();
          }
        });
      },
      child: Container(
        width: 210.w,
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient header
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Patient Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25.r),
                          child: CachedNetworkImage(
                            imageUrl: appointment.image ?? "",
                            height: 48.h,
                            width: 48.w,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 24.sp,
                                color: Colors.grey[900],
                              ),
                            ),
                            errorWidget: (context, url, err) => Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 24.sp,
                                color: Colors.grey[900],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Name and appointment date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.name ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CustomTextStyle(
                                  fontSize: 14.sp,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFontStyleTextStrings.medium,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Builder(
                                builder: (_) {
                                  final dateText = _getAppointmentDateText(
                                    appointment,
                                  );
                                  return dateText.isEmpty
                                      ? const SizedBox.shrink()
                                      : Text(
                                          dateText,
                                          maxLines: 2,
                                          style: CustomTextStyle(
                                            fontSize: 11.sp,
                                            height: 1.3,
                                            color: Colors.grey[700],
                                            fontFamily:
                                                AppFontStyleTextStrings.regular,
                                          ),
                                        );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Status badge
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          appointment.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _getStatusColor(appointment.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(appointment.status),
                        textAlign: TextAlign.center,
                        style: CustomTextStyle(
                          fontSize: 11.sp,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(appointment.status),
                          fontFamily: AppFontStyleTextStrings.medium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
                child: Container(
                  width: double.infinity,
                  height: 1.h,
                  color: Colors.black54,
                ),
              ),

              // Start + Profile buttons
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // Same navigation as the card tap
                          await Get.toNamed(
                            Routes.dAppointmentDetailScreen,
                            arguments: {'id': appointment.id.toString()},
                          )?.then((value) {
                            Get.delete<DAppointmentDetailsController>();
                            if (value ?? false) {
                              dashboardController.fetchDoctorAppointment();
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.color1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          minimumSize: const Size(double.infinity, 36),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            (appointment.status?.toLowerCase() != 'completed' &&
                                    appointment.status?.toLowerCase() !=
                                        'cancelled')
                                ? 'start_session'.tr
                                : 'view_details'.tr,
                            style: CustomTextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontFamily: AppFontStyleTextStrings.regular,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // Navigate to profile (reuse details screen if no dedicated profile route)
                          await Get.toNamed(
                            Routes.dAppointmentDetailScreen,
                            arguments: {'id': appointment.id.toString()},
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[600]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          minimumSize: Size(double.infinity, 36.h),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'profile'.tr,
                            style: CustomTextStyle(
                              fontSize: 12.sp,
                              color: Colors.black87,
                              fontFamily: AppFontStyleTextStrings.regular,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildInterestChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: FittedBox(
        child: Text(
          label,

          style: CustomTextStyle(
            fontSize: 10.sp,
            color: Colors.black87,
            fontFamily: AppFontStyleTextStrings.regular,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAppointmentsView(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 36.w, vertical: 16.h),
      padding: EdgeInsets.all(20.w),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(color: Colors.grey[200]!),
      // ),
      child: Column(
        children: [
          // Image.asset(
          //   AppImages.noAppointment,
          //   height: 100,
          // ),
          // SizedBox(height: 12),
          Center(
            child: Text(
              'doctor_not_appointment_text'.tr,
              textAlign: TextAlign.center,
              style: CustomTextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                fontFamily: AppFontStyleTextStrings.regular,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      height: 180.h,
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40.sp, color: Colors.grey[400]),
            SizedBox(height: 12.h),
            Text(
              'unable_to_load_data'.tr,
              style: CustomTextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontFamily: AppFontStyleTextStrings.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return SizedBox(
      height: 180.h,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
          strokeWidth: 3.w,
        ),
      ),
    );
  }

  // Helper Methods
  String _getStatusText(String? status) {
    if (status == null || status.isEmpty) return 'pending'.tr;
    return status.toLowerCase().tr;
  }

  String _getAppointmentDateText(dynamic appointment) {
    String? dateValue;
    String? timeValue;

    // Get date
    try {
      dateValue = appointment.bookingDate;
    } catch (_) {}
    dateValue = (dateValue == null || dateValue.isEmpty)
        ? (() {
            try {
              return appointment.appointmentDate;
            } catch (_) {
              return null;
            }
          })()
        : dateValue;
    dateValue = (dateValue == null || dateValue.isEmpty)
        ? (() {
            try {
              return appointment.date;
            } catch (_) {
              return null;
            }
          })()
        : dateValue;
    dateValue = (dateValue == null || dateValue.isEmpty)
        ? (() {
            try {
              return appointment.startDate;
            } catch (_) {
              return null;
            }
          })()
        : dateValue;
    dateValue = (dateValue == null || dateValue.isEmpty)
        ? (() {
            try {
              return appointment.createdAt;
            } catch (_) {
              return null;
            }
          })()
        : dateValue;

    // Get time
    try {
      timeValue = appointment.bookingTime;
    } catch (_) {}
    timeValue = (timeValue == null || timeValue.isEmpty)
        ? (() {
            try {
              return appointment.startTime;
            } catch (_) {
              return null;
            }
          })()
        : timeValue;

    if (dateValue == null || dateValue.isEmpty) return '';

    String formattedDate = _formatDate(dateValue);
    String formattedTime = _formatTime(timeValue);

    return formattedTime.isNotEmpty
        ? '$formattedDate $formattedTime'
        : formattedDate;
  }

  String _formatDate(String dateString) {
    if (dateString.length < 10) return dateString;
    return "${dateString.substring(8, 10)}-${dateString.substring(5, 7)}-${dateString.substring(0, 4)}";
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';
    if (timeString.length < 5) return timeString;
    // Extract HH:MM from time (e.g., "08:00:00" -> "08:00")
    return timeString.substring(0, 5);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'accepted':
        return const Color(0xFF3366FF);
      case 'cancelled':
        return Colors.grey;
      case 'pending':
        return Colors.amber;
      default:
        return const Color(0xFF3366FF);
    }
  }
}
