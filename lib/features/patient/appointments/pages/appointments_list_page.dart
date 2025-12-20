import 'package:flutter/material.dart' as material;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/appointments/models/uall_appointment_model.dart';
class UAllAppointments extends GetView<UAllAppointmentsController> {
  final UAllAppointmentsController appointmentsController = Get.put(
    UAllAppointmentsController(),
  );

  UAllAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: CustomAppBar(title: 'all_appointment'.tr),
        leading: Container(),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: _buildSessionTypeTabs(),
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(
            () => Visibility(
              visible: appointmentsController.selectedTab.value == 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: _buildFilterChips(),
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: appointmentsController.selectedTab.value == 1,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 46.0, vertical: 10.0),
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
          //   style: const TextStyle(
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 60),
            const SizedBox(height: 16),
            Text(
              'error_loading_appointments'.tr,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'please_check_connection'.tr,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => appointmentsController.refreshAppointments(),
              icon: const Icon(Icons.refresh),
              label: Text('try_again'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3366FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => appointmentsController.selectedTab.value = 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: appointmentsController.selectedTab.value == 0
                      ? const Color(0xFF3366FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: appointmentsController.selectedTab.value == 0
                        ? const Color(0xFF3366FF)
                        : Colors.grey.shade500,
                  ),
                ),
                child: Center(
                  child: Text(
                    'previous_sessions'.tr,
                    style: TextStyle(
                      color: appointmentsController.selectedTab.value == 0
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => appointmentsController.selectedTab.value = 1,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: appointmentsController.selectedTab.value == 1
                      ? const Color(0xFF3366FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: appointmentsController.selectedTab.value == 0
                        ? Colors.grey.shade500
                        : const Color(0xFF3366FF),
                  ),
                ),
                child: Center(
                  child: Text(
                    'upcoming_sessions'.tr,
                    style: TextStyle(
                      color: appointmentsController.selectedTab.value == 1
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? backgroundColor : Colors.grey.shade500,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // AppointmentList with loading indicator
  Widget _buildAppointmentList() {
    return GridView.builder(
      controller: appointmentsController.scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two items per row
        childAspectRatio: 0.78, // Controls card height
        crossAxisSpacing: 12, // Horizontal spacing between cards
        mainAxisSpacing: 12, // Vertical spacing between cards
      ),
      itemCount: appointmentsController.nextUrl.value == "null"
          ? appointmentsController.filteredList.length
          : appointmentsController.filteredList.length + 1,
      itemBuilder: (context, index) {
        if (index == appointmentsController.filteredList.length &&
            appointmentsController.isLoadingMore.value) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
                strokeWidth: 2,
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appointmentsController.selectedTab.value == 1
                ? const SizedBox(height: 8)
                : const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Doctor image with info indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: CachedNetworkImage(
                        imageUrl: appointment.image ?? '',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          AppImages.getDoctorPlaceholder(appointment.gender),
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, err) => Image.asset(
                          AppImages.getDoctorPlaceholder(appointment.gender),
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Doctor name and specialty
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 90),
                        child: Text(
                          appointment.name ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: Get.locale?.languageCode == 'ar' ? 1 : 1.0,
                          ),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.departmentName ?? 'Specialist',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.2,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Date and time
            Padding(
              padding: EdgeInsets.only(
                top: appointmentsController.selectedTab.value == 1 ? 12 : 32,
                left: 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      Get.locale?.languageCode == 'ar'
                          ? "${_formatDateArabic(appointment.date ?? '')} \n ${_formatTimeArabic(appointment.slot ?? '')} "
                          : "${_formatDate(appointment.date ?? '')} at ${_formatTime(appointment.slot ?? '')}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[800],
                        height: Get.locale?.languageCode == 'ar' ? 1.3 : 1.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset(
                    AppImages.appointmentTime,
                    color: AppColors.color1,
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                ],
              ),
            ),

            // Spacer to push buttons to bottom
            const SizedBox(height: 10),

            // Action buttons based on session type
            isPastSession
                ? _buildReviewButton(appointment)
                : _buildSessionActionButtons(appointment),
          ],
        ),
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Postpone button
        // SizedBox(
        //   height: 32, // Reduced height
        //   width: 120, // Fixed width
        //   child: OutlinedButton(
        //     onPressed: () {
        //       Get.toNamed(
        //         Routes.uAppointmentDetailScreen,
        //         arguments: {'id': appointment.id.toString()},
        //       );
        //     },
        //     style: OutlinedButton.styleFrom(
        //       side: const BorderSide(color: Colors.grey),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(60),
        //       ),
        //     ),
        //     child: Text(
        //       'postpone'.tr,
        //       style: TextStyle(
        //         fontSize: 12,
        //         fontFamily: Get.locale?.languageCode == 'ar'
        //             ? 'NotoKufiArabic'
        //             : 'Roboto',
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(height: 16),

        // Attend session button
        SizedBox(
          height: 32,
          width: 120, // Fixed width
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
                borderRadius: BorderRadius.circular(60),
              ),
            ),
            child: Text(
              'attend_session'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
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
    return SizedBox(
      height: 32, // Reduced height
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to the review screen with the correct arguments
          Get.toNamed(
            Routes.doctorReviewScreen,
            arguments: {
              'id': appointment.id.toString(), // Use appointment ID directly
              'appointmentId': appointment.id.toString(),
              'doctorName': appointment.name.toString(),
              'doctorImage': appointment.image.toString(),
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF34C759),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Text(
          'review'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: Get.locale?.languageCode == 'ar'
                ? 'NotoKufiArabic'
                : 'Roboto',
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Text(
            appointmentsController.selectedTab.value == 0
                ? 'no_sessions_yet'.tr
                : 'no_upcoming_sessions'.tr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'ready_to_start'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          SvgPicture.asset(AppImages.appointmentEmpty, height: 150),
          const SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 28),
              _buildActionButton('book_a_new_appointment'.tr, true, () {
                Get.toNamed(Routes.indemandDoctorScreen);
              }),
              const SizedBox(width: 8),
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
              const SizedBox(width: 28),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, bool isPrimary, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(
              fontSize: Get.locale?.languageCode == 'fr' ? 12 : 14,
              fontFamily: Get.locale?.languageCode == 'ar'
                  ? 'NotoKufiArabic'
                  : 'Roboto',
            ),
            backgroundColor: isPrimary ? const Color(0xFF3366FF) : Colors.white,
            foregroundColor: isPrimary ? Colors.white : Colors.black,
            side: isPrimary ? null : BorderSide(color: Colors.grey.shade600),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
