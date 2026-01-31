import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';
import 'package:videocalling/features/patient/appointments/models/uall_appointment_model.dart';

class UAllAppointmentsController extends GetxController {
  RxList<UAppointmentData> list = <UAppointmentData>[].obs;
  RxList<UAppointmentData> filteredList = <UAppointmentData>[].obs;
  RxString userId = "".obs;
  RxBool isAppointmentExist = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isLoaded = false.obs;
  RxBool isErrorInLoading = false.obs;
  RxString nextUrl = "null".obs;
  UserAAppointmentsClass? userAppointmentsClass;
  ScrollController scrollController = ScrollController();

  // Status mapping based on backend code
  final Map<String, String> statusMap = {
    '0': 'Absent',
    '1': 'Received',
    '2': 'Approved',
    '3': 'In Process',
    '4': 'Completed',
    '5': 'Rejected',
    '6': 'Refunded',
  };

  // Tab and filter state
  RxInt selectedTab = 1.obs; // 0 = Previous, 1 = Upcoming
  RxInt selectedFilter =
      0.obs; // 0 = All, 1 = Attended, 2 = Canceled, 3 = Absent

  Future<void> fetchAppointments() async {
    isErrorInLoading.value = false;
    isLoaded.value = false;

    try {
      print("🔍 Fetching appointments for user ID: ${userId.value}");

      if (userId.value.isEmpty) {
        print('❌ No user ID found');
        isErrorInLoading.value = true;
        isLoaded.value = true;
        return;
      }

      // Fetch all appointments from Supabase bookings table
      final response = await supabaseHelper.client
          .from('bookings')
          .select('''
            *,
            status,
            doctors!doctor_id (
              doctor_id,
              full_name,
              email,
              phone_number,
              specialization,
              profile_img_url,
              years_of_exp,
              numb_patients,
              gender,
              bio
            )
          ''')
          .eq('patient_id', userId.value)
          .order('booking_date', ascending: false)
          .order('booking_time', ascending: false);

      print('✅ Received ${response.length} total appointments');

      if (response.isNotEmpty) {
        isAppointmentExist.value = true;
        list.clear();

        // Convert Supabase response to UAppointmentData format
        for (var booking in response) {
          final doctorData = booking['doctors'];

          // Combine date and time for display
          final bookingDate = booking['booking_date']?.toString() ?? '';
          final bookingTime = booking['booking_time']?.toString() ?? '';

          // Map Supabase status to numeric codes
          String status = booking['status']?.toString() ?? 'confirmed';
          if (status == 'confirmed' || status == 'pending') {
            status = '1'; // Received
          } else if (status == 'approved') {
            status = '2';
          } else if (status == 'in_progress') {
            status = '3';
          } else if (status == 'completed') {
            status = '4';
          } else if (status == 'cancelled' || status == 'rejected') {
            status = '5';
          } else if (status == 'refunded') {
            status = '6';
          } else if (status == 'absent') {
            status = '0';
          }

          final appointmentData = UAppointmentData(
            id: booking['id']?.toString(),
            doctorId: booking['doctor_id']?.toString(),
            date: bookingDate,
            slot: bookingTime,
            phone: doctorData?['phone_number']?.toString() ?? '',
            name: doctorData?['full_name']?.toString() ?? 'Unknown Doctor',
            address: doctorData?['bio']?.toString() ?? '',
            image: doctorData?['profile_img_url']?.toString() ?? '',
            departmentName:
                doctorData?['specialization']?.toString() ?? 'Specialist',
            status: status,
            gender: doctorData?['gender']?.toString(),
          );

          list.add(appointmentData);
        }

        print("✅ Loaded ${list.length} appointments");

        // Apply filters
        applyFilters();
      } else {
        print('ℹ️ No appointments found');
        isAppointmentExist.value = false;
        list.clear();
        filteredList.clear();
      }
    } catch (e, stackTrace) {
      print("❌ Exception when fetching appointments: $e");
      print("Stack trace: $stackTrace");
      isErrorInLoading.value = true;
      isAppointmentExist.value = false;
      filteredList.clear();
    } finally {
      isLoaded.value =
          true; // Always set loaded to true to avoid infinite loading
    }
  }

  Future<void> loadMore() async {
    // For Supabase, we load all appointments at once
    // Pagination can be implemented later using .range() if needed
    print(
      'ℹ️ Load more not implemented for Supabase (all appointments loaded at once)',
    );
  }

  // Apply filters based on selected tab and filter option
  void applyFilters() {
    if (list.isEmpty) {
      filteredList.clear();
      isAppointmentExist.value = false;
      return;
    }

    print(
      "🔍 Applying filters - Tab: ${selectedTab.value}, Filter: ${selectedFilter.value}",
    );

    final today = TimezoneService.getCurrentMauritaniaTime();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // First filter by DATE, based on tab selection to exactly match backend logic
    if (selectedTab.value == 1) {
      // UPCOMING TAB: Future dates OR today's date with pending status
      var upcoming = list.where((appointment) {
        final appointmentDate = appointment.date ?? '';

        // Future dates - always show
        if (appointmentDate.compareTo(todayStr) > 0) {
          return true;
        }

        // Today's appointments with pending status
        if (appointmentDate == todayStr) {
          final status = appointment.status;
          return status == '1' ||
              status == '2' ||
              status == '3'; // Received, Approved, In Process
        }

        return false;
      }).toList();

      print("📈 Found ${upcoming.length} upcoming appointments");

      // Sort by date (nearest first)
      upcoming.sort((a, b) {
        try {
          final aDate = _parseDate(a.date);
          final bDate = _parseDate(b.date);
          if (aDate == null || bDate == null) return 0;
          return aDate.compareTo(bDate);
        } catch (e) {
          return 0;
        }
      });

      filteredList.value = upcoming;
    } else {
      // PREVIOUS TAB: Past dates OR today's date with completed/canceled status
      var past = list.where((appointment) {
        final appointmentDate = appointment.date ?? '';

        // Past dates - always show
        if (appointmentDate.compareTo(todayStr) < 0) {
          return true;
        }

        // Today's appointments with completed/canceled status
        if (appointmentDate == todayStr) {
          final status = appointment.status;
          return status == '0' ||
              status == '4' ||
              status == '5' ||
              status == '6';
        }

        return false;
      }).toList();

      print("📉 Found ${past.length} past appointments");

      // Apply additional status filter for past appointments
      switch (selectedFilter.value) {
        case 1: // Completed (status 4)
          filteredList.value = past.where((a) => a.status == '4').toList();
          break;
        case 2: // Canceled - Rejected & Refunded (status 5, 6)
          filteredList.value = past
              .where((a) => a.status == '5' || a.status == '6')
              .toList();
          break;
        case 3: // Absent (status 0) - correctly labeled now
          filteredList.value = past.where((a) => a.status == '0').toList();
          break;
        default: // All past
          filteredList.value = past;
      }

      // Sort by date (newest first)
      var sortedPast = filteredList.toList();
      sortedPast.sort((a, b) {
        try {
          final aDate = _parseDate(a.date);
          final bDate = _parseDate(b.date);
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        } catch (e) {
          return 0;
        }
      });
      filteredList.value = sortedPast;
    }

    // Update empty state
    isAppointmentExist.value = filteredList.isNotEmpty;
    print("🏁 Final filtered list contains ${filteredList.length} items");
  }

  // Helper method to parse date strings
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    try {
      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) return null;

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  // Refresh appointments (for pull-to-refresh)
  Future<void> refreshAppointments() async {
    print("🔄 Refreshing appointments");
    list.clear();
    filteredList.clear();
    isLoaded.value = false;
    isErrorInLoading.value = false;
    await fetchAppointments();
  }

  @override
  void onInit() {
    super.onInit();

    // Initialize with a small delay to ensure storage is ready
    _initializeAppointments();

    // Add listeners for tab and filter changes
    ever(selectedTab, (_) => applyFilters());
    ever(selectedFilter, (_) => applyFilters());

    // Listen for userId changes and refetch
    ever(userId, (value) {
      if (value.isNotEmpty && list.isEmpty) {
        loggerNoStack.d("📥 userId changed to: $value, fetching appointments");
        fetchAppointments();
      }
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMore();
      }
    });
  }

  Future<void> _initializeAppointments() async {
    // Small delay to ensure storage and Firebase are ready
    await Future.delayed(const Duration(milliseconds: 300));

    // Try to get userId from storage
    userId.value = StorageService.readData(key: LocalStorageKeys.userId) ?? "";

    if (userId.value.isEmpty) {
      loggerNoStack.d("⚠️ Warning: userId is empty in storage!");

      // Try to get from other storage locations
      var alternateId = StorageService.readData(
        key: LocalStorageKeys.userIdWithAscii,
      );
      if (alternateId != null && alternateId.isNotEmpty) {
        userId.value = alternateId;
        loggerNoStack.d("🔍 Using alternate userId: ${userId.value}");
      }
    }

    // If still empty, try to get from Firebase
    if (userId.value.isEmpty) {
      try {
        final firebaseUser = supabaseHelper.client.auth.currentUser;
        if (firebaseUser != null) {
          userId.value = firebaseUser.id;
          loggerNoStack.d("🔥 Got userId from Supabase auth: ${userId.value}");
        }
      } catch (e) {
        loggerNoStack.e("Error getting user from auth: $e");
      }
    }

    if (userId.value.isNotEmpty) {
      loggerNoStack.d("User ID found: ${userId.value}, fetching appointments");
      await fetchAppointments();
      loggerNoStack.d("✅ Initial fetchAppointments completed");
    } else {
      isLoaded.value = true; // Set to true to avoid indefinite loading
      isErrorInLoading.value = true;
      loggerNoStack.d("❌ No user ID found, cannot fetch appointments");
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
