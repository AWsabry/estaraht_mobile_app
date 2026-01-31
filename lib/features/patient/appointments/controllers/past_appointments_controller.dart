import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

class UserPastAppointmentsController extends GetxController {
  RxList<AppointmentData> list = <AppointmentData>[].obs;
  String? userId;

  RxBool isAppointmentExist = false.obs;
  RxBool isErrorInLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isLoaded = false.obs;

  String nextUrl = "";

  UserAppointmentsClass? userAppointmentsClass;
  ScrollController scrollController = ScrollController();

  fetchUpcomingAppointments() async {
    try {
      isErrorInLoading.value = false;

      // Get current user ID from Firebase
      final currentUser = firebaseHelper.currentUser;
      if (currentUser == null) {
        userId = StorageService.readData(key: LocalStorageKeys.userId) ?? "";
      } else {
        userId = currentUser.uid;
      }

      if (userId == null || userId!.isEmpty) {
        print('❌ No user ID found');
        isErrorInLoading.value = true;
        isLoaded.value = true;
        return;
      }

      print('📋 Fetching past appointments for user: $userId');

      // Fetch past appointments from Supabase bookings table
      // Past appointments are those with booking_date before today
      final now = TimezoneService.getCurrentMauritaniaTime();
      final today = DateTime(now.year, now.month, now.day);
      final todayString = today.toIso8601String().split('T')[0]; // YYYY-MM-DD

      final response = await supabaseHelper.client
          .from('bookings')
          .select('''
    *,
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
          .eq('patient_id', userId!)
          .lt('booking_date', todayString)
          .order('booking_date', ascending: false)
          .order('booking_time', ascending: false);

      print('✅ Received ${response.length} past appointments');

      if (response.isNotEmpty) {
        isAppointmentExist.value = true;
        list.clear();

        // Convert Supabase response to AppointmentData format
        for (var booking in response) {
          final doctorData = booking['doctors'];

          // Combine date and time for display
          final bookingDate = booking['booking_date']?.toString() ?? '';
          final bookingTime = booking['booking_time']?.toString() ?? '';

          final appointmentData = AppointmentData(
            id: booking['doctor_id']?.toString(), // use doctor_id (TEXT now, not int)
            date: bookingDate,
            slot: bookingTime,
            phone: doctorData?['phone_number'] ?? '',
            name: doctorData?['full_name'] ?? 'Unknown Doctor',
            address: doctorData?['bio'] ?? '', // fallback since you don’t have address
            image: doctorData?['profile_img_url'] ?? '',
            departmentName: doctorData?['specialization'] ?? 'General',
            status: booking['status']?.toString() ?? 'confirmed',
          );


          list.add(appointmentData);
        }

        update();
      } else {
        print('ℹ️ No past appointments found');
        isAppointmentExist.value = false;
        list.clear();
        update();
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching past appointments: $e');
      print('Stack trace: $stackTrace');
      isErrorInLoading.value = true;
      isAppointmentExist.value = false;
    } finally {
      isLoaded.value = true;
      update();
    }
  }

  loadMore() async {
    // For Supabase, we can implement pagination using range
    // For now, we load all past appointments at once
    // You can implement pagination later if needed
    print(
      'ℹ️ Load more not implemented for Supabase (all appointments loaded)',
    );
  }

  @override
  void onInit() {
    super.onInit();
    userId = StorageService.readData(key: LocalStorageKeys.userId) ?? "";
    fetchUpcomingAppointments();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMore();
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }
}
