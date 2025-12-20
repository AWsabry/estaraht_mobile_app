import 'package:flutter/material.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/availability/controllers/availability_controller.dart';

class DAvailabilityManagementScreen
    extends GetView<DAvailabilityManagementController> {
  const DAvailabilityManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'available_management'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.availabilities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isErrorInLoading.value) {
          return _buildErrorState();
        }

        return Column(
          children: [
            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3366FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF3366FF).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF3366FF)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'select_available_time_slots'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Day tabs and time slots
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final dayNumber = index + 1;
                  final dayName = controller.dayNames[index];

                  return _buildDayCard(dayNumber, dayName, isArabic);
                },
              ),
            ),

            // Save button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveAvailabilities(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3366FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'save_availabilities'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDayCard(int dayNumber, String dayName, bool isArabic) {
    return Obx(() {
      final totalSlots = controller.getTotalSlotsForDay(dayNumber);
      final isExpanded =
          controller.selectedSlots[dayNumber]?.isNotEmpty ?? false;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: totalSlots > 0
                ? const Color(0xFF3366FF).withOpacity(0.3)
                : Colors.grey[300]!,
          ),
        ),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isExpanded,
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: totalSlots > 0
                        ? const Color(0xFF3366FF).withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: totalSlots > 0
                            ? const Color(0xFF3366FF)
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (totalSlots > 0)
                        Text(
                          '$totalSlots ${'time_slots_selected'.tr}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: totalSlots > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3366FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      totalSlots.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const Icon(Icons.keyboard_arrow_down),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                controller.selectAllSlotsForDay(dayNumber),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF3366FF)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              'select_all'.tr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF3366FF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                controller.clearSlotsForDay(dayNumber),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              'clear_all'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Time slots grid
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.availableTimeSlots.map((timeSlot) {
                        return Obx(() {
                          final isSelected = controller.isTimeSlotSelected(
                            dayNumber,
                            timeSlot,
                          );
                          return InkWell(
                            onTap: () =>
                                controller.toggleTimeSlot(dayNumber, timeSlot),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF3366FF)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF3366FF)
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                timeSlot,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'unable_to_load_data'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchAvailabilities(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3366FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'retry'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
