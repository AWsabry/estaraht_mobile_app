import 'package:videocalling/core/config/app_imports.dart';

class DoctorTabsScreen extends GetView<DoctorTabController> {
  const DoctorTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DoctorTabController tabController = Get.put(DoctorTabController());
    return WillPopScope(
      onWillPop: tabController.willPopScope,
      child: Scaffold(
        body: Obx(() => tabController.getPage(tabController.index.value)),
        bottomNavigationBar: Obx(
          () => Container(
            decoration: const BoxDecoration(color: Colors.white),
            //   height: 80,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(0),
                topLeft: Radius.circular(0),
              ),
              child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: Column(
                      children: [
                        _buildNavIcon(
                          isSelected: tabController.index.value == 0,
                          selectedIcon: AppImages.tab1Select,
                          unselectedIcon: AppImages.tab1Unselect,
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                    label: 'home'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Column(
                      children: [
                        _buildNavIcon(
                          isSelected: tabController.index.value == 1,
                          selectedIcon: AppImages.tab2Select,
                          unselectedIcon: AppImages.tab2Unselect,
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                    label: 'consultations'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Column(
                      children: [
                        _buildNavIcon(
                          isSelected: tabController.index.value == 2,
                          selectedIcon: AppImages.tab3dSelect,
                          unselectedIcon: AppImages.tab3dUnselect,
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                    label: 'financial'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Column(
                      children: [
                        _buildNavIcon(
                          isSelected: tabController.index.value == 3,
                          selectedIcon: AppImages.tab4Select,
                          unselectedIcon: AppImages.tab4Unselect,
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                    label: 'settings'.tr,
                  ),
                ],
                selectedLabelStyle: TextStyle(
                  color: AppColors.BLACK,
                  fontFamily: AppFontStyleTextStrings.regular,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                type: BottomNavigationBarType.fixed,
                unselectedLabelStyle: TextStyle(
                  fontFamily: AppFontStyleTextStrings.regular,
                  fontWeight: FontWeight.w500,
                  color: AppColors.BLACK,
                  fontSize: 10,
                ),
                iconSize: 0, // Set to zero to avoid default padding
                unselectedItemColor: Colors.grey.shade700,
                selectedItemColor: AppColors.BLACK,
                onTap: (i) {
                  if (tabController.index.value == i) return;
                  if (i == 0) {
                    Get.lazyPut<DoctorDashboardController>(
                      () => DoctorDashboardController(),
                    );
                  } else if (i == 1) {
                    Get.lazyPut<DoctorPastAppointmentsController>(
                      () => DoctorPastAppointmentsController(),
                    );
                  } else if (i == 2) {
                    Get.lazyPut<DoctorProfileController>(
                      () => DoctorProfileController(),
                    );
                  } else if (i == 3) {
                    Get.lazyPut<DMoreInfoController>(
                      () => DMoreInfoController(),
                    );
                  } else if (i == 4) {
                    Get.lazyPut<DoctorChatListController>(
                      () => DoctorChatListController(),
                    );
                  }

                  if (tabController.index.value == 0) {
                    Get.delete<DoctorDashboardController>();
                  } else if (tabController.index.value == 1) {
                    Get.delete<DoctorPastAppointmentsController>();
                  } else if (tabController.index.value == 2) {
                    Get.delete<DoctorProfileController>();
                  } else if (tabController.index.value == 4) {
                    Get.delete<DMoreInfoController>();
                  } else if (tabController.index.value == 3) {
                    Get.delete<DoctorChatListController>();
                  }

                  tabController.index.value = i;
                  tabController.update();
                },
                currentIndex: tabController.index.value,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon({
    required bool isSelected,
    required String selectedIcon,
    required String unselectedIcon,
  }) {
    if (isSelected) {
      return Container(
        height: 32,
        width: 54,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.color1,
          borderRadius: BorderRadius.circular(42),
        ),
        child: SvgPicture.asset(
          selectedIcon,
          height: 24,
          width: 24,
          color: Colors.white,
        ),
      );
    } else {
      return SvgPicture.asset(unselectedIcon, height: 24, width: 24);
    }
  }
}
