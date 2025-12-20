import 'package:videocalling/core/config/app_imports.dart';
class ManageHolidayScreen extends GetView<HolidayManageController> {
  final HolidayManageController manageController =
      Get.put(HolidayManageController());

   ManageHolidayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          manageController.holidayId == 0
              ? 'add_holiday'.tr
              : 'update_holiday'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 16),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selection Section
                  Text(
                    'select_date'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'select_date_desc'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Date Range Picker
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.05),
                      //     blurRadius: 10,
                      //     offset: Offset(0, 2),
                      //   ),
                      // ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SfDateRangePicker(
                            controller: manageController.controller,
                            enablePastDates: false,
                            maxDate:
                                DateTime.now().add(const Duration(days: 30)),
                            view: DateRangePickerView.month,
                            selectionMode: DateRangePickerSelectionMode.range,
                            onSelectionChanged:
                                (dateRangePickerSelectionChangedArgs) {},
                            initialSelectedRange:
                                manageController.controller.selectedRange,
                            rangeSelectionColor:
                                const Color(0xFF3366FF).withOpacity(0.2),
                            todayHighlightColor: const Color(0xFF3366FF),
                            selectionColor: const Color(0xFF3366FF),
                            monthCellStyle: DateRangePickerMonthCellStyle(
                              textStyle: const TextStyle(color: Colors.black87),
                              disabledDatesTextStyle:
                                  TextStyle(color: Colors.grey[400]),
                            ),
                            monthViewSettings: const DateRangePickerMonthViewSettings(
                              viewHeaderStyle: DateRangePickerViewHeaderStyle(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description Input
                  Text(
                    'description'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: manageController.isDescriptionError.value
                            ? Colors.red
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: manageController.descController,
                      decoration: InputDecoration(
                        hintText: 'enter_description'.tr,
                        contentPadding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      onChanged: (text) {
                        if (text.isEmpty) {
                          manageController.isDescriptionError.value = false;
                        }
                      },
                    ),
                  ),

                  if (manageController.isDescriptionError.value)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'common_textfield_error'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Remove Button (when editing)
                  if (manageController.holidayId != 0)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          manageController.removeHoliday();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                        child: Text(
                          'remove'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),

                  if (manageController.holidayId != 0) const SizedBox(height: 16),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.focusScope?.unfocus();
                        manageController.addHoliday();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3366FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        manageController.holidayId == 0
                            ? 'add_holiday'.tr
                            : 'update_holiday'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          )),
    );
  }
}
