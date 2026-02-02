// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/doctors/models/doctor_model.dart';
import 'package:videocalling/features/patient/doctors/models/sdoctor_model.dart';
import 'package:videocalling/features/patient/home/models/home_model.dart';

class UserHomeController extends GetxController {
  Future<bool> dialogPop() async {
    StorageService.removeData(key: LocalStorageKeys.callSessionCS);
    return true;
  }

  ScrollController scrollController2 = ScrollController();
  ScrollController scrollController = ScrollController();

  RxList<SpecialityData> list = <SpecialityData>[].obs;

  final cs.CarouselSliderController sliderController =
      cs.CarouselSliderController();
  RxList<BannerList> bannerList = <BannerList>[].obs;
  RxInt current = 0.obs;

  RxList<Appointment> appointmentList = <Appointment>[].obs;

  PageController pageController = PageController();

  SearchDoctorClass? searchDoctorClass;
  TextEditingController textController = TextEditingController();
  RxString nextUrl = "".obs;
  RxString searchKeyword = "".obs;
  RxList<SDoctorData> newData = <SDoctorData>[].obs;
  RxBool isSearching = false.obs;
  RxBool isSearchDataLoaded = false.obs;
  RxBool isLoadingMore = false.obs;

  RxString userId = "".obs;
  RxBool isLoggedIn = false.obs;
  RxBool isDataLoaded = false.obs;
  RxBool isErrorInLoading = false.obs;

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

  final incomingCallManager = Get.put(IncomingManageController());

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    isLoggedIn.value =
        StorageService.readData(key: LocalStorageKeys.isLoggedIn) ?? false;
    userId.value = StorageService.readData(key: LocalStorageKeys.userId) ?? "";
    if (isLoggedIn.value) {
      call_3in1_api();
    } else if (varSpecialityList.isEmpty && varBannerList.isEmpty) {
      call_3in1_api();
    } else {
      list.clear();
      bannerList.clear();
      list.value = varSpecialityList;
      bannerList.value = varBannerList;
      isDataLoaded.value = true;
    }

    if (StorageService.readData(key: LocalStorageKeys.callSessionCS) != null) {
      dialog();
    }

    if (Platform.isAndroid) {
      _getLocationStart();
    } else {
      _getLocationStartIOS();
    }
    scrollController2.addListener(() {
      if (scrollController2.position.pixels ==
          scrollController2.position.maxScrollExtent) {
        loadMoreNearbyDoctorData();
      }
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMoreFunc();
      }
    });
  }

  RxBool isErrorInLoadDoctorData = false.obs;
  RxBool isDoctorDataLoaded = false.obs;
  RxString nextUrlDoctor = "".obs;

  RxList<DoctorModel> list2 = <DoctorModel>[].obs;

  RxString lat = "".obs;
  RxString lon = "".obs;

  void _getLocationStart() async {
    isErrorInLoadDoctorData.value = false;
    isDoctorDataLoaded.value = false;
    var status = await Permission.location.status;
    if (status.isDenied) {
      await [Permission.location].request();
    }
    status = await Permission.location.status;

    if (status.isGranted) {
      // Notification permission request disabled
      // if (Platform.isAndroid) {
      //   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      //       FlutterLocalNotificationsPlugin();
      //   flutterLocalNotificationsPlugin
      //       .resolvePlatformSpecificImplementation<
      //           AndroidFlutterLocalNotificationsPlugin>()
      //       ?.requestPermission();
      // }
      if (longitude.isEmpty || latitude.isEmpty) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        callApi(latitude: position.latitude, longitude: position.longitude);
      } else {
        callApi(
          latitude: double.parse(latitude),
          longitude: double.parse(longitude),
        );
      }
    } else if (status.isPermanentlyDenied) {
      messageDialog('permission_not_granted'.tr, "permission_not".tr);
      isErrorInLoadDoctorData.value = true;
      return;
    } else if (status.isDenied) {
      messageDialog('permission_not_granted'.tr, "permission_not".tr);
      isErrorInLoadDoctorData.value = true;
    }
  }

  void _getLocationStartIOS() async {
    isErrorInLoadDoctorData.value = false;
    isDoctorDataLoaded.value = false;

    LocationPermission status = await Geolocator.requestPermission();

    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }
    status = await Geolocator.requestPermission();

    if (status == LocationPermission.whileInUse ||
        status == LocationPermission.always) {
      // Notification permission request disabled
      // if (Platform.isAndroid) {
      //   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      //       FlutterLocalNotificationsPlugin();
      //   flutterLocalNotificationsPlugin
      //       .resolvePlatformSpecificImplementation<
      //           AndroidFlutterLocalNotificationsPlugin>()
      //       ?.requestPermission();
      // }
      if (longitude.isEmpty || latitude.isEmpty) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        callApi(latitude: position.latitude, longitude: position.longitude);
      } else {
        callApi(
          latitude: double.parse(latitude),
          longitude: double.parse(longitude),
        );
      }
    } else if (status == LocationPermission.deniedForever) {
      messageDialog('permission_not_granted'.tr, "permission_not".tr);
      isErrorInLoadDoctorData.value = true;
      return;
    } else if (status == LocationPermission.denied) {
      messageDialog('permission_not_granted'.tr, "permission_not".tr);
      isErrorInLoadDoctorData.value = true;
    }
  }

  callApi({double? latitude, double? longitude}) async {
    try {
      isErrorInLoadDoctorData.value = false;

      list2.clear();
      lat.value = latitude.toString();
      lon.value = longitude.toString();

      // Fetch all doctors from Supabase with all necessary fields
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
            avg_rating,
            number_review,
            numb_session,
            fcm_token,
            updated_at
          ''')
          .order('full_name', ascending: true)
          .limit(100);

      // Convert response to DoctorModel objects
      for (var doctor in response) {
        final doctorModel = DoctorModel.fromJson(doctor);
        loggerNoStack.i('Loaded doctor: ${doctorModel.toString()}');
        list2.add(doctorModel);
      }

      isDoctorDataLoaded.value = true;
      nextUrlDoctor.value = "null";
    } catch (e) {
      print('Error fetching doctors: $e');
      isErrorInLoadDoctorData.value = true;
      messageDialog('error'.tr, 'unable_to_load_data'.tr);
    }
  }

  messageDialog(String s1, String s2) {
    customDialog(
      s1: s1,
      s2: s2,
      onPressed: () async {
        if (Platform.isAndroid) {
          var status = await Permission.location.status;
          if (!status.isGranted && s1 == 'permission_not_granted'.tr) {
            Map<Permission, PermissionStatus> statuses = await [
              Permission.location,
            ].request();

            if (statuses[Permission.location]!.isGranted) {
              _getLocationStart();
            }
          }
        } else {
          LocationPermission status = await Geolocator.requestPermission();
          if (!(status == LocationPermission.whileInUse ||
                  status == LocationPermission.always) &&
              s1 == 'permission_not_granted'.tr) {
            status = await Geolocator.requestPermission();

            if ((status == LocationPermission.whileInUse ||
                status == LocationPermission.always)) {
              _getLocationStart();
            }
          }
        }

        Get.back();
      },
    );
  }

  loadMoreNearbyDoctorData() async {
    // No longer needed - Supabase loads all doctors at once
    // Pagination can be implemented later if needed
    return;
  }

  call_3in1_api() async {
    try {
      isErrorInLoading.value = false;

      // Fetch banners from Supabase

      // Fetch specialities from Supabase
      final specialitiesResponse = await supabaseHelper.client
          .from('specializations')
          .select('id, name')
          .order('name', ascending: true);

      // Parse banners

      // Parse specialities
      List<SpecialityData> fetchedSpecialities = [];
      fetchedSpecialities = specialitiesResponse
          .map((speciality) => SpecialityData.fromJson(speciality))
          .toList();

      // Update lists if data has changed
      if (!listEquals(fetchedSpecialities, list)) {
        list.clear();
        bannerList.clear();
        list.value = fetchedSpecialities;
      }

      varSpecialityList.clear();
      varBannerList.clear();
      varSpecialityList.addAll(list);

      // Fetch appointments if user is logged in
      if (isLoggedIn.value && userId.value.isNotEmpty) {
        final appointmentsResponse = await supabaseHelper.client
            .from('bookings')
            .select('''
              id,
              doctor_id,
              booking_date,
              booking_time,
              status,
              doctors!doctor_id (
                full_name,
                email,
                phone_number,
                specialization,
                profile_img_url
              )
            ''')
            .eq('patient_id', userId.value)
            .eq('status', 'confirmed')
            .order('booking_date', ascending: true)
            .order('booking_time', ascending: true);

        appointmentList.clear();
        for (var booking in appointmentsResponse) {
          final doctorData = booking['doctors'];

          // Convert Supabase booking to Appointment model
          final appointment = Appointment(
            id: booking['id'] is int
                ? booking['id']
                : int.tryParse(booking['id']?.toString() ?? ''),
            doctorId: booking['doctor_id'] is int
                ? booking['doctor_id']
                : int.tryParse(booking['doctor_id']?.toString() ?? ''),
            date: booking['booking_date']?.toString(),
            slot: booking['booking_time']?.toString(),
            phone: doctorData?['phone_number']?.toString(),
            departmentName: doctorData?['specialization']?.toString(),
            doctorls: doctorData != null
                ? Doctorls(
                    name: doctorData['full_name']?.toString(),
                    email: doctorData['email']?.toString(),
                    phoneno: doctorData['phone_number']?.toString(),
                    image: doctorData['profile_img_url']?.toString(),
                  )
                : null,
          );
          appointmentList.add(appointment);
        }
      }

      isDataLoaded.value = true;
    } catch (e) {
      print('Error in call_3in1_api: $e');
      isErrorInLoading.value = true;
    }
  }

  loadMoreFunc() async {
    if (nextUrl.value == "null") {
      return;
    }
    isLoadingMore.value = true;
    final response = await get(
      Uri.parse("${nextUrl.value}&term=${searchKeyword.value}"),
    ).timeout(const Duration(seconds: Apis.timeOut));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      searchDoctorClass = SearchDoctorClass.fromJson(jsonResponse);
      newData.addAll(searchDoctorClass?.data?.doctorData ?? []);
      isLoadingMore.value = false;
      nextUrl.value = searchDoctorClass!.data!.nextPageUrl ?? "null";
    }
  }

  onChanged(String value) async {
    if (value.isEmpty) {
      newData.clear();
      isSearching.value = false;
      pageController.previousPage(
        duration: const Duration(milliseconds: 850),
        curve: Curves.linear,
      );
    } else {
      if (!isSearching.value) {
        isSearching.value = true;
        pageController.nextPage(
          duration: const Duration(milliseconds: 850),
          curve: Curves.linear,
        );
        await Future.delayed(const Duration(milliseconds: 850));
      }
      isSearchDataLoaded.value = false;
      final response =
          await get(
            Uri.parse("${Apis.ServerAddress}/api/searchdoctor?term=$value"),
          ).timeout(const Duration(seconds: Apis.timeOut)).catchError((e) {
            isSearchDataLoaded.value = true;
          });
      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          searchDoctorClass = SearchDoctorClass.fromJson(jsonResponse);
          newData.clear();
          newData.addAll(searchDoctorClass!.data!.doctorData!);
          nextUrl.value = searchDoctorClass!.data!.nextPageUrl.toString();
          isSearchDataLoaded.value = true;
        } catch (e) {
          isSearchDataLoaded.value = true;
        }
      } else {
        isSearchDataLoaded.value = true;
      }
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    scrollController2.dispose();
    scrollController.dispose();
  }
}
