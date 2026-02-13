import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/appointments/models/dappointment_list_model.dart';
import 'package:videocalling/features/doctor/profile/models/doctor_profile_data.dart';
import 'package:videocalling/features/doctor/profile/pages/edit_profile_page.dart';

class DoctorDashboardController extends GetxController {
  DoctorPastAppointmentsClass? doctorAppointmentsClass;
  DoctorProfileWithRating? doctorProfileWithRating;

  RxString doctorId = "".obs;

  RxBool isAppointmentAvailable = false.obs;
  RxBool isLoaded = false.obs;
  RxBool isErrorInLoading = false.obs;

  RxBool isErrorInProfileLoading = false.obs;
  RxBool isProfileLoaded = false.obs;

  RxInt doctorTimezoneOffsetHours = 0.obs;

  final incomingCallManager = Get.put(IncomingManageController());

  fetchDoctorAppointment() async {
    try {
      isAppointmentAvailable.value = false;
      isLoaded.value = false;
      isErrorInLoading.value = false;

      // Fetch doctor's appointments from Supabase
      final response = await supabaseHelper.client
          .from('bookings')
          .select('''
            id,
            patient_id,
            doctor_id,
            booking_date,
            booking_time,
            status,
            patients!fk_bookings_patient (
              id,
              name,
              phone,
              profile_img_url
            )
          ''')
          .eq('doctor_id', doctorId.value)
          .order('booking_date', ascending: false)
          .order('booking_time', ascending: false);

      if (response.isNotEmpty) {
        final appointmentData = {
          'success': '1',
          'register': 'success',
          'data': {
            'current_page': 1,
            'data': response, // Pass the raw response list here
            'first_page_url': '',
            'from': 1,
            'last_page': 1,
            'last_page_url': '',
            'links': [],
            'next_page_url': 'null',
            'path': '',
            'per_page': response.length,
            'prev_page_url': 'null',
            'to': response.length,
            'total': response.length,
          },
        };

        doctorAppointmentsClass = DoctorPastAppointmentsClass.fromJson(
          appointmentData,
        );
        isLoaded.value = true;
        isAppointmentAvailable.value = true;
      } else {
        isLoaded.value = true;
        isAppointmentAvailable.value = false;
      }
    } catch (e) {
      loggerNoStack.e('Error fetching doctor appointments: $e');
      isErrorInLoading.value = true;
      isLoaded.value = true;
    }
  }

  fetchDoctorDetails() async {
    try {
      isErrorInProfileLoading.value = false;

      // Fetch doctor details from Supabase
      final response = await supabaseHelper.client
          .from('doctors')
          .select('''
            doctor_id,
            full_name,
            email,
            profile_img_url,
            specialization,
            average_rating,
            timezone_offset_hours
          ''')
          .eq('doctor_id', doctorId.value)
          .maybeSingle(); // Use maybeSingle() instead of single() to handle 0 rows

      // Check if doctor exists
      if (response == null) {
        loggerNoStack.e('No doctor found with ID: ${doctorId.value}');

        ///print('No doctor found with ID: ${doctorId.value}');
        isErrorInProfileLoading.value = true;
        return;
      }

      // Map Supabase response to DoctorProfileWithRating format
      final doctorData = {
        'success': '1',
        'register': 'success',
        'data': {
          'id': int.tryParse(response['doctor_id']?.toString() ?? '0'),
          'name': response['full_name']?.toString(),
          'image': response['profile_img_url']?.toString(),
          'department_name': response['specialization']?.toString(),
          'avgratting': response['average_rating'] is int
              ? response['average_rating']
              : (response['average_rating'] is double
                    ? response['average_rating'].toInt()
                    : int.tryParse(
                        response['average_rating']?.toString() ?? '0',
                      )),
          'is_subscription': '1', // Default to subscribed for Supabase users
        },
      };

      doctorProfileWithRating = DoctorProfileWithRating.fromJson(doctorData);

      doctorTimezoneOffsetHours.value = response['timezone_offset_hours'] != null
          ? (response['timezone_offset_hours'] as num).toInt()
          : 0;

      // Check if this is a new registration that needs profile completion first
      bool isNewRegistration =
          StorageService.readData(key: 'isNewDoctorRegistration') == true;

      // If has no subscription AND not a new registration, show subscription screen
      if (doctorProfileWithRating!.data!.isSubscription == "0" &&
          !isNewRegistration) {
        // Get.toNamed(Routes.chooseYourPlanScreen, arguments: {
        //   'doctorUrl': doctorProfileWithRating!.data!.image.toString()
        // });
      }
      // If new registration, prioritize profile completion
      else if (isNewRegistration) {
        // Navigate to profile completion
        Get.to(() => DoctorProfile(), arguments: {'isFromRegistration': true});
      }

      isProfileLoaded.value = true;
    } catch (e) {
      loggerNoStack.e('Error fetching doctor details: $e');
      loggerNoStack.e('Doctor ID being queried: ${doctorId.value}');
      isErrorInProfileLoading.value = true;
    }
  }

  Future<bool> dialogPop() async {
    StorageService.removeData(key: LocalStorageKeys.callSessionCS);
    return true;
  }

  dialog() {
    return Get.defaultDialog(
      onWillPop: dialogPop,
      barrierDismissible: true,
      title: 'call_accept_dialog_title'.tr,
      content: Container(
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          children: [
            const SizedBox(width: 20),
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                'call_accept_dialog_subtitle'.tr,
                style: Theme.of(Get.context!).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  onRefresh() async {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      fetchDoctorAppointment();
    });
    refreshController.refreshCompleted();
  }

  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    doctorId.value = firebaseHelper.currentUserId ?? "";

    fetchDoctorAppointment();
    fetchDoctorDetails();
    if (StorageService.readData(key: LocalStorageKeys.callSessionCS) != null) {
      dialog();
    }
  }
}
