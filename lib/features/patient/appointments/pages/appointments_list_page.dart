import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/appointments/models/uall_appointment_model.dart';
import 'package:videocalling/shared/services/review_service.dart';
import 'package:videocalling/shared/widgets/rating_dialog.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class UAllAppointments extends GetView<UAllAppointmentsController> {
  final UAllAppointmentsController appointmentsController = Get.put(
    UAllAppointmentsController(),
  );

  UAllAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Obx(
            () => Visibility(
              visible: appointmentsController.selectedTab.value == 0,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0.w,
                  vertical: 10.0.h,
                ),
                child: _buildFilterChips(),
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: appointmentsController.selectedTab.value == 1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 46.0.w,
                  vertical: 10.0.h,
                ),
              ),
            ),
          ),
          // Main content area with loading states
          Expanded(
            child: Obx(() {
              // Loading state
              if (!appointmentsController.isLoaded.value) {
                return _buildLoadingState();
              }

              // Error state
              if (appointmentsController.isErrorInLoading.value) {
                return _buildErrorState();
              }

              // Empty or content state
              if (appointmentsController.isAppointmentExist.value &&
                  appointmentsController.filteredList.isNotEmpty) {
                return _buildRefreshableAppointmentList();
              } else {
                return _buildEmptyState(context);
              }
            }),
          ),
        ],
      ),
    );
  }

  // Loading state widget
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
          ),
          SizedBox(height: 16),
          // Text(
          //   'loading_appointments'.tr,
          //   style: const CustomTextStyle(
          //     fontSize: 16,
          //     fontWeight: FontWeight.w500,
          //     color: Color(0xFF3366FF),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Error state widget
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 60.sp),
            SizedBox(height: 16.h),
            Text(
              'error_loading_appointments'.tr,

              style: CustomTextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'please_check_connection'.tr,
              style: CustomTextStyle(color: Colors.grey[600], fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => appointmentsController.refreshAppointments(),
              icon: Icon(Icons.refresh, size: 20.sp),
              label: Text('try_again'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3366FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fixed: removed extra closing brace
  Widget _buildRefreshableAppointmentList() {
    return material.RefreshIndicator(
      onRefresh: () {
        appointmentsController.refreshAppointments();
        return Future<void>.value();
      },
      color: const Color(0xFF3366FF),
      child: _buildAppointmentList(),
    );
  }

  // Session type tabs (Previous/Upcoming)
  Widget _buildSessionTypeTabs() {
    return Obx(
      () => Row(
        children: [
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () => appointmentsController.selectedTab.value = 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: appointmentsController.selectedTab.value == 0
                      ? const Color(0xFF3366FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: appointmentsController.selectedTab.value == 0
                        ? const Color(0xFF3366FF)
                        : Colors.grey.shade500,
                  ),
                ),
                child: Center(
                  child: Text(
                    'previous_sessions'.tr,
                    style: CustomTextStyle(
                      color: appointmentsController.selectedTab.value == 0
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () => appointmentsController.selectedTab.value = 1,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: appointmentsController.selectedTab.value == 1
                      ? const Color(0xFF3366FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: appointmentsController.selectedTab.value == 0
                        ? Colors.grey.shade500
                        : const Color(0xFF3366FF),
                  ),
                ),
                child: Center(
                  child: Text(
                    'upcoming_sessions'.tr,
                    style: CustomTextStyle(
                      color: appointmentsController.selectedTab.value == 1
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }

  // Filter chips row
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all'.tr, 0),
          const SizedBox(width: 8),
          _buildFilterChip('attended'.tr, 1),
          const SizedBox(width: 8),
          _buildFilterChip('canceled'.tr, 2),
          const SizedBox(width: 8),
          _buildFilterChip('postponed'.tr, 3),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final bool isSelected =
        appointmentsController.selectedFilter.value == index;

    Color backgroundColor;
    Color textColor;

    if (isSelected) {
      switch (index) {
        case 1: // Attended
          backgroundColor = AppColors.checkColor2;
          break;
        case 2: // Canceled
          backgroundColor = AppColors.checkColor1;
          break;
        case 3: // Postponed
          backgroundColor = AppColors.color2;
          break;
        default: // All
          backgroundColor = Colors.black;
      }
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: () => appointmentsController.selectedFilter.value = index,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected ? backgroundColor : Colors.grey.shade500,
          ),
        ),
        child: Text(
          label,
          style: CustomTextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }

  // AppointmentList with loading indicator
  Widget _buildAppointmentList() {
    return GridView.builder(
      controller: appointmentsController.scrollController,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two items per row
        childAspectRatio: 0.78, // Controls card height
        crossAxisSpacing: 12.w, // Horizontal spacing between cards
        mainAxisSpacing: 12.h, // Vertical spacing between cards
      ),
      itemCount: appointmentsController.nextUrl.value == "null"
          ? appointmentsController.filteredList.length
          : appointmentsController.filteredList.length + 1,
      itemBuilder: (context, index) {
        if (index == appointmentsController.filteredList.length &&
            appointmentsController.isLoadingMore.value) {
          return Padding(
            padding: EdgeInsets.all(20.0.w),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
                strokeWidth: 2.w,
              ),
            ),
          );
        } else if (index < appointmentsController.filteredList.length) {
          final appointment = appointmentsController.filteredList[index];
          return _buildAppointmentCardContent(appointment, context);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildAppointmentCardContent(
    UAppointmentData appointment,
    BuildContext context,
  ) {
    final bool isPastSession = appointmentsController.selectedTab.value == 0;
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: appointmentsController.selectedTab.value == 1 ? 8 : 12,
            ),
            // Doctor info row
            Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Doctor image
                ClipRRect(
                  borderRadius: BorderRadius.circular(25.r),
                  child: CachedNetworkImage(
                    imageUrl: appointment.image ?? '',
                    height: 50.h,
                    width: 50.w,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      AppImages.getDoctorPlaceholder(appointment.gender),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, err) => Image.asset(
                      AppImages.getDoctorPlaceholder(appointment.gender),
                      height: 50.h,
                      width: 50.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: isArabic ? 0 : 12.w),
                SizedBox(width: isArabic ? 12.w : 0),

                // Doctor name and specialty
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        (appointment.name ?? 'Unknown').isEmpty
                            ? (appointment.name ?? 'Unknown')
                            : (appointment.name ?? 'Unknown')[0].toUpperCase() +
                                  (appointment.name ?? 'Unknown').substring(1),
                        style: CustomTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          height: isArabic ? 1.2 : 1.0,
                        ),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        appointment.departmentName ?? 'Specialist',
                        style: CustomTextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        appointmentsController.statusMap[appointment.status] ??
                            appointment.status ??
                            'Unknown',
                        style: CustomTextStyle(
                          fontSize: 11.sp,
                          height: 1.2,
                          color: Colors.grey[500],
                        ),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Date and time row with timezone support
            Padding(
              padding: EdgeInsets.only(
                top: appointmentsController.selectedTab.value == 1 ? 12 : 32,
              ),
              child: Row(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time text with timezone offset
                  Expanded(
                    child: Text(
                      _formatAppointmentDateTime(
                        appointment.date ?? '',
                        appointment.slot ?? '',
                        isArabic,
                      ),
                      style: CustomTextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                        height: isArabic ? 1.3 : 1.0,
                      ),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: isArabic ? 0 : 6.w),
                  SizedBox(width: isArabic ? 6.w : 0),
                  // Time icon
                  SvgPicture.asset(
                    AppImages.appointmentTime,
                    color: AppColors.color1,
                    fit: BoxFit.cover,
                    height: 20.h,
                    width: 20.w,
                  ),
                ],
              ),
            ),

            // Spacer to push buttons to bottom
            SizedBox(height: 10.h),

            // Action buttons based on session type
            isPastSession
                ? _buildReviewButton(appointment)
                : _buildSessionActionButtons(appointment),
          ],
        ),
      ),
    );
  }

  /// Format appointment date and time with timezone support
  String _formatAppointmentDateTime(String dateStr, String timeStr, bool isArabic) {
    if (dateStr.isEmpty || timeStr.isEmpty) {
      return isArabic ? '' : '';
    }

    try {
      // Parse date and time to create DateTime object
      final doctorDateTime = _parseAppointmentDateTime(dateStr, timeStr);
      
      if (isArabic) {
        // For Arabic: show date on first line, time with offset on second line
        final dateFormatted = TimezoneService.formatDateArabic(doctorDateTime);
        final timeFormatted = TimezoneService.formatAppointmentTimeWithOffset(doctorDateTime);
        return '$dateFormatted\n$timeFormatted';
      } else {
        // For English: "Date at Time (Timezone offset if needed)"
        final dateFormatted = _formatDate(dateStr);
        final timeFormatted = _formatAppointmentTimeEnglish(doctorDateTime);
        return '$dateFormatted at $timeFormatted';
      }
    } catch (e) {
      // Fallback to old format if parsing fails
      return isArabic
          ? "${_formatDateArabic(dateStr)} \n ${_formatTimeArabic(timeStr)} "
          : "${_formatDate(dateStr)} at ${_formatTime(timeStr)}";
    }
  }

  /// Parse appointment date and time strings to DateTime
  DateTime _parseAppointmentDateTime(String dateStr, String timeStr) {
    // Parse date (format: YYYY-MM-DD)
    final dateParts = dateStr.split('-');
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);

    // Parse time (format: "10:00 AM" or "14:30")
    int hour = 0;
    int minute = 0;

    if (timeStr.contains('AM') || timeStr.contains('PM') || 
        timeStr.contains('am') || timeStr.contains('pm')) {
      // 12-hour format with AM/PM
      final parts = timeStr.toUpperCase().split(' ');
      final timePart = parts[0];
      final period = parts.length > 1 ? parts[1] : 'AM';

      final timeParts = timePart.split(':');
      hour = int.parse(timeParts[0]);
      if (timeParts.length > 1) {
        minute = int.parse(timeParts[1]);
      }

      // Convert to 24-hour format
      if (period.contains('PM') && hour != 12) {
        hour += 12;
      } else if (period.contains('AM') && hour == 12) {
        hour = 0;
      }
    } else {
      // 24-hour format
      final timeParts = timeStr.split(':');
      hour = int.parse(timeParts[0]);
      if (timeParts.length > 1) {
        minute = int.parse(timeParts[1]);
      }
    }

    // Create DateTime as UTC (Mauritania time GMT+0)
    return DateTime.utc(year, month, day, hour, minute);
  }

  /// Format appointment time for English with timezone offset
  String _formatAppointmentTimeEnglish(DateTime doctorDateTime) {
    final offset = TimezoneService.getTimezoneOffsetFromMauritania();
    
    // Format doctor's time
    final hour = doctorDateTime.hour;
    final minute = doctorDateTime.minute;
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final doctorTime = '$hour12:${minute.toString().padLeft(2, '0')} $period';
    
    // If same timezone, just show the time
    if (offset == 0) {
      return doctorTime;
    }
    
    // Convert to patient's local time
    final patientTime = TimezoneService.mauritaniaToLocalTime(doctorDateTime);
    final pHour = patientTime.hour;
    final pMinute = patientTime.minute;
    final pHour12 = pHour > 12 ? pHour - 12 : (pHour == 0 ? 12 : pHour);
    final pPeriod = pHour >= 12 ? 'PM' : 'AM';
    final patientTimeStr = '$pHour12:${pMinute.toString().padLeft(2, '0')} $pPeriod';
    
    return '$doctorTime ($patientTimeStr your time)';
  }

  String _formatTimeArabic(String timeStr) {
    if (timeStr.isEmpty) return '';

    // Check if the time string contains AM or PM
    if (timeStr.contains('AM') || timeStr.contains('am')) {
      return timeStr.replaceAll('AM', 'صباحا').replaceAll('am', 'صباحا');
    } else if (timeStr.contains('PM') || timeStr.contains('pm')) {
      return timeStr.replaceAll('PM', 'مساء').replaceAll('pm', 'مساء');
    }

    return timeStr;
  }

  String _formatDateArabic(String dateStr) {
    try {
      // Parse the date (assuming format is YYYY-MM-DD)
      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) return dateStr;

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      final date = DateTime(year, month, day);

      // Arabic day names
      final List<String> arabicDays = [
        'الأحد',
        'الإثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
      ];

      // Arabic month names
      final List<String> arabicMonths = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];

      // Get Arabic day name and format
      final dayName = arabicDays[date.weekday % 7]; // Sunday is 0 in Arabic
      final arabicMonth = arabicMonths[date.month - 1];

      // Format the date in Arabic style
      return '$dayName، $day $arabicMonth';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildSessionActionButtons(UAppointmentData appointment) {
    final isRejected =
        appointment.status == '5' ||
        appointment.status?.toLowerCase() == 'rejected' ||
        appointment.status?.toLowerCase() == 'cancelled';

    final isCompleted =
        appointment.status == '4' ||
        appointment.status?.toLowerCase() == 'completed';

    final buttonText = isCompleted ? 'view_details'.tr : 'attend_session'.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 16.h),
        SizedBox(
          height: 32.h,
          width: 120.w,
          child: ElevatedButton(
            onPressed: isRejected
                ? null
                : () {
                    Get.toNamed(
                      Routes.uAppointmentDetailScreen,
                      arguments: {'id': appointment.id.toString()},
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isRejected
                  ? Colors.grey[400]
                  : const Color(0xFF3366FF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60.r),
              ),
              disabledBackgroundColor: Colors.grey[400],
            ),
            child: Text(
              buttonText,
              style: CustomTextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontFamily: Get.locale?.languageCode == 'ar'
                    ? 'NotoKufiArabic'
                    : 'Roboto',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewButton(UAppointmentData appointment) {
    final isCompleted =
        appointment.status == '4' || appointment.status == 'completed';
    final userId = StorageService.readData(key: LocalStorageKeys.userId) ?? "";

    return Column(
      children: [
        SizedBox(
          height: 32.h,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(
                Routes.uAppointmentDetailScreen,
                arguments: {'id': appointment.id.toString()},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3366FF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.r),
              ),
            ),
            child: Text(
              'view_details'.tr,
              style: CustomTextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontFamily: Get.locale?.languageCode == 'ar'
                    ? 'NotoKufiArabic'
                    : 'Roboto',
              ),
            ),
          ),
        ),
        if (isCompleted) ...[
          SizedBox(height: 6.h),
          SizedBox(
            height: 32.h,
            width: double.infinity,
            child: FutureBuilder<bool>(
              future: reviewService.hasReviewedBooking(appointment.id ?? ''),
              builder: (context, snapshot) {
                final hasReviewed = snapshot.data ?? false;
                if (hasReviewed) {
                  return ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                    ),
                    child: Text(
                      'rated'.tr,
                      style: CustomTextStyle(
                        color: Colors.grey[600],
                        fontSize: 11.sp,
                        fontFamily: Get.locale?.languageCode == 'ar'
                            ? 'NotoKufiArabic'
                            : 'Roboto',
                      ),
                    ),
                  );
                }
                return ElevatedButton(
                  onPressed: () {
                    showRatingDialog(
                      bookingId: appointment.id ?? '',
                      doctorId: appointment.doctorId ?? '',
                      patientId: userId,
                      doctorName: appointment.name ?? 'Doctor',
                      onSubmitted: () {
                        appointmentsController.refreshAppointments();
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34C759),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                  ),
                  child: Text(
                    'rate'.tr,
                    style: CustomTextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontFamily: Get.locale?.languageCode == 'ar'
                          ? 'NotoKufiArabic'
                          : 'Roboto',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      // Parse the date (assuming format is YYYY-MM-DD)
      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) return dateStr;

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      final date = DateTime(year, month, day);

      // Format: Sunday, March 17
      return DateFormat('EEEE, MMMM d').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';

    try {
      // Parse time string (expecting formats like "10:00 AM", "14:30", "2:30 PM", etc.)
      timeStr = timeStr.trim();

      // If already contains AM/PM, just format it nicely
      if (timeStr.toUpperCase().contains('AM') ||
          timeStr.toUpperCase().contains('PM')) {
        // Extract time and period
        final parts = timeStr.split(' ');
        if (parts.length >= 2) {
          final timePart = parts[0];
          final period = parts[1].toUpperCase();

          // Parse hour and minute
          final timeParts = timePart.split(':');
          if (timeParts.isNotEmpty) {
            int hour = int.tryParse(timeParts[0]) ?? 0;

            // Format: 10 PM, 2 AM, etc.
            return '$hour $period';
          }
        }
        return timeStr;
      }

      // If 24-hour format (like "14:30")
      final timeParts = timeStr.split(':');
      if (timeParts.isNotEmpty) {
        int hour = int.tryParse(timeParts[0]) ?? 0;

        if (hour == 0) {
          return '12 AM';
        } else if (hour < 12) {
          return '$hour AM';
        } else if (hour == 12) {
          return '12 PM';
        } else {
          return '${hour - 12} PM';
        }
      }

      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50.h),
          Text(
            appointmentsController.selectedTab.value == 0
                ? 'no_sessions_yet'.tr
                : 'no_upcoming_sessions'.tr,
            style: CustomTextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'ready_to_start'.tr,
            style: CustomTextStyle(fontSize: 16.sp, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50.h),
          SvgPicture.asset(AppImages.appointmentEmpty, height: 150.h),
          SizedBox(height: 80.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 28.w),
              _buildActionButton('book_a_new_appointment'.tr, true, () {
                Get.toNamed(Routes.indemandDoctorScreen);
              }),
              SizedBox(width: 8.w),
              _buildActionButton('find_a_therapist'.tr, false, () async {
                await Get.toNamed(
                  Routes.dSearchScreen,
                  arguments: {
                    'keyword': '',
                    'category': '',
                    'categoryIndex': 0,
                  },
                );
                Get.delete<DoctorSearchController>();
              }),
              SizedBox(width: 28.w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, bool isPrimary, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 40.h,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            textStyle: CustomTextStyle(
              fontSize: Get.locale?.languageCode == 'ar'
                  ? 10.sp
                  : Get.locale?.languageCode == 'fr'
                  ? 12.sp
                  : 14.sp,
              fontFamily: Get.locale?.languageCode == 'ar'
                  ? 'NotoKufiArabic'
                  : 'Roboto',
            ),
            backgroundColor: isPrimary ? const Color(0xFF3366FF) : Colors.white,
            foregroundColor: isPrimary ? Colors.white : Colors.black,
            side: isPrimary ? null : BorderSide(color: Colors.grey.shade600),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
