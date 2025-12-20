import 'package:videocalling/core/config/app_imports.dart';

class StepThreeDetailsScreen extends GetView<StepThreeDetailsController> {
  final StepThreeDetailsController threeDetailsController =
      Get.find<StepThreeDetailsController>();

  StepThreeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: threeDetailsController.onWillPopScope,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'profile_str'.tr,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          leading: IconButton(
            padding: const EdgeInsets.only(left: 16),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(
          () => threeDetailsController.isErrorInLoading.value
              ? _buildErrorView()
              : threeDetailsController.isDataLoaded.value
              ? _buildMainContent(context)
              : _buildLoadingView(),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Icon(Icons.error_outline_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'unable_to_load_data'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              threeDetailsController.isErrorInLoading.value = false;
              threeDetailsController.onInit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.color1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildLoadingView() {
    return SizedBox(
      height: MediaQuery.of(Get.context!).size.height - 50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.color1),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'loading_schedule'.tr,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    // Full height with bottom padding to ensure button visibility
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'add_time_slot'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: AppColors.color1,
                        elevation: 2,
                        onPressed: () {
                          threeDetailsController.addValues();
                          threeDetailsController.totalCards.value =
                              threeDetailsController.totalCards.value + 1;
                          threeDetailsController.update();
                        },
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: threeDetailsController.slotsData.length,
                    itemBuilder: (context, i) {
                      return Visibility(
                        visible:
                            threeDetailsController.id ==
                            threeDetailsController.slotsData[i].dayId
                                .toString(),
                        child: _buildTimeSlotCard(context, i),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: 100,
                ), // Extra space at the bottom for scrolling
              ],
            ),
          ),
        ),

        // Fixed bottom section with add button and save button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add button row

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _validateAndSave();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'save'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _validateAndSave() {
    bool hasEmptyFields = false;

    // Check for empty time slots
    for (int i = 0; i < threeDetailsController.slotsData.length; i++) {
      if (threeDetailsController.id ==
          threeDetailsController.slotsData[i].dayId.toString()) {
        String startTime =
            threeDetailsController.textEditingControllerStartTime[i].text;
        String endTime =
            threeDetailsController.textEditingControllerEndTime[i].text;

        // Validate start time
        if (startTime.isEmpty || startTime == "--:--" || startTime.length < 5) {
          threeDetailsController.isError[i] = true.obs;
          threeDetailsController.errorMessage[i] = 'start_time_required'.tr;
          hasEmptyFields = true;
        }
        // Validate end time
        else if (endTime.isEmpty || endTime == "--:--" || endTime.length < 5) {
          threeDetailsController.isError[i] = true.obs;
          threeDetailsController.errorMessage[i] = 'end_time_required'.tr;
          hasEmptyFields = true;
        }
      }
    }

    // If all fields are filled, proceed with saving
    if (!hasEmptyFields) {
      threeDetailsController.generateJson();
    } else {
      // Show feedback to user about empty fields
    }
  }

  Widget _buildTimeSlotCard(BuildContext context, int i) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: threeDetailsController.isError[i].value
              ? Colors.red
              : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: const [
          // BoxShadow(
          //   color: Colors.black.withOpacity(0.05),
          //   blurRadius: 10,
          //   offset: Offset(0, 2),
          // ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildTimeField(
                  context,
                  i,
                  'start_time'.tr,
                  threeDetailsController.textEditingControllerStartTime[i],
                  true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  context,
                  i,
                  'end_time'.tr,
                  threeDetailsController.textEditingControllerEndTime[i],
                  false,
                ),
              ),
              const SizedBox(width: 12),
              _buildDeleteButton(i),
            ],
          ),
          const SizedBox(height: 8),

          // Error message
          Obx(
            () => threeDetailsController.isError[i].value
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            threeDetailsController.errorMessage[i],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 12),

          // Interval dropdown
          _buildIntervalDropdown(context, i),

          const SizedBox(height: 16),

          // Time slots grid
          _buildTimeSlotsGrid(context, i),
        ],
      ),
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    int index,
    String label,
    TextEditingController controller,
    bool isStartTime,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      threeDetailsController.isError[index].value &&
                          ((isStartTime &&
                                  (controller.text.isEmpty ||
                                      controller.text == "--:--")) ||
                              (!isStartTime &&
                                  (controller.text.isEmpty ||
                                      controller.text == "--:--")))
                      ? Colors.red
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "--:--",
                  contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  border: InputBorder.none,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.access_time,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.allow(RegExp("[0-9:]")),
                  MaskedTextInputFormatter(mask: '00:00', separator: ':'),
                ],
                onTap: () {
                  threeDetailsController.selectTime(index, isStartTime);
                },
                onChanged: (val) {
                  if (isStartTime) {
                    threeDetailsController.startTime[index] = val;
                  } else {
                    threeDetailsController.endTime[index] = val;
                  }
                  // Clear error when user starts typing
                  if (val.isNotEmpty && val != "--:--") {
                    threeDetailsController.isError[index] = false.obs;
                  }
                  threeDetailsController.selectedvValue[index] = null;
                },
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    threeDetailsController.selectTime(index, isStartTime);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeleteButton(int index) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            threeDetailsController.slotsData.removeAt(index);
            threeDetailsController.errorMessage.removeAt(index);
            threeDetailsController.startTime.removeAt(index);
            threeDetailsController.endTime.removeAt(index);
            threeDetailsController.slotsList.removeAt(index);
            threeDetailsController.selectedvValue.removeAt(index);
            threeDetailsController.textEditingControllerStartTime.removeAt(
              index,
            );
            threeDetailsController.textEditingControllerEndTime.removeAt(index);
            threeDetailsController.isError.removeAt(index);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalDropdown(BuildContext context, int index) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            hint: Text(
              "select_interval".tr,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            items: threeDetailsController.slotsInterval.map((x) {
              return DropdownMenuItem(
                value: x,
                child: Text(
                  x,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              );
            }).toList(),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            onChanged: (val) {
              threeDetailsController.selectedvValue[index] = val.toString();
              threeDetailsController.slotsDistribution(
                threeDetailsController.startTime[index],
                threeDetailsController.endTime[index],
                int.parse(val.toString().substring(0, 2)),
                index,
              );
              threeDetailsController.update();
            },
            value: threeDetailsController.selectedvValue[index],
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotsGrid(BuildContext context, int index) {
    return Obx(
      () => threeDetailsController.slotsList[index].isEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Text(
                'no_slots_generated'.tr,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            )
          : GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2,
              children: List.generate(
                threeDetailsController.slotsList[index].length,
                (slotIndex) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.color1.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        threeDetailsController
                                .slotsList[index][slotIndex]
                                .slot ??
                            "",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
