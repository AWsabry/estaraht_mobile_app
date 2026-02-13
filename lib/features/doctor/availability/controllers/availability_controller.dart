import 'package:videocalling/core/config/app_imports.dart';

import '../models/availability_model.dart';

class DAvailabilityManagementController extends GetxController {
  final supabase = supabaseHelper;
  final firebase = firebaseHelper;

  RxBool isLoading = false.obs;
  RxBool isErrorInLoading = false.obs;
  RxList<AvailabilityModel> availabilities = <AvailabilityModel>[].obs;

  // Days of the week (1 = Monday, 7 = Sunday)
  final List<String> dayNames = [
    'day_full_1',
    'day_full_2',
    'day_full_3',
    'day_full_4',
    'day_full_5',
    'day_full_6',
    'day_full_7',
  ];

  // Time slots available for selection
  final List<String> availableTimeSlots = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
  ];

  // Track selected time slots for each day
  RxMap<int, RxList<String>> selectedSlots = <int, RxList<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize selected slots for each day
    for (int i = 1; i <= 7; i++) {
      selectedSlots[i] = <String>[].obs;
    }
    fetchAvailabilities();
  }

  Future<void> fetchAvailabilities() async {
    try {
      isLoading.value = true;
      isErrorInLoading.value = false;

      final doctorId = firebase.currentUserId;
      if (doctorId == null) {
        print('❌ No authenticated user found');
        isErrorInLoading.value = true;
        return;
      }

      print('🔍 Fetching availabilities for doctor: $doctorId');

      final response = await supabase
          .from('availabilities')
          .select()
          .eq('doctor_id', doctorId)
          .order('day_number', ascending: true);

      availabilities.clear();
      for (var item in response) {
        final availability = AvailabilityModel.fromJson(item);
        availabilities.add(availability);

        // Populate selected slots: DB and UI both use 1=Mon,...,7=Sun
        selectedSlots[availability.dayNumber]?.value = List<String>.from(
          availability.timeSlots,
        );
      }
      print('✅ Loaded ${availabilities.length} availability records');
    } catch (e) {
      print('❌ Error fetching availabilities: $e');
      isErrorInLoading.value = true;
      customDialog(s1: 'error'.tr, s2: 'unable_to_load_data'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleTimeSlot(int dayNumber, String timeSlot) {
    final slots = selectedSlots[dayNumber];
    if (slots == null) return;

    if (slots.contains(timeSlot)) {
      slots.remove(timeSlot);
    } else {
      slots.add(timeSlot);
      // Sort slots
      slots.sort();
    }
  }

  bool isTimeSlotSelected(int dayNumber, String timeSlot) {
    return selectedSlots[dayNumber]?.contains(timeSlot) ?? false;
  }

  Future<void> saveAvailabilities() async {
    try {
      isLoading.value = true;

      final doctorId = firebase.currentUserId;
      if (doctorId == null) {
        customDialog(s1: 'error'.tr, s2: 'not_authenticated'.tr);
        return;
      }

      customDialog1(s1: 'saving'.tr, s2: 'please_wait'.tr);

      // Delete existing availabilities for this doctor
      await supabase.from('availabilities').delete().eq('doctor_id', doctorId);

      // Insert new availabilities
      final List<Map<String, dynamic>> dataToInsert = [];

      for (int dayNumber = 1; dayNumber <= 7; dayNumber++) {
        final slots = selectedSlots[dayNumber]?.toList() ?? [];
        if (slots.isNotEmpty) {
          // DB format: 1=Monday, ..., 7=Sunday (same as UI)
          dataToInsert.add({
            'doctor_id': doctorId,
            'day_number': dayNumber,
            'time_slots': slots,
            'is_available': true,
          });
        }
      }

      if (dataToInsert.isNotEmpty) {
        await supabase.from('availabilities').insert(dataToInsert);
        loggerNoStack.f(
          '✅ Successfully saved ${dataToInsert.length} availability records',
        );
        // print('✅ Successfully saved ${dataToInsert.length} availability records');
      }

      Get.back(); // Close loading dialog

      customDialog(
        s1: 'success'.tr,
        s2: 'availabilities_saved_successfully'.tr,
      );

      // Refresh data
      await fetchAvailabilities();
    } catch (e) {
      Get.back(); // Close loading dialog
      loggerNoStack.e('Error saving availabilities', error: e);
      print('❌ Error saving availabilities: $e');
      customDialog(s1: 'error'.tr, s2: 'unable_to_save_data'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  int getTotalSlotsForDay(int dayNumber) {
    return selectedSlots[dayNumber]?.length ?? 0;
  }

  void clearAllSlots() {
    for (int i = 1; i <= 7; i++) {
      selectedSlots[i]?.clear();
    }
  }

  void selectAllSlotsForDay(int dayNumber) {
    selectedSlots[dayNumber]?.value = List<String>.from(availableTimeSlots);
  }

  void clearSlotsForDay(int dayNumber) {
    selectedSlots[dayNumber]?.clear();
  }
}
