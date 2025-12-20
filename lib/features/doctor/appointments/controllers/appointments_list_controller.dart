import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/features/doctor/appointments/models/dappointment_list_model.dart';

class DAllAppointmentsController extends GetxController {
  DoctorPastAppointmentsClass? doctorPastAppointmentsClass;
  RxString userId = "".obs;
  RxBool isAppointmentAvailable = false.obs;
  RxString nextUrl = "".obs;
  RxBool isLoadingMore = false.obs;
  RxList<DoctorAppointmentData> list = <DoctorAppointmentData>[].obs;
  List<DoctorAppointmentData> list2 = [];
  ScrollController scrollController = ScrollController();
  RxBool isLoaded = false.obs;
  RxBool isErrorInLoading = false.obs;

  Future<void> fetchPastAppointments() async {
    isErrorInLoading.value = false;
    isLoaded.value = false;
    list.clear();
    try {
      // Get current Firebase UID
      final doctorId = firebaseHelper.currentUserId;
      if (doctorId == null) {
        isErrorInLoading.value = true;
        return;
      }
      userId.value = doctorId;
      // Fetch appointments from Supabase
      final response = await supabaseHelper
          .from('bookings')
          .select('*, patients(name, profile_img_url)')
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);
      loggerNoStack.i("this is the response ${response.first}");
      if (response.isNotEmpty) {
        isLoaded.value = true;
        isAppointmentAvailable.value = true;
        // Map response to DoctorAppointmentData list
        list.addAll(
          response.map((e) => DoctorAppointmentData.fromJson(e)).toList(),
        );
        loggerNoStack.i("this is the first ${list.first.toJson()}");
        // Pagination: if you use nextUrl, set it here (Supabase supports range queries)
        nextUrl.value = "null"; // Set to null or handle pagination if needed
      } else {
        isLoaded.value = true;
        isAppointmentAvailable.value = false;
      }
    } catch (e) {
      isErrorInLoading.value = true;
    }
  }

  Future<void> loadMore() async {
    // If you implement pagination, use range queries here
    // Example: .range(from, to) on Supabase query
    // For now, just set isLoadingMore to false
    isLoadingMore.value = false;
  }

  @override
  void onClose() {
    // TODO: implement dispose
    super.dispose();
    scrollController.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    fetchPastAppointments();
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        await loadMore();
      }
    });
  }
}
