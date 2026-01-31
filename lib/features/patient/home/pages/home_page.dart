import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';

class UserHomeScreen extends GetView<UserHomeController> {
  final UserHomeController homeController = Get.put(UserHomeController());

  UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHomeScreenAppBar(
              title: 'welcome_str'.tr,
              title1:
                  StorageService.readData(key: LocalStorageKeys.name) ??
                  'user_str'.tr,
              textController: homeController.textController,
              valueColor:
                  homeController.isSearching.value &&
                      !homeController.isSearchDataLoaded.value
                  ? AlwaysStoppedAnimation(Theme.of(context).hintColor)
                  : AlwaysStoppedAnimation(AppColors.transparentColor),
              onChanged: (val) {
                homeController.searchKeyword.value = val;
                homeController.onChanged(val);
              },
              onSubmitted: (val) {
                homeController.searchKeyword.value = val;
              },
              onPressed: () async {
                Get.focusScope?.unfocus();
                await Get.toNamed(
                  Routes.indemandDoctorScreen,
                  arguments: {'openKeyboard': true},
                );
                homeController.newData.clear();
                homeController.textController.clear();
                homeController.searchKeyword.value = "";
                homeController.update();
              },
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(45.w, 0, 45.w, 10),
              child: Text(
                'most_in_demand_doctors'.tr,
                style: CustomTextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Obx(() {
              if (homeController.isErrorInLoadDoctorData.value) {
                return Container();
              } else {
                return Column(
                  children: [
                    SizedBox(
                      height: 820.h * 0.3412,
                      child: Obx(() {
                        // Show a loader when data is loading
                        if (homeController.list2.isEmpty &&
                            !homeController.isErrorInLoadDoctorData.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF3961F1),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.only(left: 46.w, right: 32.w),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: homeController.list2.length,
                          itemBuilder: (BuildContext ctx, index) {
                            var data = homeController.list2[index];
                            return InkWell(
                              onTap: () async {
                                loggerNoStack.i(
                                  'Navigating to DoctorDetailScreen with id: ${data.doctorId}',
                                );
                                Get.focusScope?.unfocus();

                                await Get.toNamed(
                                  Routes.doctorDetailScreen,
                                  arguments: {'id': data.doctorId.toString()},
                                );
                                Get.delete<DoctorDetailController>();
                              },
                              child: Container(
                                width: 240.w,
                                // Fixed width for card
                                margin: EdgeInsets.only(right: 16.w),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[600]!),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Sessions count with icon
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        24.w,
                                        16.h,
                                        24.w,
                                        0,
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppImages.videoCallIcon,
                                            color: AppColors.color1,
                                            width: 24.w,
                                            height: 24.h,
                                          ),
                                          Text(
                                            //"${data.sessionsCount} ",
                                            "",
                                            style: CustomTextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            "sessions".tr,
                                            style: CustomTextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        24.w,
                                        12.h,
                                        24.w,
                                        12.h,
                                      ),
                                      child: Row(
                                        children: [
                                          Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50.r),
                                              child: SizedBox(
                                                width: 50.w,
                                                height: 50.h,
                                                child: CachedNetworkImage(
                                                  imageUrl: data.image ?? "",
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColorLight,
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 25,
                                                          ),
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        err,
                                                      ) => Container(
                                                        color: Colors.grey[200],
                                                        child: const Icon(
                                                          Icons.person,
                                                          size: 25,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data.name ?? "",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: CustomTextStyle(
                                                    fontFamily:
                                                        AppFontStyleTextStrings
                                                            .medium,
                                                    color: AppColors.BLACK,
                                                    fontSize: 16.sp,
                                                    height: 1.2,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  data.specialization ?? "",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: CustomTextStyle(
                                                    color: AppColors.BLACK,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // const SizedBox(height: 10),
                                    // Specialties
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        24.w,
                                        0,
                                        0,
                                        16.h,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: 16.w,
                                          top: 8.0.h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'specialization'.tr,
                                              style: CustomTextStyle(
                                                fontSize: 12.sp,
                                                height: 1.2,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 9.h),
                                            Wrap(
                                              spacing: 4.w,
                                              runSpacing: 4.h,
                                              children: [
                                                _buildSpecialtyChip(
                                                  data.specialization ?? "",
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              "${'bio'.tr}: ${data.bio ?? ""}",
                                              maxLines: 1,
                                              style: CustomTextStyle(
                                                fontSize: 11.sp,
                                                height: 1.2,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Action buttons
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        26.w,
                                        0,
                                        26.w,
                                        8.h,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        height: 1,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        24.w,
                                        0,
                                        24.w,
                                        0,
                                      ),
                                      child: Row(
                                        children: [
                                          // Profile button
                                          Expanded(
                                            flex: 3, // Takes 3/5 of the space
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                loggerNoStack.i(
                                                  'Navigating to DoctorDetailScreen with id: ${data.id}',
                                                );
                                                Get.focusScope?.unfocus();
                                                await Get.toNamed(
                                                  Routes.doctorDetailScreen,
                                                  arguments: {
                                                    'id': data.doctorId
                                                        .toString(),
                                                  },
                                                );
                                                Get.delete<
                                                  DoctorDetailController
                                                >();
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: Colors.grey[600]!,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20.r,
                                                      ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 1,
                                                    ),
                                              ),
                                              child: Text(
                                                'profile'.tr,
                                                style: CustomTextStyle(
                                                  fontSize: 11.sp,
                                                  height: 1.2,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          // Book now button
                                          Expanded(
                                            flex: 2, // Takes 2/5 of the space
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                Get.focusScope?.unfocus();
                                                await Get.toNamed(
                                                  Routes.makeAppointmentScreen,
                                                  arguments: {
                                                    'id': "${data.doctorId}",
                                                    'name': data.fullName ?? "",
                                                    'image': data.image ?? "",
                                                    'consultationFee':
                                                        "${data.bookingPrice ?? 0}",
                                                  },
                                                );
                                                Get.delete<
                                                  DoctorDetailController
                                                >();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF3961F1,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20.r,
                                                      ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                              ),
                                              child: Text(
                                                'book'.tr,
                                                style: CustomTextStyle(
                                                  fontSize: 11.sp,
                                                  height: 1.2,
                                                  color: Colors.white,
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
                            );
                          },
                        );
                      }),
                    ),
                    // Loading indicator
                  ],
                );
              }
            }),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  // Helper method to build specialty chips
  Widget _buildSpecialtyChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[600]!),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label.isEmpty ? "N/A" : label,
        style: CustomTextStyle(
          fontSize: 10.sp,
          height: 1.3,
          color: Colors.black87,
        ),
      ),
    );
  }
}
