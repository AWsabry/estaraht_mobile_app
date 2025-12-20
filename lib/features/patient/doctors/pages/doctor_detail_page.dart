import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/core/utils/logger.dart';
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
            style: TextStyle(fontFamily: AppFontStyleTextStrings.regular),
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
                        labelStyle: TextStyle(
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
              right: 24,
              top: 126,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCard(
                    svgIcon: AppImages.workIcon,
                    iconColor: AppColors.color1,
                    title:
                        "${detailController.doctorDetailsClass?.data?.yearsOfExp} ${"years".tr}",
                    subtitle: "of_experience".tr,
                  ),
                  const SizedBox(height: 8),
                  _buildStatCard(
                    svgIcon: AppImages.reviewsIcon,
                    iconColor: AppColors.color1,
                    title:
                        detailController.doctorDetailsClass?.data?.avgratting
                            ?.toStringAsFixed(1) ??
                        '4.8',
                    subtitle: "reviews".tr,
                  ),
                  const SizedBox(height: 8),
                  _buildStatCard(
                    svgIcon: AppImages.groupOfPeaple,
                    iconColor: AppColors.color1,
                    title:
                        detailController.doctorDetailsClass?.data?.nbSessions
                            ?.toString() ??
                        '2000',
                    subtitle: "patients".tr,
                  ),
                ],
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
                              horizontal: 12,
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
                                  detailController
                                          .doctorDetailsClass
                                          ?.data
                                          ?.departmentName ??
                                      "Psychologist",
                                  style: TextStyle(
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
                                  style: const TextStyle(
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
                            'book_now'.tr,
                            style: const TextStyle(
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
      width: 128,
      height: 52,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(svgIcon, color: iconColor, height: 20, width: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
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
          style: const TextStyle(
            fontSize: 14,
            height: 1.2, // Specific line height for Arabic
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 32),

        // Stats grid rows
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                padding: const EdgeInsets.all(16),
                child: _buildStatItem(
                  icon: Icons.video_call,
                  title: "number_of_sessions".tr,
                  value: "2000_sessions",
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
                  icon: Icons.attach_money,
                  title: "session_price".tr,
                  value: "price_value",
                ),
              ),
            ),
          ],
        ),
        // Second row of stats
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                padding: const EdgeInsets.all(16),
                child: _buildStatItem(
                  icon: Icons.star,
                  title: "reviews".tr,
                  value: "700_reviews",
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
                  value: "50_min",
                ),
              ),
            ),
          ],
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.2, // Specified line height for Arabic
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.tr,
          style: const TextStyle(
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
        style: const TextStyle(fontSize: 14, color: Colors.black87),
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
              style: const TextStyle(
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

                              DateTime today = DateTime.now();
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
                                          style: TextStyle(
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
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          monthName,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.8)
                                                : Colors.grey[500],
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        if (isToday)
                                          Container(
                                            margin: const EdgeInsets.only(top: 4),
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
                                              style: TextStyle(
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
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                              style: const TextStyle(
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
                                  color: const Color(0xFF3961F1).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  DateFormat('MMM dd').format(
                                    detailController
                                        .availableDates[detailController
                                        .selectedDateIndex
                                        .value],
                                  ),
                                  style: const TextStyle(
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
                                        style: TextStyle(
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'make_an_appointment'.tr,
                                style: const TextStyle(
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: detailController.currentTimeSlots.length,
      itemBuilder: (context, index) {
        String timeSlot = detailController.currentTimeSlots[index];

        // Format time display
        String displayTime = timeSlot;
        try {
          DateTime time = DateFormat('HH:mm').parse(timeSlot);
          if (isArabic) {
            int hour = time.hour;
            if (hour >= 12) {
              displayTime = '${DateFormat('h:mm').format(time)} مساءً';
            } else {
              displayTime = '${DateFormat('h:mm').format(time)} صباحاً';
            }
          } else {
            displayTime = DateFormat('h:mm a').format(time);
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
                child: Text(
                  displayTime,
                  style: const TextStyle(
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
    const rating = 5;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rating section
        Row(
          children: [
            for (int i = 1; i <= 5; i++)
              Icon(
                i <= rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 24,
              ),
            const SizedBox(width: 16),
            Text(
              "write_comment".tr,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Overall rating
        Row(
          children: [
            const Icon(Icons.star, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            const Text(
              "4.8",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "from_patients".tr.replaceAll('{count}', '700'),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ],
        ),

        const Divider(height: 32),

        // Reviews
        _buildReviewItem("M********", "review_example_text".tr),

        const Divider(height: 16),

        _buildReviewItem("M********", "review_example_text".tr),
      ],
    );
  }

  Widget _buildReviewItem(String name, String comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundColor: Colors.grey[300], radius: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                comment,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
