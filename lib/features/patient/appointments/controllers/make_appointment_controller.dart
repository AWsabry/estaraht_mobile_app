import 'package:http/http.dart' as http;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/appointments/models/make_appointment_class.dart';
import 'package:videocalling/features/video_call/call_manager.dart';
import 'package:videocalling/shared/models/availability_model.dart';
import 'package:videocalling/shared/models/country_pricing_model.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';
import 'package:videocalling/shared/services/pricing_service.dart';
import 'package:videocalling/shared/services/others/booking_email_service.dart';

class MakeAppointmentController extends GetxController {
  String id = Get.arguments['id'];
  String name = Get.arguments['name'];
  String image = Get.arguments['image'];
  String consultationFee = Get.arguments['consultationFee'] ?? '0';

  RxString dynamicPrice = "0".obs;
  RxString dynamicCurrency = "USD".obs;
  Rx<CountryPricing?> doctorPricing = Rx<CountryPricing?>(null);

  DateTime dateTime = TimezoneService.getCurrentMauritaniaTime();

  RxBool isToday = true.obs;

  MakeAppointmentClass1? makeAppointmentClass;
  RxBool isLoading = true.obs;
  RxBool isLoading1 = true.obs;
  RxBool istimingSlotLoading = true.obs;
  RxBool isNoSlot = false.obs;
  RxBool isNoTimingSlot = false.obs;
  RxString description = "".obs;
  String userId = "";
  String doctorId = "";
  String date = "";
  RxString slotId = "".obs;
  RxString slotName = "".obs;
  RxBool isPhoneError = false.obs;
  ScrollController scrollController = ScrollController();
  RxBool isAppointmentMadeSuccessfully = false.obs;
  RxString AppointmentId = "".obs;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textEditingController1 = TextEditingController();

  Map<String, dynamic>? paymentIntent;

  // Duration selection
  RxString selectedDuration = "45".obs;

  // Supabase client
  final supabase = supabaseHelper.client;

  /// Doctor's timezone offset in hours (UTC). Null until fetched; defaults to 0 (Mauritania) for existing doctors.
  final Rx<int?> doctorTimezoneOffsetHours = Rx<int?>(null);

  // Availability data from Supabase
  RxList<AvailabilityModel> weeklyAvailability = <AvailabilityModel>[].obs;
  RxBool isLoadingAvailability = false.obs;

  // Available dates list - only dates when doctor is available
  RxList<DateTime> availableDates = <DateTime>[].obs;

  // Maximum days to look ahead for available dates
  final int maxDaysAhead = 15;

  List<String> days = [
    'day1'.tr,
    'day2'.tr,
    'day3'.tr,
    'day4'.tr,
    'day5'.tr,
    'day6'.tr,
    'day7'.tr,
    'day1'.tr,
  ];

  List<String> months = [
    'month1'.tr,
    'month2'.tr,
    'month3'.tr,
    'month4'.tr,
    'month5'.tr,
    'month6'.tr,
    'month7'.tr,
    'month8'.tr,
    'month9'.tr,
    'month10'.tr,
    'month11'.tr,
    'month12'.tr,
  ];

  List<RxBool> isSelected = <RxBool>[];
  RxList<RxBool> selectedSlot = <RxBool>[].obs;
  List<RxBool> selectedTimingSlot = <RxBool>[];
  RxInt previousSelectedIndex = 0.obs;
  RxInt previousSelectedSlot = 0.obs;
  RxInt previousSelectedTimingSlot = 0.obs;
  RxInt currentSlotsIndex = 0.obs;
  RxBool isDescriptionEmpty = false.obs;
  RxBool isChecked = true.obs;
  RxBool checkHolidayFuture = false.obs;

  /// Fetch available time slots from Supabase for a specific doctor
  /// This replaces the old API-based availability check
  Future<void> getAvailableDatesFromSupabase() async {
    try {
      loggerNoStack.t('Getting time slots and availability from Supabase');
      isLoadingAvailability.value = true;

      loggerNoStack.w('Doctor ID being used for query: "$doctorId"');
      loggerNoStack.w(
        'Using hardcoded test ID: "36d5fd4a-15dd-4bb8-a6d1-f90af81b13f4"',
      );

      // TODO: Change back to doctorId once working
      final testDoctorId = doctorId;

      // First, let's test if we can query the table at all
      try {
        final allRecords = await supabase
            .from('availabilities')
            .select('id, doctor_id');
        loggerNoStack.w(
          'Total records in availabilities table: ${allRecords.length}',
        );
        if (allRecords.isNotEmpty) {
          loggerNoStack.w(
            'First record doctor_id: ${allRecords[0]['doctor_id']}',
          );
          loggerNoStack.w(
            'Doctor ID type: ${allRecords[0]['doctor_id'].runtimeType}',
          );
        }
      } catch (e) {
        loggerNoStack.e(
          'Error querying all records (RLS might be blocking): $e',
        );
      }

      // Try different query approaches
      loggerNoStack.d('Attempting query with exact UUID match...');

      // Get weekly schedule for the doctor
      final response = await supabase
          .from('availabilities')
          .select()
          .eq('doctor_id', doctorId)
          .eq('is_available', true)
          .order('day_number', ascending: true);

      loggerNoStack.d('Response type: ${response.runtimeType}');
      loggerNoStack.d('Response length: ${(response as List).length}');

      if ((response as List).isEmpty) {
        // Try without is_available filter
        loggerNoStack.w(
          'No results with is_available=true, trying without filter...',
        );
        final responseNoFilter = await supabase
            .from('availabilities')
            .select()
            .eq('doctor_id', testDoctorId);
        loggerNoStack.w(
          'Without is_available filter: ${responseNoFilter.length} records',
        );
      }

      loggerNoStack.d('Raw response: $response');

      // Parse the response into AvailabilityModel objects
      weeklyAvailability.value = (response as List)
          .map((json) => AvailabilityModel.fromJson(json))
          .toList();

      loggerNoStack.i(
        'Loaded ${weeklyAvailability.length} availability records',
      );
      isLoadingAvailability.value = false;
    } catch (e) {
      loggerNoStack.e('Error fetching availability from Supabase: $e');
      isLoadingAvailability.value = false;
      weeklyAvailability.clear();
    }
  }

  /// Get available time slots for a specific day
  /// dayNumber: 0=Sunday, 1=Monday, 2=Tuesday, etc.
  Future<List<String>> getTimeSlotsForDay(int dayNumber) async {
    try {
      loggerNoStack.t(
        'Getting time slots for day $dayNumber for doctor $doctorId',
      );

      final response = await supabase
          .from('availabilities')
          .select('time_slots')
          .eq('doctor_id', doctorId)
          .eq('day_number', dayNumber)
          .eq('is_available', true)
          .maybeSingle();

      loggerNoStack.d('Time slots response for day $dayNumber: $response');

      if (response != null && response['time_slots'] != null) {
        List<String> slots = List<String>.from(response['time_slots']);
        loggerNoStack.i(
          'Found ${slots.length} time slots for day $dayNumber: $slots',
        );
        return slots;
      }
      loggerNoStack.w('No time slots found for day $dayNumber');
      return [];
    } catch (e) {
      loggerNoStack.e('Error fetching time slots for day $dayNumber: $e');
      return [];
    }
  }

  /// Get all time slots for a specific date with booking status
  /// This method calculates the day of week from the date and fetches slots
  Future<List<Map<String, dynamic>>> getTimeSlotsWithStatusForDate(
    DateTime selectedDate,
  ) async {
    try {
      // Convert Dart weekday (1=Monday, 7=Sunday) to database format (0=Sunday, 1=Monday, etc.)
      // Dart: Monday=1, Tuesday=2, ..., Sunday=7
      // DB: Sunday=0, Monday=1, Tuesday=2, ..., Saturday=6
      int dayNumber = selectedDate.weekday == 7 ? 0 : selectedDate.weekday;

      loggerNoStack.t(
        'Getting time slots for date ${TimezoneService.toIsoDateString(selectedDate)}, Dart weekday: ${selectedDate.weekday}, DB day number: $dayNumber',
      );

      List<String> allSlots = await getTimeSlotsForDay(dayNumber);

      if (allSlots.isEmpty) {
        return [];
      }

      // Get booked slots for this date
      String dateString = TimezoneService.toIsoDateString(selectedDate);
      Set<String> bookedTimes = await getBookedSlots(dateString);

      // Create list with booking status for each slot
      List<Map<String, dynamic>> slotsWithStatus = allSlots.map((slot) {
        bool isBooked = bookedTimes.contains(slot);
        return {'time': slot, 'is_booked': isBooked};
      }).toList();

      loggerNoStack.i(
        'Total slots: ${allSlots.length}, Booked: ${bookedTimes.length}',
      );
      return slotsWithStatus;
    } catch (e) {
      loggerNoStack.e('Error getting time slots for date: $e');
      return [];
    }
  }

  /// Get booked time slots for a specific date
  Future<Set<String>> getBookedSlots(String date) async {
    try {
      loggerNoStack.t(
        'Checking booked slots for date $date, doctorId: $doctorId',
      );

      final bookedSlots = await supabase
          .from('bookings')
          .select('booking_time, status')
          .eq('doctor_id', doctorId)
          .eq('booking_date', date);

      loggerNoStack.d(
        'Booked slots response (${bookedSlots.length} records): $bookedSlots',
      );

      if (bookedSlots.isEmpty) {
        loggerNoStack.i('No bookings found for this date');
        return {};
      }

      // Extract booked time slots and filter by status
      Set<String> bookedTimes = {};
      for (var booking in bookedSlots) {
        // Only exclude confirmed, pending, and accepted bookings
        String status = booking['status']?.toString().toLowerCase() ?? '';
        if ((status == 'confirmed' ||
                status == 'pending' ||
                status == 'accepted') &&
            booking['booking_time'] != null) {
          // booking_time might be in format "09:00:00" or "09:00"
          String timeStr = booking['booking_time'].toString();
          // Normalize to HH:mm format
          if (timeStr.contains(':')) {
            List<String> parts = timeStr.split(':');
            timeStr = '${parts[0]}:${parts[1]}';
          }
          bookedTimes.add(timeStr);
        }
      }

      loggerNoStack.i('Booked times: $bookedTimes');
      return bookedTimes;
    } catch (e) {
      loggerNoStack.e('Error getting booked slots: $e');
      // If error occurs, return empty set to avoid blocking users
      return {};
    }
  }

  /// Check if doctor is available on a specific date
  Future<bool> isDoctorAvailableOnDate(DateTime selectedDate) async {
    try {
      // Convert Dart weekday to database format
      int dayNumber = selectedDate.weekday == 7 ? 0 : selectedDate.weekday;

      loggerNoStack.t(
        'Checking availability for weekday ${selectedDate.weekday}, converted to day_number $dayNumber',
      );

      final response = await supabase
          .from('availabilities')
          .select('is_available')
          .eq('doctor_id', doctorId)
          .eq('day_number', dayNumber)
          .maybeSingle();

      loggerNoStack.d('Availability response: $response');

      bool isAvailable = response != null && response['is_available'] == true;
      loggerNoStack.i('Doctor available on day $dayNumber: $isAvailable');

      return isAvailable;
    } catch (e) {
      loggerNoStack.e('Error checking doctor availability: $e');
      return false;
    }
  }

  /// Fetch doctor's timezone offset from database for timezone-aware messaging
  Future<void> _fetchDoctorTimezone() async {
    try {
      final response = await supabase
          .from('doctors')
          .select('timezone_offset_hours')
          .eq('doctor_id', doctorId)
          .maybeSingle();
      if (response != null && response['timezone_offset_hours'] != null) {
        doctorTimezoneOffsetHours.value =
            (response['timezone_offset_hours'] as num).toInt();
      } else {
        doctorTimezoneOffsetHours.value = 0; // Default to Mauritania
      }
    } catch (e) {
      loggerNoStack.w('Could not fetch doctor timezone: $e');
      doctorTimezoneOffsetHours.value = 0;
    }
  }

  initialize() async {
    textEditingController.text =
        StorageService.readData(key: LocalStorageKeys.phone) ?? "";
    userId = StorageService.readData(key: LocalStorageKeys.userId) ?? "";
    doctorId = id;

    // Fetch doctor's timezone for timezone-aware messaging
    await _fetchDoctorTimezone();

    // Load weekly availability from Supabase
    await getAvailableDatesFromSupabase();

    // Generate available dates based on doctor's schedule
    await generateAvailableDates();

    // Check availability for the first available date (if any)
    if (availableDates.isNotEmpty) {
      await checkAvailabilityFromSupabase(availableDates[0], true, i: 0);
    } else {
      // No available dates found
      isNoSlot.value = true;
      isLoading.value = false;
      loggerNoStack.w('No available dates found for doctor');
    }
  }

  /// New method to check availability using Supabase instead of old API
  Future<void> checkAvailabilityFromSupabase(
    DateTime selectedDate,
    bool isFirst, {
    required int i,
  }) async {
    try {
      isLoading.value = true;
      isChecked.value = true;
      isNoSlot.value = false;
      date = TimezoneService.toIsoDateString(selectedDate);

      // Update isToday based on selected date (using doctor's timezone)
      final doctorOffset = doctorTimezoneOffsetHours.value ?? 0;
      DateTime today = TimezoneService.getCurrentTimeInDoctorTimezone(
        doctorOffset,
      );
      String todayStr = TimezoneService.toIsoDateString(today);
      bool wasTodayBefore = isToday.value;
      isToday.value = (date == todayStr);

      loggerNoStack.i(
        'Date comparison - Today: $todayStr, Selected: $date, isToday changed from $wasTodayBefore to ${isToday.value}',
      );

      loggerNoStack.t(
        'Checking availability for date: $date, weekday: ${selectedDate.weekday}, isToday: ${isToday.value}',
      );

      // Check if doctor is available on this date
      bool isAvailable = await isDoctorAvailableOnDate(selectedDate);

      loggerNoStack.d('Is available: $isAvailable');

      if (isAvailable) {
        // Get time slots with booking status for this date
        List<Map<String, dynamic>> timeSlotsWithStatus =
            await getTimeSlotsWithStatusForDate(selectedDate);

        loggerNoStack.d('Time slots found: ${timeSlotsWithStatus.length}');

        if (timeSlotsWithStatus.isNotEmpty) {
          // Convert to the format expected by the UI
          selectedSlot.clear();
          slotName.value = "";
          slotId.value = "";
          currentSlotsIndex.value = 0;
          previousSelectedTimingSlot.value = 0;

          // Split into Morning/Evening slots with booking status
          List<Map<String, dynamic>> morningSlots = [];
          List<Map<String, dynamic>> eveningSlots = [];

          for (var slotData in timeSlotsWithStatus) {
            String timeSlot = slotData['time'];
            bool isBooked = slotData['is_booked'];

            try {
              // Parse hour from time slot (e.g., "10:00" -> 10)
              String hourStr = timeSlot.split(':')[0].trim();
              int hour = int.parse(hourStr);

              Map<String, dynamic> slotInfo = {
                'id': timeSlot.hashCode,
                'name': timeSlot,
                'is_book': isBooked ? '1' : '0',
              };

              if (hour < 12) {
                morningSlots.add(slotInfo);
              } else {
                eveningSlots.add(slotInfo);
              }
            } catch (e) {
              loggerNoStack.e('Error parsing time slot "$timeSlot": $e');
              // If parsing fails, default to evening
              eveningSlots.add({
                'id': timeSlot.hashCode,
                'name': timeSlot,
                'is_book': isBooked ? '1' : '0',
              });
            }
          }

          loggerNoStack.d(
            'Morning slots: ${morningSlots.length}, Evening slots: ${eveningSlots.length}',
          );

          List<Map<String, dynamic>> slotsData = [];

          if (morningSlots.isNotEmpty && eveningSlots.isNotEmpty) {
            slotsData = [
              {'title': 'morning', 'slottime': morningSlots},
              {'title': 'evening', 'slottime': eveningSlots},
            ];
          } else if (morningSlots.isNotEmpty) {
            slotsData = [
              {'title': 'morning', 'slottime': morningSlots},
            ];
          } else if (eveningSlots.isNotEmpty) {
            slotsData = [
              {'title': 'evening', 'slottime': eveningSlots},
            ];
          } else {
            // All day - create slot info with booking status
            List<Map<String, dynamic>> allDaySlots = timeSlotsWithStatus
                .map(
                  (slotData) => {
                    'id': slotData['time'].hashCode,
                    'name': slotData['time'],
                    'is_book': slotData['is_booked'] ? '1' : '0',
                  },
                )
                .toList();

            slotsData = [
              {'title': 'all_day', 'slottime': allDaySlots},
            ];
          }

          loggerNoStack.i(
            'Created ${slotsData.length} slot groups with ${timeSlotsWithStatus.length} total slots',
          );

          // Convert to MakeAppointmentClass1 format
          makeAppointmentClass = MakeAppointmentClass1.fromJson({
            'success': '1',
            'data': slotsData,
          });

          // Initialize slot selection
          for (int j = 0; j < slotsData.length; j++) {
            if (j == 0) {
              selectedSlot.add(true.obs);
            } else {
              selectedSlot.add(false.obs);
            }
          }

          initializeTimeSlotsFromSupabase(0);
          isLoading.value = false;
          previousSelectedSlot.value = 0;
          checkHolidayFuture.value = false;
        } else {
          // No slots available
          loggerNoStack.w('No time slots found for this date');
          isNoSlot.value = true;
          isLoading.value = false;
          checkHolidayFuture.value = false;
        }
      } else {
        // Doctor not available on this day
        loggerNoStack.w('Doctor not available on this date');
        isLoading.value = false;
        checkHolidayFuture.value = true;
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('Error checking availability: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      isNoSlot.value = true;
      isLoading.value = false;
      checkHolidayFuture.value = false;
    } finally {
      isChecked.value = false;
    }
  }

  initializeTimeSlotsFromSupabase(int index) {
    selectedTimingSlot.clear();
    try {
      loggerNoStack.d(
        'Initializing time slots for index $index, total slots: ${makeAppointmentClass!.data![index].slottime!.length}',
      );
      for (
        int i = 0;
        i < makeAppointmentClass!.data![index].slottime!.length;
        i++
      ) {
        selectedTimingSlot.add(false.obs);
        var slot = makeAppointmentClass!.data![index].slottime![i];
        loggerNoStack.d('Slot $i: ${slot.name} - is_book: ${slot.isBook}');
      }
    } catch (e) {
      loggerNoStack.e('Error initializing time slots: $e');
      isNoSlot.value = true;
      isLoading.value = false;
    }
    currentSlotsIndex.value = index;
  }

  initializeTimeSlots(int index) {
    selectedTimingSlot.clear();
    try {
      for (
        int i = 0;
        i < makeAppointmentClass!.data![index].slottime!.length;
        i++
      ) {
        selectedTimingSlot.add(false.obs);
      }
    } catch (e) {
      isNoSlot.value = true;
      isLoading.value = false;
    }
    currentSlotsIndex.value = index;
  }

  processPayment({required BuildContext context}) async {
    Get.focusScope?.unfocus();

    // Check if a time slot has been selected
    if (slotId.value.isEmpty) {
      messageDialog('error'.tr, 'select_appointment_time'.tr);
      return;
    }

    // Check if patient has available sessions
    try {
      final user = firebaseHelper.currentUser;
      if (user != null) {
        final patientData = await supabaseHelper.client
            .from('patients')
            .select('sessions_available')
            .eq('id', user.uid)
            .single();

        final sessionsAvailable = patientData['sessions_available'] ?? 0;

        loggerNoStack.i('Patient has $sessionsAvailable sessions available');

        if (sessionsAvailable <= 0) {
          // No sessions available - redirect to payment plans
          loggerNoStack.w(
            'Patient has no sessions available, redirecting to payment plans',
          );

          customDialog(
            s1: 'no_sessions_available'.tr,
            s2: 'please_subscribe_to_continue'.tr,
            onPressed: () {
              loggerNoStack.d('Navigating to payment plans screen');
              Get.back(); // Close dialog
              Get.offAllNamed(
                Routes.userTabScreen,
                arguments: {'initialTab': 3},
              );
            },
          );
          return;
        }

        // Patient has sessions - proceed with booking WITHOUT payment
        bookAppointmentWithSession();
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('Error checking patient sessions: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      messageDialog('error'.tr, 'error2'.tr);
    }
  }

  /// Book appointment using patient's available sessions (NO PAYMENT)
  bookAppointmentWithSession() async {
    try {
      customDialog1(s1: 'reporting_dialog1'.tr, s2: 'appoint_make_dialog'.tr);

      loggerNoStack.i('Creating booking with session deduction...');

      final user = firebaseHelper.currentUser;
      if (user == null) {
        Get.back();
        messageDialog('error'.tr, 'not_authenticated'.tr);
        return;
      }

      final patientId = user.uid;

      // 1. Deduct session from patient's available count
      final patientData = await supabase
          .from('patients')
          .select('sessions_available, sessions_pending')
          .eq('id', patientId)
          .single();

      final currentAvailable = patientData['sessions_available'] ?? 0;
      final currentPending = patientData['sessions_pending'] ?? 0;

      if (currentAvailable <= 0) {
        Get.back();
        messageDialog('error'.tr, 'no_sessions_available'.tr);
        return;
      }

      // Deduct 1 from available, add 1 to pending
      await supabase
          .from('patients')
          .update({
            'sessions_available': currentAvailable - 1,
            'sessions_pending': currentPending + 1,
          })
          .eq('id', patientId);

      loggerNoStack.i(
        'Session deducted: Available $currentAvailable -> ${currentAvailable - 1}, Pending $currentPending -> ${currentPending + 1}',
      );

      // 2. Create booking in Supabase
      // date and slotName are in doctor's timezone (from doctor's availability)
      final timeParts = slotName.value.split(':');
      final formattedTime =
          '${int.parse(timeParts[0]).toString().padLeft(2, '0')}:${int.parse(timeParts[1]).toString().padLeft(2, '0')}:00';

      final bookingData = {
        'patient_id': patientId,
        'doctor_id': doctorId,
        'availability_id': slotId.value.isNotEmpty ? slotId.value : null,
        'status': 'confirmed',
        'price': '0', // No payment for session-based booking
        'payment_intent_id': null, // No payment
        'video_session_id': null,
        'created_at': TimezoneService.getCurrentMauritaniaTime()
            .toIso8601String(),
        'booking_date': date, // YYYY-MM-DD in doctor's timezone
        'booking_time': formattedTime, // HH:mm:ss in doctor's timezone
      };

      final response = await supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      loggerNoStack.i('✅ Booking created successfully: ${response['id']}');

      // 3. Send email notifications to both patient and doctor
      _sendBookingEmailNotifications(
        bookingId: response['id'].toString(),
        patientId: patientId,
        doctorId: doctorId,
        bookingDate: DateTime.parse(date),
        bookingTime: formattedTime,
      );

      Get.back();
      isAppointmentMadeSuccessfully.value = true;
      customDialog(
        dismiss: false,
        s1: 'success'.tr,
        s2: 'appointment_made_success'.tr,
        onPressed: () {
          Get.back();
          Get.back();

          Get.toNamed(
            Routes.uAppointmentDetailScreen,
            arguments: {'id': response['id'].toString()},
          );
        },
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('Error creating booking with session: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      Get.back();
      messageDialog('error'.tr, 'error2'.tr);
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      customDialog(
        s1: 'success'.tr,
        s2: 'payment_success'.tr,
        dismiss: false,
        onPressed: () {
          Get.back();
          bookAppointment(type: "stripe", tId: paymentIntent!['id']);
          paymentIntent = null;
        },
      );
    } on StripeException catch (e) {
      customDialog(s1: 'fail'.tr, s2: "${'fail_description'.tr}\n$e");
    } catch (e) {
      customDialog(s1: 'fail'.tr, s2: "${'fail_description'.tr}\n$e");
    }
  }

  bookAppointment({String? tId, String? type}) async {
    customDialog1(s1: 'reporting_dialog1'.tr, s2: 'appoint_make_dialog'.tr);

    String url = "${Apis.ServerAddress}/api/bookappointment";

    Map mm = {};

    if (type == 'stripe') {
      mm = {
        "user_id": userId,
        "doctor_id": doctorId,
        "date": date,
        "slot_id": slotId.value,
        "slot_name": slotName.value,
        "consultation_fees": consultationFee,
        "payment_type": type,
        "phone": textEditingController.text,
        "user_description": description.value,
        "stripe_payment_id": tId,
      };
    } else {
      mm = {
        "user_id": userId,
        "doctor_id": doctorId,
        "date": date,
        "slot_id": slotId.value,
        "slot_name": slotName.value,
        "consultation_fees": consultationFee,
        "payment_type": type,
        "phone": textEditingController.text,
        "user_description": description.value,
      };
    }

    final response = await post(Uri.parse(url), body: mm);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse["success"].toString() == "1") {
        Get.back();
        AppointmentId.value = jsonResponse['data'].toString();
        if (type == 'online') {
          String? paymentLink;

          if (selectedPaymentMethod.value == 3) {
            paymentLink =
                '${Apis.ServerAddress}/paystack-payment?id=$AppointmentId&type=1';
          } else if (selectedPaymentMethod.value == 4) {
            paymentLink =
                '${Apis.ServerAddress}/rave-payment?id=$AppointmentId&type=1';
          } else if (selectedPaymentMethod.value == 5) {
            paymentLink =
                '${Apis.ServerAddress}/paytm-payment?id=$AppointmentId&type=1';
          } else if (selectedPaymentMethod.value == 6) {
            paymentLink =
                '${Apis.ServerAddress}/braintree_payment?id=$AppointmentId&type=1';
          } else if (selectedPaymentMethod.value == 7) {
            paymentLink =
                '${Apis.ServerAddress}/pay_razorpay?id=$AppointmentId&type=1';
          } else if (selectedPaymentMethod.value == 8) {
            paymentLink =
                '${Apis.ServerAddress}/stripe-payment?id=$AppointmentId&type=1';
          } else {
            messageDialog('fail'.tr, 'fail_description'.tr);
          }

          Get.toNamed(
            Routes.inAppWebViewScreen,
            arguments: {
              'url': paymentLink,
              'isDoctor': 1,
              'appointmentId': AppointmentId.value,
            },
          )?.then((result) {
            if (result == 'success') {
              isAppointmentMadeSuccessfully.value = true;
              customDialog(
                s1: 'success'.tr,
                s2: 'appointment_made_success'.tr,
                dismiss: false,
                onPressed: () {
                  Get.back();
                  Get.back();

                  Get.toNamed(
                    Routes.uAppointmentDetailScreen,
                    arguments: {'id': AppointmentId.value},
                  );
                },
              );
            } else if (result == 'fail') {
              messageDialog('fail'.tr, 'fail_description'.tr);
            }
          });
        } else if (type == 'stripe') {
          customDialog(
            s1: 'success'.tr,
            s2: 'appointment_made_success'.tr,
            onPressed: () {
              Get.back();
              Get.back();
              Get.toNamed(
                Routes.uAppointmentDetailScreen,
                arguments: {'id': AppointmentId.value},
              );
            },
            dismiss: false,
          );
        } else {
          isAppointmentMadeSuccessfully.value = true;
          customDialog(
            dismiss: false,
            s1: 'success'.tr,
            s2: 'appointment_made_success'.tr,
            onPressed: () {
              Get.back();
              Get.back();
              Get.toNamed(
                Routes.uAppointmentDetailScreen,
                arguments: {'id': AppointmentId.value},
              );
            },
          );
        }
      } else if (jsonResponse["success"].toString() == "3") {
        Get.back();
        customDialog(
          s1: 'error'.tr,
          s2: jsonResponse['register'],
          onPressed: () async {
            try {
              CallManager.instance.destroy();
              await PushNotificationsManager.instance.unsubscribe();
              await SharedPrefs.deleteUserData();
              await signOut();
            } catch (e) {}
            await SharedPreferences.getInstance().then((pref) {
              pref.clear();
              pref.setString("isBack", "1");
            });
            StorageService.writeBoolData(
              key: LocalStorageKeys.isLoggedInAsDoctor,
              value: false,
            );
            StorageService.writeBoolData(
              key: LocalStorageKeys.isLoggedIn,
              value: false,
            );
            await Get.toNamed(
              Routes.loginUserScreen,
              arguments: {"isBack": false},
            );
          },
        );
      } else {
        Get.back();
        messageDialog('error'.tr, jsonResponse['register']);
      }
    }
  }

  checkIfHoliday(String date, bool isFirst, {required int i}) async {
    bool isHoliday = false;
    isLoading.value = true;
    isChecked.value = true;
    isNoSlot.value = false;

    try {
      var response = await http.get(
        Uri.parse(
          '${Apis.ServerAddress}/api/checkholiday?doctor_id=$doctorId&date=$date',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        isHoliday = jsonResponse['success'].toString() == '0' ? true : false;
        if (!isHoliday) {
          selectedSlot.clear();
          slotName.value = "";
          slotId.value = "";
          currentSlotsIndex.value = 0;
          previousSelectedTimingSlot.value = 0;
          makeAppointmentClass = MakeAppointmentClass1.fromJson(jsonResponse);
          if (makeAppointmentClass!.success.toString() == "1") {
            for (int i = 0; i < makeAppointmentClass!.data!.length; i++) {
              if (i == 0) {
                selectedSlot.add(true.obs);
              } else {
                selectedSlot.add(false.obs);
              }
            }
            initializeTimeSlotsFromSupabase(0);
            isLoading.value = false;
            previousSelectedSlot.value = 0;
          } else {
            isNoSlot.value = true;
            isLoading.value = false;
          }
        } else {
          isLoading.value = false;
        }
      }
    } catch (e) {
      isNoSlot.value = true;
      isLoading.value = false;
      loggerNoStack.e('Error checking holiday: $e');
    } finally {
      checkHolidayFuture.value = isHoliday;
      isChecked.value = false;
      http.Client().close();
    }
  }

  messageDialog(String s1, String s2) {
    customDialog(
      s1: s1,
      s2: s2,
      onPressed: () {
        Get.back();
      },
    );
  }

  RxInt selectedPaymentMethod = 2.obs;

  bottomSheet({required BuildContext context}) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: AppColors.transparentColor,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.WHITE,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      15.hs,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppTextWidgets.boldTextWithColor(
                                text: "$name's ${'consultation_fee'.tr}",
                                color: AppColors.BLACK,
                                size: 12,
                              ),
                            ),
                            20.ws,
                            AppTextWidgets.boldTextWithColor(
                              text: CURRENCY.trim() + (consultationFee),
                              color: AppColors.AMBER,
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                      5.hs,
                      Divider(color: AppColors.grey, thickness: 0.7),
                      5.hs,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AppTextWidgets.semiBoldText(
                          text: 'select_a_payment_method'.tr.toUpperCase(),
                          color: AppColors.LIGHT_GREY_TEXT,
                          size: 12,
                        ),
                      ),
                      5.hs,
                      SizedBox(
                        height: Get.height * 0.5,
                        child: ListView(
                          children: [
                            paymentMethodCardTile(
                              title: 'method1_title'.tr,
                              explanation: 'method1_description'.tr,
                              index: 2,
                              setState: setState,
                            ),
                            Divider(color: AppColors.grey, thickness: 0.7),
                            paymentMethodCardTile(
                              title: 'method2_title'.tr,
                              explanation: 'common_description'.tr,
                              index: 3,
                              setState: setState,
                            ),
                            Divider(color: AppColors.grey, thickness: 0.7),
                            paymentMethodCardTile(
                              title: 'method3_title'.tr,
                              explanation: 'common_description'.tr,
                              index: 4,
                              setState: setState,
                            ),
                            Divider(color: AppColors.grey, thickness: 0.7),

                            paymentMethodCardTile(
                              title: 'method5_title'.tr,
                              explanation: 'common_description'.tr,
                              index: 6,
                              setState: setState,
                            ),
                            Divider(color: AppColors.grey, thickness: 0.7),
                            paymentMethodCardTile(
                              title: 'method7_title'.tr,
                              explanation: 'common_description'.tr,
                              index: 7,
                              setState: setState,
                            ),
                            Divider(color: AppColors.grey, thickness: 0.7),
                            paymentMethodCardTile(
                              title: 'method6_title'.tr,
                              explanation: 'method6_description'.tr,
                              index: 8,
                              setState: setState,
                            ),
                            Divider(color: AppColors.grey, thickness: 0.7),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Obx(
                  () => CustomButton(
                    onTap: () async {
                      Get.back();
                      if (selectedPaymentMethod.value == 2) {
                        bookAppointment(type: "COD");
                      } else if (selectedPaymentMethod.value == 8) {
                        paymentIntent =
                            await (String amount, String currency) async {
                              Map<String, dynamic> body = {
                                'amount': ((int.parse(amount)) * 100)
                                    .toString(),
                                'currency': currency,
                                'payment_method_types[]': 'card',
                              };

                              var response = await http.post(
                                Uri.parse(
                                  'https://api.stripe.com/v1/payment_intents',
                                ),
                                headers: {
                                  'Authorization': 'Bearer $stripeSecretKey',
                                  'Content-Type':
                                      'application/x-www-form-urlencoded',
                                },
                                body: body,
                              );
                              return jsonDecode(response.body.toString());
                            }(consultationFee, CURRENCY_CODE);
                        http.Client().close();
                        await Stripe.instance.initPaymentSheet(
                          paymentSheetParameters: SetupPaymentSheetParameters(
                            paymentIntentClientSecret:
                                paymentIntent!['client_secret'],
                            merchantDisplayName: 'Doctor Finder',
                          ),
                        );
                        displayPaymentSheet();
                      } else {
                        bookAppointment(type: "online");
                      }
                    },
                    btnText: selectedPaymentMethod.value == 2
                        ? 'make_an_appointment'.tr
                        : 'process_payment'.tr,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> navigateToPaymentScreen(BuildContext context) async {
    Get.focusScope?.unfocus();

    // Check if a time slot has been selected
    if (slotId.value.isEmpty) {
      customDialog(
        s1: 'error'.tr,
        s2: 'select_appointment_time'.tr,
        onPressed: () => Get.back(),
      );
      return;
    }

    // Check if patient has available sessions
    try {
      final user = firebaseHelper.currentUser;
      if (user != null) {
        final patientData = await supabaseHelper.client
            .from('patients')
            .select('sessions_available')
            .eq('id', user.uid)
            .single();

        final sessionsAvailable = patientData['sessions_available'] ?? 0;

        loggerNoStack.i('Patient has $sessionsAvailable sessions available');

        if (sessionsAvailable <= 0) {
          // No sessions available - redirect to payment plans
          loggerNoStack.w(
            'Patient has no sessions available, redirecting to payment plans',
          );

          customDialog(
            s1: 'no_sessions_available'.tr,
            s2: 'please_subscribe_to_continue'.tr,
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAllNamed(
                Routes.userTabScreen,
                arguments: {'initialTab': 3},
              );
            },
          );
          return;
        }
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('Error checking patient sessions: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      // Continue with normal flow if check fails
    }

    // Prepare data with safer null checks
    Map<String, dynamic> paymentData = {
      'doctorName': name,
      'doctorId': id,
      'userId': userId,
      'doctorImageUrl': image,
      'appointmentDate': date,
      'appointmentTime': slotName.value,
      'slotId': slotId.value,
      'amount': consultationFee,
      'phone': textEditingController.text,
      'description': description.value,
    };

    print("Navigation data: $paymentData"); // Debug print

    // Use a safer navigation approach
    try {
      Get.toNamed(Routes.userPaymentScreen, arguments: paymentData);
    } catch (e) {
      print("Navigation error: ${e.toString()}");
      customDialog(
        s1: 'error'.tr,
        s2: 'something_went_wrong'.tr,
        onPressed: () => Get.back(),
      );
    }
  }

  paymentMethodCardTile({
    required String title,
    required String explanation,
    required int index,
    required StateSetter setState,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod.value = index;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.LIGHT_GREY_TEXT),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selectedPaymentMethod.value == index
                    ? AppColors.AMBER
                    : AppColors.transparentColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidgets.mediumTextWithSize(text: title, size: 18),
                AppTextWidgets.blackText(
                  text: explanation,
                  color: AppColors.LIGHT_GREY_TEXT,
                  size: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  void onInit() {
    super.onInit();
    initialize();
    date = TimezoneService.toIsoDateString(dateTime);
    loadDoctorPricing();
  }

  Future<void> loadDoctorPricing() async {
    try {
      final pricing = await pricingService.getPricingForDoctor(id);
      if (pricing != null) {
        doctorPricing.value = pricing;
        dynamicPrice.value = pricing.sessionPrice.toStringAsFixed(0);
        dynamicCurrency.value = pricing.currency;
        consultationFee = dynamicPrice.value;
      }
    } catch (e) {
      print('Error loading doctor pricing: $e');
    }
  }

  updateSelectedDuration(String duration) {
    selectedDuration.value = duration;
    // Add any additional logic needed for duration change
    // such as fee adjustment, time slot updates, etc.
  }

  void handleLogout() async {
    try {
      CallManager.instance.destroy();
      // Removed ConnectyCube dependencies
      print('User logged out from appointment screen');

      // Clear user data
      StorageService.writeBoolData(
        key: LocalStorageKeys.isLoggedIn,
        value: false,
      );

      Get.offAllNamed(Routes.patientOnboardingScreen);
    } catch (e) {
      print('Logout error: $e');
    }
  }

  /// Generate list of available dates based on doctor's weekly availability
  /// This method looks ahead for the next available dates based on the doctor's schedule
  Future<void> generateAvailableDates() async {
    try {
      availableDates.clear();

      if (weeklyAvailability.isEmpty) {
        loggerNoStack.w('No weekly availability data found');
        return;
      }

      // Get the days of week when doctor is available
      Set<int> availableDays = weeklyAvailability
          .where((availability) => availability.isAvailable)
          .map((availability) => availability.dayNumber)
          .toSet();

      loggerNoStack.i(
        'Doctor is available on days: $availableDays (0=Sunday, 1=Monday, etc.)',
      );

      // Generate available dates for the next maxDaysAhead days (15 days)
      // Use doctor's timezone so dates align with doctor's calendar
      final doctorOffset = doctorTimezoneOffsetHours.value ?? 0;
      DateTime currentDate = TimezoneService.getCurrentTimeInDoctorTimezone(
        doctorOffset,
      );
      int daysChecked = 0;

      // Continue until we check all 15 days ahead or find enough dates
      while (daysChecked < maxDaysAhead) {
        DateTime checkDate = currentDate.add(Duration(days: daysChecked));

        // Convert Dart weekday to database format
        int dayNumber = checkDate.weekday == 7 ? 0 : checkDate.weekday;

        // Check if doctor is available on this day of week
        if (availableDays.contains(dayNumber)) {
          availableDates.add(checkDate);
          loggerNoStack.d(
            'Added available date: ${TimezoneService.toIsoDateString(checkDate)} (day $dayNumber)',
          );
        }

        daysChecked++;
      }

      loggerNoStack.i(
        'Generated ${availableDates.length} available dates from $maxDaysAhead days ahead',
      );

      // Update isSelected list to match available dates count
      isSelected.clear();
      for (int i = 0; i < availableDates.length; i++) {
        if (i == 0) {
          isSelected.add(true.obs);
        } else {
          isSelected.add(false.obs);
        }
      }
    } catch (e) {
      loggerNoStack.e('Error generating available dates: $e');
    }
  }

  /// Send email notifications to both patient and doctor when booking is created
  Future<void> _sendBookingEmailNotifications({
    required String bookingId,
    required String patientId,
    required String doctorId,
    required DateTime bookingDate,
    required String bookingTime,
  }) async {
    try {
      // Get patient and doctor data
      final patientDataFuture = supabase
          .from('patients')
          .select('name, email')
          .eq('id', patientId)
          .single();

      final doctorDataFuture = supabase
          .from('doctors')
          .select('full_name, email, timezone_offset_hours')
          .eq('doctor_id', doctorId)
          .single();

      final results = await Future.wait([patientDataFuture, doctorDataFuture]);
      final patientData = results[0];
      final doctorData = results[1];

      final patientName = patientData['name'] ?? 'Patient';
      final patientEmail = patientData['email'] ?? '';
      final doctorName = doctorData['full_name'] ?? 'Doctor';
      final doctorEmail = doctorData['email'] ?? '';
      final doctorTimezoneOffset =
          (doctorData['timezone_offset_hours'] as num?)?.toInt() ?? 0;

      // Format date and time (already in doctor's timezone from booking)
      final formattedDate =
          '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}';
      final timeOnly = bookingTime.length >= 5
          ? bookingTime.substring(0, 5)
          : bookingTime; // HH:mm

      // Send emails using the multilingual email service
      if (doctorEmail.isNotEmpty) {
        await BookingEmailService.sendDoctorEmail(
          doctorEmail: doctorEmail,
          doctorName: doctorName,
          patientName: patientName,
          bookingId: bookingId,
          formattedDate: formattedDate,
          timeOnly: timeOnly,
          doctorTimezoneOffsetHours: doctorTimezoneOffset,
        );
      }

      if (patientEmail.isNotEmpty) {
        await BookingEmailService.sendPatientEmail(
          patientEmail: patientEmail,
          patientName: patientName,
          doctorName: doctorName,
          bookingId: bookingId,
          formattedDate: formattedDate,
          timeOnly: timeOnly,
        );
      }

      loggerNoStack.i('✅ Email notifications sent successfully');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error sending email notifications: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      // Don't throw error - email notifications are not critical
    }
  }
}
