import 'package:videocalling/core/config/app_imports.dart';

class UserHomeScreen extends GetView<UserHomeController> {
  final UserHomeController homeController = Get.put(UserHomeController());

  UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Container(),
        backgroundColor: AppColors.transparentColor,
        toolbarHeight: kToolbarHeight + 285,
        flexibleSpace: CustomHomeScreenAppBar(
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
            await Get.toNamed(Routes.indemandDoctorScreen);
            homeController.newData.clear();
            homeController.textController.clear();
            homeController.searchKeyword.value = "";
            homeController.update();
          },
        ),
      ),
      body: PageView(
        controller: homeController.pageController,

        physics: const NeverScrollableScrollPhysics(),
        children: [
          Column(
            children: [
              Obx(() {
                if (homeController.isErrorInLoadDoctorData.value) {
                  return Container();
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48, 0, 48, 16),
                        child: Row(
                          children: [
                            Text(
                              'most_in_demand_doctors'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            // Commented TextButton can be restored here if needed
                          ],
                        ),
                      ),

                      // HORIZONTAL DOCTOR CARDS
                      SizedBox(
                        height: 270,
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
                            padding: const EdgeInsets.only(left: 46, right: 32),
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
                                  width: 240,
                                  // Fixed width for card
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[600]!,
                                    ),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Sessions count with icon
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          16,
                                          24,
                                          0,
                                        ),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              AppImages.videoCallIcon,
                                              color: AppColors.color1,
                                              width: 24,
                                              height: 24,
                                            ),
                                            const Text(
                                              //"${data.sessionsCount} ",
                                              "",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "sessions".tr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          12,
                                          24,
                                          12,
                                        ),
                                        child: Row(
                                          children: [
                                            Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: CachedNetworkImage(
                                                    imageUrl: data.image ?? "",
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => Container(
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColorLight,
                                                          child: Center(
                                                            child: Image.asset(
                                                              AppImages
                                                                  .tab3dUnselect,
                                                              height: 50,
                                                              width: 50,
                                                            ),
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (context, url, err) =>
                                                            Container(
                                                              color: Colors
                                                                  .grey[200],
                                                              child: const Icon(
                                                                Icons.person,
                                                                size: 25,
                                                              ),
                                                            ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
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
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppFontStyleTextStrings
                                                              .medium,
                                                      color: AppColors.BLACK,
                                                      fontSize: 16,
                                                      height: 1.2,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  Text(
                                                    data.specialization ?? "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: AppColors.BLACK,
                                                      fontSize: 12,
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
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          0,
                                          0,
                                          16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'specialization'.tr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                height: 1.2,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: [
                                                _buildSpecialtyChip(
                                                  data.specialization ?? "",
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Bio: ${data.bio ?? ""}",
                                              maxLines: 3,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                height: 1.2,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Action buttons
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          26,
                                          0,
                                          26,
                                          8,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          height: 1,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          0,
                                          24,
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
                                                          20,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 1,
                                                      ),
                                                ),
                                                child: Text(
                                                  'profile'.tr,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    height: 1.2,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Book now button
                                            Expanded(
                                              flex: 2, // Takes 2/5 of the space
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Get.focusScope?.unfocus();
                                                  await Get.toNamed(
                                                    Routes
                                                        .makeAppointmentScreen,
                                                    arguments: {
                                                      'id': "${data.doctorId}",
                                                      'name':
                                                          data.fullName ?? "",
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
                                                          20,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                      ),
                                                ),
                                                child: Text(
                                                  'book_now'.tr,
                                                  style: const TextStyle(
                                                    fontSize: 11,
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
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build specialty chips
  Widget _buildSpecialtyChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[600]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          height: 1.3,
          color: Colors.black87,
        ),
      ),
    );
  }
}
