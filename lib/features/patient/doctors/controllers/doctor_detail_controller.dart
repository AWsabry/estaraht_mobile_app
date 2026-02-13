import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';
import 'package:videocalling/features/patient/doctors/models/doctor_detail_model.dart';
import 'package:videocalling/shared/models/availability_model.dart';
import 'package:videocalling/shared/models/review_model.dart';
import 'package:videocalling/shared/services/review_service.dart';

class DoctorDetailController extends GetxController {
  DoctorDetailsClass? doctorDetailsClass;
  String id = Get.arguments['id'];
  RxBool isLoading = true.obs;
  RxBool isLoggedIn = false.obs;
  RxBool isErrorInLoading = false.obs;

  // Availability data from Supabase
  RxList<AvailabilityModel> weeklyAvailability = <AvailabilityModel>[].obs;
  RxList<DateTime> availableDates = <DateTime>[].obs;
  RxBool isLoadingAvailability = false.obs;
  final int maxDaysAhead = 31;

  // Time slot display
  RxInt selectedDateIndex = 0.obs;
  RxList<String> currentTimeSlots = <String>[].obs;
  RxBool isLoadingTimeSlots = false.obs;

  // Reviews data
  RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  RxBool isLoadingReviews = false.obs;
  RxDouble averageRating = 0.0.obs;
  RxInt totalReviews = 0.obs;

  // Stats from bookings
  RxInt completedSessions = 0.obs;
  RxInt uniquePatients = 0.obs;

  /// Doctor's timezone offset in hours (UTC). Null until fetched; 0 for existing doctors without the column.
  final Rx<int?> doctorTimezoneOffsetHours = Rx<int?>(null);

  fetchDoctorDetails() async {
    try {
      isLoading.value = true;
      isErrorInLoading.value = false;
      loggerNoStack.e('Fetching details for doctor ID: $id');
      // Fetch doctor details from Supabase
      final response = await supabaseHelper.client
          .from('doctors')
          .select('''
            doctor_id,
            full_name,
            email,
            phone_number,
            age,
            gender,
            specialization,
            bio,
            years_of_exp,
            numb_patients,
            profile_img_url,
            booking_price,
            average_rating,
            total_reviews,
            numb_session,
            avg_session_time,
            fcm_token,
            updated_at,
            timezone_offset_hours
          ''')
          .eq('doctor_id', id)
          .single();

      // Map Supabase response to DoctorDetailsClass format
      final doctorData = {
        'success': '1',
        'register': 'success',
        'data': {
          'id': int.tryParse(response['doctor_id']?.toString() ?? '0'),
          'name': response['full_name'],
          'email': response['email'],
          'phoneno': response['phone_number'],
          'age': response['age']?.toString(),
          'gender': response['gender'],
          'department_name': response['specialization'],
          'aboutus': response['bio'],
          'years_of_exp': response['years_of_exp'],
          'numb_patients': response['numb_patients'],
          'image': response['profile_img_url'],
          'consultation_fees': response['booking_price']?.toString(),
          'avgratting': response['average_rating'],
          'number_review': response['total_reviews'],
          'numb_session': response['numb_session'],
          'avg_session_time': response['avg_session_time'],
          'fcm_token': response['fcm_token'],
          'updated_at': response['updated_at'],
        },
      };

      doctorDetailsClass = DoctorDetailsClass.fromJson(doctorData);
      doctorTimezoneOffsetHours.value =
          response['timezone_offset_hours'] != null
          ? (response['timezone_offset_hours'] as num).toInt()
          : 0;
      isLoading.value = false;
    } catch (e) {
      print('Error fetching doctor details: $e');
      isErrorInLoading.value = true;
      isLoading.value = false;
    }
  }

  /// Fetch available time slots from Supabase for a specific doctor
  Future<void> getAvailableDatesFromSupabase() async {
    try {
      loggerNoStack.t(
        'Getting weekly availability from Supabase for doctor: $id',
      );
      isLoadingAvailability.value = true;

      // Get weekly schedule for the doctor
      final response = await supabaseHelper.client
          .from('availabilities')
          .select()
          .eq('doctor_id', id)
          .eq('is_available', true)
          .order('day_number', ascending: true);

      loggerNoStack.d('Availability response: $response');

      // Parse the response into AvailabilityModel objects
      weeklyAvailability.value = (response as List)
          .map((json) => AvailabilityModel.fromJson(json))
          .toList();

      loggerNoStack.i(
        'Loaded ${weeklyAvailability.length} availability records for doctor detail',
      );
      isLoadingAvailability.value = false;
    } catch (e) {
      loggerNoStack.e('Error fetching availability from Supabase: $e');
      isLoadingAvailability.value = false;
      weeklyAvailability.clear();
    }
  }

  /// Generate list of available dates based on doctor's weekly availability
  Future<void> generateAvailableDates() async {
    try {
      availableDates.clear();

      if (weeklyAvailability.isEmpty) {
        loggerNoStack.w('No weekly availability data found for doctor detail');
        return;
      }

      // Get the days of week when doctor is available (DB: 0=Sunday..6=Saturday; normalize legacy 7→0)
      Set<int> availableDays = weeklyAvailability
          .where((availability) => availability.isAvailable)
          .map((availability) =>
              availability.dayNumber == 7 ? 0 : availability.dayNumber)
          .toSet();

      loggerNoStack.i(
        'Doctor is available on days: $availableDays (0=Sunday, 1=Monday, etc.)',
      );

      // Generate available dates for the next maxDaysAhead days (full month)
      DateTime currentDate = TimezoneService.getCurrentMauritaniaTime();
      int daysChecked = 0;

      while (daysChecked < maxDaysAhead) {
        DateTime checkDate = currentDate.add(Duration(days: daysChecked));

        // Convert Dart weekday to database format
        int dayNumber = checkDate.weekday == 7 ? 0 : checkDate.weekday;

        // Check if doctor is available on this day of week
        if (availableDays.contains(dayNumber)) {
          availableDates.add(checkDate);
          loggerNoStack.d(
            'Added available date: ${checkDate.toString().substring(0, 10)} (day $dayNumber)',
          );
        }

        daysChecked++;
      }

      loggerNoStack.i(
        'Generated ${availableDates.length} available dates from $maxDaysAhead days ahead for doctor detail',
      );
    } catch (e) {
      loggerNoStack.e('Error generating available dates: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value =
        StorageService.readData(key: LocalStorageKeys.isLoggedIn) ?? false;
    fetchDoctorDetails();
    _loadAvailabilityData();
    fetchReviews();
    fetchDoctorStats();
  }

  Future<void> fetchDoctorStats() async {
    try {
      loggerNoStack.i('📊 Fetching doctor stats from bookings...');

      // Get completed sessions count
      final sessionsResponse = await supabaseHelper.client
          .from('bookings')
          .select('id')
          .eq('doctor_id', id)
          .eq('status', 'completed');

      completedSessions.value = (sessionsResponse as List).length;
      loggerNoStack.i('✅ Completed sessions: ${completedSessions.value}');

      // Get unique patients count (distinct patient_id from completed bookings)
      final patientsResponse = await supabaseHelper.client
          .from('bookings')
          .select('patient_id')
          .eq('doctor_id', id)
          .eq('status', 'completed');

      // Get unique patient IDs
      final Set<String> uniquePatientIds = {};
      for (var booking in patientsResponse as List) {
        if (booking['patient_id'] != null) {
          uniquePatientIds.add(booking['patient_id'].toString());
        }
      }
      uniquePatients.value = uniquePatientIds.length;
      loggerNoStack.i('✅ Unique patients: ${uniquePatients.value}');
    } catch (e) {
      loggerNoStack.e('❌ Error fetching doctor stats: $e');
    }
  }

  Future<void> fetchReviews() async {
    try {
      isLoadingReviews.value = true;
      loggerNoStack.i('🔍 Fetching reviews for doctor ID: $id');

      reviews.value = await reviewService.getReviewsForDoctor(id);
      loggerNoStack.i('📝 Fetched ${reviews.length} reviews');

      final ratingData = await reviewService.getDoctorRating(id);
      averageRating.value = ratingData['average_rating'] ?? 0.0;
      totalReviews.value = ratingData['total_reviews'] ?? 0;

      loggerNoStack.i(
        '⭐ Average rating: ${averageRating.value}, Total reviews: ${totalReviews.value}',
      );
    } catch (e) {
      loggerNoStack.e('❌ Error fetching reviews: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> _loadAvailabilityData() async {
    await getAvailableDatesFromSupabase();
    await generateAvailableDates();
    // Initialize with first available date to load time slots
    await initializeWithFirstDate();
  }

  processPayment() async {
    if (isLoggedIn.value) {
      Get.toNamed(
        Routes.makeAppointmentScreen,
        arguments: {
          'id': id,
          'name': doctorDetailsClass!.data!.name ?? "",
          'consultationFee': doctorDetailsClass!.data!.consultationFee,
          'image': doctorDetailsClass!.data!.image ?? "",
        },
      );
    } else {
      Get.toNamed(Routes.loginUserScreen, arguments: {"isBack": true})?.then((
        value,
      ) {
        if (value ?? false) {
          isLoggedIn.value = true;
          Get.toNamed(
            Routes.makeAppointmentScreen,
            arguments: {
              'id': id,
              'name': doctorDetailsClass!.data!.name ?? "",
              'consultationFee': doctorDetailsClass!.data!.consultationFee,
            },
          );
        }
      });
    }
  }

  /// Get day name from weekday number
  String getDayName(int weekday) {
    const days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
    // Convert Dart weekday (1=Monday, 7=Sunday) to our array index (0=Sunday)
    int index = weekday == 7 ? 0 : weekday;
    return days[index];
  }

  /// Get available time slots for a specific date
  Future<List<String>> getTimeSlotsForDate(DateTime selectedDate) async {
    try {
      // Convert Dart weekday to database format
      int dayNumber = selectedDate.weekday == 7 ? 0 : selectedDate.weekday;

      loggerNoStack.t(
        'Getting time slots for date ${selectedDate.toString().substring(0, 10)}, day number: $dayNumber',
      );

      var response = await supabaseHelper.client
          .from('availabilities')
          .select('time_slots')
          .eq('doctor_id', id)
          .eq('day_number', dayNumber)
          .eq('is_available', true)
          .maybeSingle();

      // Backward compatibility: legacy data may have Sunday stored as 7
      if ((response == null || response['time_slots'] == null) &&
          dayNumber == 0) {
        response = await supabaseHelper.client
            .from('availabilities')
            .select('time_slots')
            .eq('doctor_id', id)
            .eq('day_number', 7)
            .eq('is_available', true)
            .maybeSingle();
      }

      if (response != null && response['time_slots'] != null) {
        List<String> slots = List<String>.from(response['time_slots']);

        // Filter out booked slots
        String dateString = selectedDate.toString().substring(0, 10);
        List<String> availableSlots = await filterBookedSlots(
          slots,
          dateString,
        );

        loggerNoStack.i(
          'Found ${availableSlots.length} available time slots for ${selectedDate.toString().substring(0, 10)}',
        );
        return availableSlots;
      }

      return [];
    } catch (e) {
      loggerNoStack.e('Error fetching time slots: $e');
      return [];
    }
  }

  /// Filter out time slots that are already booked.
  /// [date] is doctor-local date (YYYY-MM-DD). Bookings are stored in UTC.
  Future<List<String>> filterBookedSlots(
    List<String> allSlots,
    String date,
  ) async {
    try {
      final doctorOffset = doctorTimezoneOffsetHours.value ?? 0;
      final range = TimezoneService.utcDateRangeForLocalDay(date, doctorOffset);
      List<dynamic> bookedSlots = await supabaseHelper.client
          .from('bookings')
          .select('booking_date, booking_time, status')
          .eq('doctor_id', id)
          .eq('booking_date', range.start);
      if (range.start != range.end) {
        final second = await supabaseHelper.client
            .from('bookings')
            .select('booking_date, booking_time, status')
            .eq('doctor_id', id)
            .eq('booking_date', range.end);
        bookedSlots = [...bookedSlots, ...second];
      }

      if (bookedSlots.isEmpty) {
        return allSlots;
      }

      final dateParts = date.split('-');
      if (dateParts.length < 3) return allSlots;
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final localDayStartUtc = DateTime.utc(
        year,
        month,
        day,
        0,
        0,
      ).subtract(Duration(hours: doctorOffset));
      final localDayEndUtc = DateTime.utc(
        year,
        month,
        day,
        23,
        59,
      ).subtract(Duration(hours: doctorOffset));

      Set<String> bookedTimes = {};
      for (var booking in bookedSlots) {
        String status = booking['status']?.toString().toLowerCase() ?? '';
        if ((status != 'confirmed' && status != 'pending') ||
            booking['booking_date'] == null ||
            booking['booking_time'] == null)
          continue;

        final utcMoment = TimezoneService.parseUtcBookingToDateTime(
          booking['booking_date'].toString(),
          booking['booking_time'].toString(),
        );
        if (utcMoment == null) continue;
        if (utcMoment.isBefore(localDayStartUtc) ||
            utcMoment.isAfter(localDayEndUtc))
          continue;

        final timeStr = TimezoneService.utcBookingToLocalTimeString(
          booking['booking_date'].toString(),
          booking['booking_time'].toString(),
          doctorOffset,
        );
        if (timeStr.isNotEmpty) bookedTimes.add(timeStr);
      }

      return allSlots.where((slot) {
        final normalized = slot.contains(':')
            ? '${slot.split(':')[0].padLeft(2, '0')}:${slot.split(':')[1].padLeft(2, '0')}'
            : slot;
        return !bookedTimes.contains(normalized);
      }).toList();
    } catch (e) {
      loggerNoStack.e('Error filtering booked slots: $e');
      return allSlots;
    }
  }

  /// Handle date selection and load time slots
  Future<void> selectDate(int index) async {
    if (index >= 0 && index < availableDates.length) {
      selectedDateIndex.value = index;
      isLoadingTimeSlots.value = true;

      DateTime selectedDate = availableDates[index];
      List<String> timeSlots = await getTimeSlotsForDate(selectedDate);

      currentTimeSlots.value = timeSlots;
      isLoadingTimeSlots.value = false;

      loggerNoStack.i(
        'Selected date: ${selectedDate.toString().substring(0, 10)}, loaded ${timeSlots.length} time slots',
      );
    }
  }

  /// Initialize with first available date
  Future<void> initializeWithFirstDate() async {
    if (availableDates.isNotEmpty) {
      await selectDate(0);
    }
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
