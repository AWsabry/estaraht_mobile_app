import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/appointments/models/make_appointment_class.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class MakeAppointment extends GetView<MakeAppointmentController> {
  final MakeAppointmentController makeAppointmentController = Get.put(
    MakeAppointmentController(),
  );

  MakeAppointment({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: CustomAppBar(title: 'book_a_session'.tr),
        leading: Container(),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.h),
          child: Container(
            height: 60,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: Colors.black,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'book_a_session'.tr,
                    style: const CustomTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(
        () => Stack(
          children: [
            // title back button
            SingleChildScrollView(
              controller: makeAppointmentController.scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor info card
                  _buildDoctorInfoCard(isArabic),

                  // Timezone info banner (if user is in different timezone)
                  if (TimezoneService.needsTimezoneConversion())
                    _buildTimezoneInfoBanner(isArabic),

                  // Session duration selection
                  //_buildSessionDurationSection(isArabic),

                  // Date selection
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                      right: 40,
                      top: 20,
                      bottom: 12,
                    ),
                    child: Text(
                      'select_date'.tr,
                      style: const CustomTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                      right: 40,
                      top: 2,
                      bottom: 12,
                    ),
                    child: Obx(
                      () => Row(
                        children: [
                          const Icon(Icons.arrow_forward),
                          const SizedBox(width: 8),

                          /// Show actual available date range instead of fixed 7 days
                          Text(
                            makeAppointmentController.availableDates.isNotEmpty
                                ? '${DateFormat('dd MMM').format(makeAppointmentController.availableDates.first)} - ${DateFormat('dd MMM').format(makeAppointmentController.availableDates.last)}'
                                : 'no_available_dates'.tr,
                            style: const CustomTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Date selection row
                  Container(
                    height: 110,
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                    child: Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            makeAppointmentController.availableDates.length,
                        itemBuilder: (context, i) {
                          if (makeAppointmentController
                              .availableDates
                              .isEmpty) {
                            return Center(
                              child: Text(
                                'No available dates'.tr,
                                style: const CustomTextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }

                          DateTime currentDate =
                              makeAppointmentController.availableDates[i];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () {
                                if (makeAppointmentController
                                        .previousSelectedIndex
                                        .value ==
                                    i) {
                                  return;
                                }

                                // Fix: Check if selected date is actually today, not just index 0
                                DateTime selectedDate =
                                    makeAppointmentController.availableDates[i];
                                DateTime today =
                                    TimezoneService.getCurrentMauritaniaTime();
                                bool isSelectedDateToday =
                                    selectedDate.year == today.year &&
                                    selectedDate.month == today.month &&
                                    selectedDate.day == today.day;

                                makeAppointmentController.isToday.value =
                                    isSelectedDateToday;

                                makeAppointmentController
                                        .isSelected[makeAppointmentController
                                            .previousSelectedIndex
                                            .value]
                                        .value =
                                    false;
                                makeAppointmentController.isSelected[i].value =
                                    !makeAppointmentController
                                        .isSelected[i]
                                        .value;
                                makeAppointmentController
                                        .previousSelectedIndex
                                        .value =
                                    i;

                                // Use new Supabase-based availability check with the selected available date

                                makeAppointmentController
                                    .checkAvailabilityFromSupabase(
                                      selectedDate,
                                      false,
                                      i: i,
                                    );
                              },
                              borderRadius: BorderRadius.circular(32),
                              child: Container(
                                width: 58,
                                height: 62,
                                decoration: BoxDecoration(
                                  color:
                                      makeAppointmentController
                                          .isSelected[i]
                                          .value
                                      ? const Color(0xFF3366FF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color:
                                        makeAppointmentController
                                            .isSelected[i]
                                            .value
                                        ? const Color(0xFF3366FF)
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      makeAppointmentController.days[currentDate
                                          .weekday],
                                      style: CustomTextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            makeAppointmentController
                                                .isSelected[i]
                                                .value
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      currentDate.day.toString(),
                                      style: CustomTextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            makeAppointmentController
                                                .isSelected[i]
                                                .value
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Available time slots
                  // Available time slots
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                      right: 40,
                      top: 20,
                      bottom: 8,
                    ),
                    child: Text(
                      'choose_the_time'.tr,
                      style: const CustomTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  // Time slot content based on loading state
                  !makeAppointmentController.isLoading.value ||
                          !makeAppointmentController.isLoading1.value
                      ? _buildTimeSlotContent()
                      : const Center(child: CircularProgressIndicator()),

                  // // Bottom spacing
                  // const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(34),
                    child: ElevatedButton(
                      onPressed: () => makeAppointmentController.processPayment(
                        context: context,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3366FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'make_an_appointment'.tr,
                        style: const CustomTextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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
  }

  /// Build timezone information banner for users in different timezone
  Widget _buildTimezoneInfoBanner(bool isArabic) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.w, vertical: 8.h),
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF3366FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3366FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFF3366FF),
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              TimezoneService.getTimezoneDifferenceMessage(),
              style: CustomTextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF3366FF),
                fontWeight: FontWeight.w500,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoCard(bool isArabic) {
    return Container(
      margin: EdgeInsets.only(left: 32.w, right: 32.w, top: 10.h, bottom: 12.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor image
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              makeAppointmentController.image,
              width: 50.w,
              height: 50.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50.w,
                height: 50.h,
                color: Colors.grey[200],
                child: Icon(Icons.person, size: 40.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Doctor info
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and specialist section
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        makeAppointmentController.name.isEmpty
                            ? makeAppointmentController.name
                            : makeAppointmentController.name[0].toUpperCase() +
                                  makeAppointmentController.name.substring(1),
                        style: CustomTextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'specialist'.tr,
                        style: CustomTextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Icons section
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppImages.videoCallIcon,
                            width: 16.w,
                            height: 16.h,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              'sessions'.tr,
                              style: CustomTextStyle(
                                fontSize: 10.sp,
                                height: 1.3,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppImages.appointmentTime,
                            width: 16.w,
                            height: 16.h,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              '45 ${"min".tr}',
                              style: CustomTextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotContent() {
    if (makeAppointmentController.isNoSlot.value) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'no_slot_available'.tr,
            style: CustomTextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
        ),
      );
    } else if (makeAppointmentController.isChecked.value) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    } else if (makeAppointmentController.checkHolidayFuture.value) {
      return _buildDoctorOnLeaveMessage();
    } else {
      return _buildAvailableTimeSlots();
    }
  }

  Widget _buildDoctorOnLeaveMessage() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          'doc_on_leave_title'.tr,
          style: const CustomTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
          child: Text(
            'doc_on_leave_description'.trParams({
              'date': makeAppointmentController.date,
            }),
            style: CustomTextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableTimeSlots() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Morning/Evening slot selection
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount:
                  makeAppointmentController.makeAppointmentClass!.data!.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      makeAppointmentController
                              .selectedSlot[makeAppointmentController
                                  .previousSelectedSlot
                                  .value]
                              .value =
                          false;
                      makeAppointmentController.selectedSlot[i].value =
                          !makeAppointmentController.selectedSlot[i].value;
                      makeAppointmentController.previousSelectedSlot.value = i;
                      makeAppointmentController.initializeTimeSlots(i);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 60,
                      // margin: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                      decoration: BoxDecoration(
                        color: makeAppointmentController.selectedSlot[i].value
                            ? const Color(0xFF3366FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: makeAppointmentController.selectedSlot[i].value
                              ? const Color(0xFF3366FF)
                              : Colors.grey.shade300,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 32,
                            width: 32,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  makeAppointmentController
                                      .selectedSlot[i]
                                      .value
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getSlotIcon(i),
                              size: 20,
                              color:
                                  makeAppointmentController
                                      .selectedSlot[i]
                                      .value
                                  ? const Color(0xFF3366FF)
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            makeAppointmentController
                                    .makeAppointmentClass!
                                    .data![i]
                                    .title ??
                                "",
                            style: CustomTextStyle(
                              color:
                                  makeAppointmentController
                                      .selectedSlot[i]
                                      .value
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          // Time slots grid
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.1,
              physics: const ClampingScrollPhysics(),
              children: _buildTimeSlotItems(),
            ),
          ),

          // Phone and Description fields
          /* Container(
              padding: const EdgeInsets.fromLTRB(40, 16, 40, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phone number field
                  Text(
                    'phone_number'.tr,
                    style: CustomTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: makeAppointmentController.textEditingController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      errorText: makeAppointmentController.isPhoneError.value
                          ? 'mobile_error_2'
                              .trParams({'length': PHONE_LENGTH.toString()})
                          : null,
                      hintText: 'enter_phone'.tr,
                      prefixIcon:
                          Icon(Icons.phone, size: 18, color: Colors.grey),
                    ),
                    onChanged: (val) {
                      makeAppointmentController.isPhoneError.value = false;
                    },
                  ),

                  SizedBox(height: 16),

                  // Description field
                  Text(
                    'description'.tr,
                    style: CustomTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller:
                        makeAppointmentController.textEditingController1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      errorText:
                          makeAppointmentController.isDescriptionEmpty.value
                              ? 'common_textfield_error'.tr
                              : null,
                      hintText: 'description_hint'.tr,
                    ),
                    onChanged: (val) {
                      makeAppointmentController.isDescriptionEmpty.value =
                          false;
                      makeAppointmentController.description.value = val;
                    },
                  ),
                ],
              ),
            )*/
        ],
      ),
    );
  }

  IconData _getSlotIcon(int index) {
    if (makeAppointmentController.makeAppointmentClass?.data == null ||
        index >= makeAppointmentController.makeAppointmentClass!.data!.length) {
      return Icons.wb_sunny;
    }

    String? title = makeAppointmentController
        .makeAppointmentClass!
        .data![index]
        .title
        ?.toLowerCase();

    if (title == 'morning') {
      return Icons.wb_sunny; // أيقونة الشمس للصباح
    } else if (title == 'evening') {
      return Icons.nightlight_round; // أيقونة القمر للمساء
    }

    // Default fallback
    return Icons.wb_sunny;
  }

  List<Widget> _buildTimeSlotItems() {
    List<Widget> timeSlots = [];
    final languageController = Get.find<LanguageController>();
    final bool isArabic = languageController.currentLanguage.value == 'ar';

    if (makeAppointmentController.makeAppointmentClass != null) {
      List<Slottime> list =
          makeAppointmentController
              .makeAppointmentClass!
              .data![makeAppointmentController.currentSlotsIndex.value]
              .slottime ??
          [];

      for (int i = 0; i < list.length; i++) {
        bool isBooked = list[i].isBook == "1";

        // Fix: Handle 24-hour format from Supabase (HH:mm) instead of 12-hour format (hh:mm a)
        bool isPastTime = false;
        if (makeAppointmentController.isToday.value) {
          try {
            String timeSlot = list[i].name ?? "";
            // Parse current time and slot time in 24-hour format
            DateTime now = TimezoneService.getCurrentMauritaniaTime();
            DateTime slotDateTime = DateFormat(
              'yyyy-MM-dd HH:mm',
            ).parse('${DateFormat('yyyy-MM-dd').format(now)} $timeSlot');
            isPastTime = now.isAfter(slotDateTime);
          } catch (e) {
            // If parsing fails, assume slot is not in the past
            isPastTime = false;
          }
        }

        // Format time with Arabic AM/PM if needed, or convert to 12-hour format
        String displayTime = list[i].name ?? "";
        if (displayTime.isNotEmpty) {
          try {
            // Parse 24-hour time and convert to 12-hour format if needed
            DateTime time = DateFormat('HH:mm').parse(displayTime);

            if (isArabic) {
              // For Arabic, show 24-hour format with Arabic AM/PM
              int hour = time.hour;
              if (hour >= 12) {
                displayTime = '${DateFormat('h:mm').format(time)} مساءً';
              } else {
                displayTime = '${DateFormat('h:mm').format(time)} صباحاً';
              }
            } else {
              // For English, convert to 12-hour format with AM/PM
              displayTime = DateFormat('h:mm a').format(time);
            }
          } catch (e) {
            // If parsing fails, keep original format
            displayTime = list[i].name ?? "";
          }
        }

        timeSlots.add(
          InkWell(
            onTap: () {
              if (isBooked) {
                Fluttertoast.showToast(
                  msg: 'no_slot_available'.tr,
                  timeInSecForIosWeb: 2,
                );
              } else if (isPastTime) {
                Fluttertoast.showToast(
                  msg: 'past_time_slots'.tr,
                  timeInSecForIosWeb: 2,
                );
              } else {
                makeAppointmentController.slotId.value = list[i].id.toString();
                makeAppointmentController.slotName.value = list[i].name!;

                if (makeAppointmentController.previousSelectedTimingSlot.value <
                    list.length) {
                  makeAppointmentController
                          .selectedTimingSlot[makeAppointmentController
                              .previousSelectedTimingSlot
                              .value]
                          .value =
                      false;
                }

                makeAppointmentController.selectedTimingSlot[i].value =
                    !makeAppointmentController.selectedTimingSlot[i].value;
                makeAppointmentController.previousSelectedTimingSlot.value = i;
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: (isBooked || isPastTime)
                    ? Colors.grey[100]
                    : makeAppointmentController.selectedTimingSlot[i].value
                    ? const Color(0xFF3366FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (isBooked || isPastTime)
                      ? Colors.grey[300]!
                      : makeAppointmentController.selectedTimingSlot[i].value
                      ? const Color(0xFF3366FF)
                      : Colors.grey[300]!,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  displayTime,
                  style: CustomTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: (isBooked || isPastTime)
                        ? Colors.grey[400]
                        : makeAppointmentController.selectedTimingSlot[i].value
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return timeSlots;
  }
}
