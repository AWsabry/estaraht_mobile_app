import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class DoctorDetailScreen extends GetView<DoctorDetailController> {
  final DoctorDetailController detailController = Get.put(
    DoctorDetailController(),
  );

  DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => detailController.isErrorInLoading.value
            ? _buildErrorView()
            : !detailController.isLoading.value
            ? _buildMainContent(context)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          10.hs,
          Icon(
            Icons.search_off_rounded,
            size: 100,
            color: AppColors.LIGHT_GREY_TEXT,
          ),
          20.hs,
          Text(
            'unable_to_load_data'.tr,
            style: CustomTextStyle(fontFamily: AppFontStyleTextStrings.regular),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Stack(
        children: [
          // Base NestedScrollView with header
          NestedScrollView(
            // Add this physics property to prevent scrolling
            physics: const NeverScrollableScrollPhysics(),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) => [
                  _buildHeaderSliver(context),
                ],
            body: const SizedBox(),
          ),
          // Overlapping content with rounded corners
          Positioned(
            top: 440,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(38, 20, 38, 20),
                      child: TabBar(
                        isScrollable: true,
                        labelColor: AppColors.color1,
                        unselectedLabelColor: Colors.black,
                        indicatorColor: AppColors.color1,
                        labelStyle: CustomTextStyle(
                          fontSize: 12,
                          fontFamily: AppFontStyleTextStrings.regular,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        indicatorWeight: 1.2,
                        tabs: [
                          Tab(text: 'bio'.tr),
                          Tab(text: 'specialization'.tr),
                          Tab(text: 'available_appointments'.tr),
                          Tab(text: 'reviews'.tr),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildBioTab(context),
                          _buildSpecializationTab(context),
                          _buildAppointmentsTab(context),
                          _buildReviewsTab(context),
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
    );
  }

  Widget _buildHeaderSliver(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 450,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.only(
          left: Get.locale?.languageCode == 'ar' ? 0 : 24,
          top: 16,
          right: Get.locale?.languageCode == 'ar' ? 24 : 0,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: () => Get.back(),
          child: Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 18,
              // Offset slightly to compensate for icon's asymmetry
              textDirection: Get.locale?.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Doctor image
            Container(
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
              child: CachedNetworkImage(
                imageUrl: detailController.doctorDetailsClass!.data!.image!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Image.asset(
                  AppImages.getDoctorPlaceholder(
                    detailController.doctorDetailsClass!.data!.gender,
                  ),
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, err) => Image.asset(
                  AppImages.getDoctorPlaceholder(
                    detailController.doctorDetailsClass!.data!.gender,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Stats cards on left side
            Positioned(
              left: 24,
              top: 126,
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatCard(
                      svgIcon: AppImages.workIcon,
                      iconColor: AppColors.color1,
                      title:
                          "${detailController.doctorDetailsClass?.data?.yearsOfExp} ${"years".tr}",
                      subtitle: "of_experience".tr,
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => _buildStatCard(
                        svgIcon: AppImages.reviewsIcon,
                        iconColor: AppColors.color1,
                        title: detailController.averageRating.value > 0
                            ? detailController.averageRating.value
                                  .toStringAsFixed(1)
                            : (detailController
                                      .doctorDetailsClass
                                      ?.data
                                      ?.avgratting
                                      ?.toStringAsFixed(1) ??
                                  '0.0'),
                        subtitle:
                            '${detailController.totalReviews.value} ${"reviews".tr}',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => _buildStatCard(
                        svgIcon: AppImages.groupOfPeaple,
                        iconColor: AppColors.color1,
                        title: detailController.uniquePatients.value.toString(),
                        subtitle: "patients".tr,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Doctor info at the bottom
            Positioned(
              left: 24,
              right: 24,
              top: 350,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Row(
                  children: [
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 30,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Colors.grey[100]?.withOpacity(0.9) ??
                                  Colors.grey.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (detailController
                                                  .doctorDetailsClass
                                                  ?.data
                                                  ?.departmentName ==
                                              null ||
                                          detailController
                                                  .doctorDetailsClass
                                                  ?.data
                                                  ?.departmentName ==
                                              '')
                                      ? "Psychologist"
                                      : detailController
                                                .doctorDetailsClass
                                                ?.data
                                                ?.departmentName ??
                                            '',
                                  style: CustomTextStyle(
                                    height: 1.2,
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  detailController
                                          .doctorDetailsClass
                                          ?.data
                                          ?.name ??
                                      "Name",
                                  style: const CustomTextStyle(
                                    height: 1.2,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            loggerNoStack.f(
                              " this is the value of  is loggedIn${controller.isLoggedIn}",
                            );
                            detailController.processPayment();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3961F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'book'.tr,
                            style: const CustomTextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String svgIcon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SvgPicture.asset(svgIcon, color: iconColor, height: 20, width: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const CustomTextStyle(
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                style: CustomTextStyle(
                  height: 1.2,
                  color: Colors.grey.shade900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBioTab(BuildContext context) {
    final aboutText =
        detailController.doctorDetailsClass?.data?.aboutus?.toString() ??
        "bio_not_available".tr;

    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 20),
      children: [
        Text(
          aboutText,
          style: const CustomTextStyle(
            fontSize: 14,
            height: 1.2, // Specific line height for Arabic
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 32),

        // Stats grid rows
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Obx(
                    () => _buildStatItem(
                      icon: Icons.video_call,
                      title: "number_of_sessions".tr,
                      value: '${detailController.completedSessions.value}',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Obx(
                    () => _buildStatItem(
                      icon: Icons.star,
                      title: "reviews".tr,
                      value: '${detailController.totalReviews.value}',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Second row of stats
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Obx(
                    () => _buildStatItem(
                      icon: Icons.group,
                      title: "patients".tr,
                      value: '${detailController.uniquePatients.value}',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _buildStatItem(
                    icon: Icons.access_time,
                    title: "avg_session_time".tr,
                    value:
                        '${detailController.doctorDetailsClass?.data?.avgSessionTime ?? 30} ${"min".tr}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // For RTL support
      textDirection: TextDirection.ltr, // Will be auto-switched for Arabic
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          title.tr,
          style: const CustomTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.2, // Specified line height for Arabic
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.tr,
          style: const CustomTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.2, // Specified line height for Arabic
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationTab(BuildContext context) {
    // Extract specializations from the doctor data
    List<String> specializations = [];

    if (detailController.doctorDetailsClass?.data?.specializations != null) {
      for (var spec
          in detailController.doctorDetailsClass!.data!.specializations!) {
        if (spec.name != null && spec.name!.isNotEmpty) {
          specializations.add(spec.name!);
        }
      }
    }

    // If no specializations are available, use the department name
    if (specializations.isEmpty &&
        detailController.doctorDetailsClass?.data?.departmentName != null) {
      specializations.add(
        detailController.doctorDetailsClass!.data!.departmentName!,
      );
    }

    // If still empty, use fallbacks
    if (specializations.isEmpty) {
      specializations = ["ADHD", "Family therapy", "Anxiety", "Depression"];
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: specializations
            .map((spec) => _buildSpecializationChip(spec))
            .toList(),
      ),
    );
  }

  Widget _buildSpecializationChip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const CustomTextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildAppointmentsTab(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Available dates section
            Text(
              'available_dates'.tr,
              style: const CustomTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Obx(
              () => detailController.availableDates.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: detailController.availableDates
                            .asMap()
                            .entries
                            .map((entry) {
                              int index = entry.key;
                              DateTime date = entry.value;

                              DateTime today =
                                  TimezoneService.getCurrentMauritaniaTime();
                              bool isToday =
                                  date.year == today.year &&
                                  date.month == today.month &&
                                  date.day == today.day;
                              bool isSelected =
                                  detailController.selectedDateIndex.value ==
                                  index;

                              String dayName = detailController.getDayName(
                                date.weekday,
                              );
                              String dayNumber = date.day.toString();
                              String monthName = DateFormat('MMM').format(date);

                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () =>
                                      detailController.selectDate(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF3961F1)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF3961F1)
                                            : Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF3961F1,
                                                ).withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          dayName.tr,
                                          style: CustomTextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[600],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dayNumber,
                                          style: CustomTextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          monthName,
                                          style: CustomTextStyle(
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.8)
                                                : Colors.grey[500],
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        if (isToday)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white.withOpacity(
                                                      0.2,
                                                    )
                                                  : const Color(
                                                      0xFF3961F1,
                                                    ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'today'.tr,
                                              style: CustomTextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xFF3961F1),
                                                fontSize: 8,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    )
                  : detailController.isLoadingAvailability.value
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'no_available_dates'.tr,
                          style: const CustomTextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 32),

            // Time slots section
            Obx(
              () => detailController.availableDates.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'available_time_slots'.tr,
                              style: const CustomTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (detailController.selectedDateIndex.value <
                                detailController.availableDates.length)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF3961F1,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  DateFormat('MMM dd').format(
                                    detailController
                                        .availableDates[detailController
                                        .selectedDateIndex
                                        .value],
                                  ),
                                  style: const CustomTextStyle(
                                    color: Color(0xFF3961F1),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        detailController.isLoadingTimeSlots.value
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : detailController.currentTimeSlots.isNotEmpty
                            ? _buildTimeSlotGrid()
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'no_time_slots_available'.tr,
                                        style: CustomTextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                        const SizedBox(height: 24),

                        // Book now button
                        if (detailController.currentTimeSlots.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  detailController.processPayment(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3961F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'make_an_appointment'.tr,
                                style: const CustomTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';
    final needsConversion = TimezoneService.needsTimezoneConversion();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: needsConversion ? 2.2 : 2.5, // Adjust for extra text
      ),
      itemCount: detailController.currentTimeSlots.length,
      itemBuilder: (context, index) {
        String timeSlot = detailController.currentTimeSlots[index];

        // Format time display with timezone support
        String displayTime = timeSlot;
        String? timezoneHint;
        
        try {
          // Parse the time slot
          DateTime time = DateFormat('HH:mm').parse(timeSlot);
          
          // Create DateTime for today with this time (in Mauritania timezone)
          final selectedDate = detailController.selectedDateIndex.value < 
              detailController.availableDates.length
              ? detailController.availableDates[detailController.selectedDateIndex.value]
              : DateTime.now();
          
          final doctorDateTime = DateTime.utc(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            time.hour,
            time.minute,
          );

          if (isArabic) {
            if (needsConversion) {
              // Show doctor time + patient local time
              displayTime = TimezoneService.formatAppointmentTimeWithOffset(doctorDateTime);
              // Extract just the main time for compact display
              final parts = displayTime.split('(');
              if (parts.length > 1) {
                displayTime = parts[0].trim();
                timezoneHint = '(${parts[1]}';
              }
            } else {
              // Just format the time in Arabic
              int hour = time.hour;
              if (hour >= 12) {
                displayTime = '${DateFormat('h:mm').format(time)} مساءً';
              } else {
                displayTime = '${DateFormat('h:mm').format(time)} صباحاً';
              }
            }
          } else {
            if (needsConversion) {
              // Format for English with timezone
              displayTime = TimezoneService.formatAppointmentTimeWithOffset(doctorDateTime);
            } else {
              displayTime = DateFormat('h:mm a').format(time);
            }
          }
        } catch (e) {
          // Keep original format if parsing fails
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => detailController.processPayment(),
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: timezoneHint != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayTime,
                            style: const CustomTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timezoneHint,
                            style: CustomTextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Text(
                        displayTime,
                        style: const CustomTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return Obx(() {
      if (detailController.isLoadingReviews.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final avgRating = detailController.averageRating.value;
      final totalReviews = detailController.totalReviews.value;
      final reviews = detailController.reviews;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall rating section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const CustomTextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3366FF),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < avgRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews ${'reviews'.tr}',
                      style: CustomTextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingBar(5, _getRatingPercentage(5)),
                      _buildRatingBar(4, _getRatingPercentage(4)),
                      _buildRatingBar(3, _getRatingPercentage(3)),
                      _buildRatingBar(2, _getRatingPercentage(2)),
                      _buildRatingBar(1, _getRatingPercentage(1)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Reviews list
          if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'no_reviews_yet'.tr,
                      style: CustomTextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...reviews.map((review) => _buildReviewItem(review)).toList(),
        ],
      );
    });
  }

  double _getRatingPercentage(int stars) {
    final reviews = detailController.reviews;
    if (reviews.isEmpty) return 0;
    final count = reviews.where((r) => r.rating == stars).length;
    return count / reviews.length;
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: CustomTextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(dynamic review) {
    final patientName = review.patientName;
    String maskedName;

    if (patientName == null || patientName.isEmpty) {
      maskedName = 'anonymous'.tr;
    } else {
      // Show first 2 characters + max 4 asterisks
      final asteriskCount = (patientName.length - 2).clamp(1, 4);
      maskedName =
          '${patientName.substring(0, 2).toUpperCase()}${'*' * asteriskCount}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 20,
                backgroundImage: review.patientImage != null
                    ? NetworkImage(review.patientImage!)
                    : null,
                child: review.patientImage == null
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maskedName,
                      style: const CustomTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review.timeAgo,
                          style: CustomTextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const CustomTextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
