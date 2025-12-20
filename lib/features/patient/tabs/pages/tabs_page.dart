import 'package:videocalling/core/config/app_imports.dart';

class PatientTabsScreen extends GetView<PatientTabController> {
  const PatientTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PatientTabController tabController = Get.put(PatientTabController());

    // Check if there's an initial tab index from navigation arguments
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('initialTab')) {
      final initialTab = args['initialTab'] as int?;
      if (initialTab != null) {
        tabController.changeTabIndex(initialTab);
      }
    }

    return Scaffold(
      body: Obx(() => tabController.getPage(tabController.index.value)),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(color: Colors.white),
          // height: 80,
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
                      const SizedBox(height: 6), // Add 6px spacing
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
                      const SizedBox(height: 6), // Add 6px spacing
                    ],
                  ),
                  label: 'doctors'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    children: [
                      _buildNavIcon(
                        isSelected: tabController.index.value == 2,
                        selectedIcon: AppImages.tab3uSelect,
                        unselectedIcon: AppImages.tab3uUnselect,
                      ),
                      const SizedBox(height: 6), // Add 6px spacing
                    ],
                  ),
                  label: 'consultations'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    children: [
                      _buildNavIcon(
                        isSelected: tabController.index.value == 3,
                        selectedIcon: AppImages.tab4Select,
                        unselectedIcon: AppImages.tab4Unselect,
                      ),
                      const SizedBox(height: 6), // Add 6px spacing
                    ],
                  ),
                  label: 'settings'.tr,
                ),
              ],
              selectedLabelStyle: TextStyle(
                color: AppColors.BLACK,
                fontFamily: AppFontStyleTextStrings.regular,
                fontSize: 12,
              ),
              type: BottomNavigationBarType.fixed,
              unselectedLabelStyle: TextStyle(
                fontFamily: AppFontStyleTextStrings.regular,
                color: AppColors.BLACK,
                fontSize: 12,
              ),
              // Set to zero to avoid default padding
              iconSize: 0,
              unselectedItemColor: Colors.grey.shade700,
              selectedItemColor: AppColors.BLACK,
              onTap: (i) {
                if (i == 0) {
                  loggerNoStack.d('Loading UserHomeController');
                  Get.lazyPut<UserHomeController>(() => UserHomeController());
                } else if (i == 2) {
                  loggerNoStack.d('Loading UAllAppointmentsController');
                  Get.lazyPut<UAllAppointmentsController>(
                    () => UAllAppointmentsController(),
                  );
                } else if (i == 1) {
                  loggerNoStack.d('Loading DoctorSearchController');
                  Get.lazyPut<IndemandDoctorController>(
                    () => IndemandDoctorController(),
                  );
                } else if (i == 3) {
                  loggerNoStack.d('Loading PatientMoreScreenController');
                  Get.lazyPut<PatientMoreScreenController>(
                    () => PatientMoreScreenController(),
                  );
                }
                if (tabController.index.value == 0) {
                  Get.delete<UserHomeController>();
                } else if (tabController.index.value == 1) {
                  Get.delete<IndemandDoctorController>();
                } else if (tabController.index.value == 2) {
                  Get.delete<UAllAppointmentsController>();
                } else if (tabController.index.value == 3) {
                  Get.delete<PatientMoreScreenController>();
                }

                tabController.index.value = i;
              },
              currentIndex: tabController.index.value,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build navigation icons with rounded background when selected
  Widget _buildNavIcon({
    required bool isSelected,
    required String selectedIcon,
    required String unselectedIcon,
  }) {
    if (isSelected) {
      return Container(
        height: 32,
        width: 64,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.color1,
          borderRadius: BorderRadius.circular(42),
        ),
        child: SvgPicture.asset(
          color: Colors.white,
          selectedIcon,
          height: 20,
          width: 20,
        ),
      );
    } else {
      return SvgPicture.asset(unselectedIcon, height: 24, width: 24);
    }
  }
}
