import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/profile/models/review_model.dart';
import 'package:videocalling/features/doctor/profile/pages/edit_profile_page.dart';

class DoctorProfileView extends GetView<DoctorProfileViewController> {
  final DoctorProfileViewController detailController = Get.put(
    DoctorProfileViewController(),
  );
  final DAvailabilityManagementController availabilityController = Get.put(
    DAvailabilityManagementController(),
  );

  DoctorProfileView({super.key});

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
                imageUrl:
                    detailController.doctorDetailsClass?.data?.image ?? "",
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).primaryColorLight,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, err) => Container(
                  color: Theme.of(context).primaryColorLight,
                  child: Center(
                    child: Image.asset(
                      AppImages.getDoctorPlaceholder(
                        detailController.doctorDetailsClass?.data?.gender,
                      ),
                    ),
                  ),
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
                        "${detailController.doctorDetailsClass?.data?.yearsOfExp ?? 0} ${"years".tr}",
                    subtitle: "of_experience".tr,
                  ),
                  const SizedBox(height: 8),
                  _buildStatCard(
                    svgIcon: AppImages.reviewsIcon,
                    iconColor: AppColors.color1,
                    title:
                        detailController.doctorDetailsClass?.data?.avgratting
                            ?.toStringAsFixed(1) ??
                        '0.0',
                    subtitle: "reviews".tr,
                  ),
                  const SizedBox(height: 8),
                  _buildStatCard(
                    svgIcon: AppImages.groupOfPeaple,
                    iconColor: AppColors.color1,
                    title:
                        detailController
                                .doctorDetailsClass
                                ?.data
                                ?.numbPatients !=
                            null
                        ? "+${detailController.doctorDetailsClass!.data!.numbPatients}"
                        : "+2500",
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
                    Expanded(
                      child: Container(
                        height: 52,
                        width: double
                            .infinity, // Make inner container also take full width
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              detailController.doctorDetailsClass?.data?.name ??
                                  "Name",
                              style: const TextStyle(
                                height: 1.2,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Psychologist".tr,
                              style: const TextStyle(
                                height: 1.2,
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => DoctorProfile());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6F6F6),
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.black87,
                          size: 18,
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
                  value:
                      "${detailController.doctorDetailsClass?.data?.nbSessions ?? 0} ${'sessions'.tr}",
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Expanded(
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(8),
            //       border: Border.all(color: Colors.grey[200]!),
            //     ),
            //     padding: const EdgeInsets.all(16),
            //     child: _buildStatItem(
            //       icon: Icons.attach_money,
            //       title: "session_price".tr,
            //       value:
            //           detailController
            //                   .doctorDetailsClass
            //                   ?.data
            //                   ?.consultationFee !=
            //               null
            //           ? '\$${detailController.doctorDetailsClass!.data!.consultationFee}'
            //           : '\$10',
            //     ),
            //   ),
            // ),
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
                  value:
                      "${detailController.doctorDetailsClass?.data?.totalReview ?? 0} ${'reviews'.tr}",
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
                  value: "45_min".tr,
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
          value,
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
        detailController.doctorDetailsClass?.data?.specializations != null) {
      specializations.add(
        detailController.doctorDetailsClass!.data!.specializations!.toString(),
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
    return Obx(() {
      if (availabilityController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (availabilityController.isErrorInLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'unable_to_load_data'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      // Get today's date
      final now = DateTime.now();
      final dates = List.generate(7, (index) => now.add(Duration(days: index)));

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Date selector row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: dates
                      .map(
                        (date) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildDateCard(
                            _getDayName(date.weekday),
                            date.day.toString(),
                            false,
                            date.weekday,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 32),

              // Display time slots for each day
              ...List.generate(7, (index) {
                final dayNumber = index + 1;
                final slots =
                    availabilityController.selectedSlots[dayNumber] ?? [];

                if (slots.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        availabilityController.dayNames[index].tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slots
                          .map((slot) => _buildTimeSlotChip(slot))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),

              if (availabilityController.availabilities.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    "no_available_dates".tr,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  String _getDayName(int weekday) {
    final days = [
      'mon'.tr,
      'tue'.tr,
      'wed'.tr,
      'thu'.tr,
      'fri'.tr,
      'sat'.tr,
      'sun'.tr,
    ];
    return days[weekday - 1].tr;
  }

  Widget _buildTimeSlotChip(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.color1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.color1.withOpacity(0.3)),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.color1,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateCard(
    String day,
    String date,
    bool isSelected,
    int dayNumber,
  ) {
    final slots = availabilityController.selectedSlots[dayNumber] ?? [];
    final hasAvailability = slots.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3961F1) : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? const Color(0xFF3961F1)
              : hasAvailability
              ? AppColors.color1.withOpacity(0.5)
              : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasAvailability)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.color1,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return Obx(() {
      if (detailController.isLoadingReviews.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (detailController.isErrorInLoadingReviews.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'unable_to_load_reviews'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      if (detailController.reviews.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'no_reviews_yet'.tr,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall rating section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.color1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detailController.averageRating.value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < detailController.averageRating.value.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '(${detailController.totalReviews.value} ${"reviews".tr})',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Reviews list
          ...detailController.reviews.map((ReviewModel review) {
            return Column(
              children: [
                _buildReviewItem(
                  review.patientName ?? 'Anonymous',
                  review.comment ?? '',
                  review.ratingValue,
                  review.formattedDate,
                  review.patientImage ?? '',
                ),
                const Divider(height: 24),
              ],
            );
          }).toList(),
        ],
      );
    });
  }

  Widget _buildReviewItem(
    String name,
    String comment,
    double rating,
    String date,
    String? imageUrl,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Patient avatar
        ClipOval(
          child: imageUrl != null && imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.grey[600]),
                  ),
                )
              : Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.grey[600]),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Star rating
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                comment,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
