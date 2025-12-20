import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/more/get_medicine_model.dart';

class AddMedicineToAppointmentController extends GetxController {
  AddMedicineToAppointmentController(
    int length, {
    required this.typeController,
    required this.appointmentID,
    required this.medicineID,
    required this.dosageController,
    required this.selectedValue,
    this.nameController,
    this.oldData,
    List<List<TimeOfDay>>? timeList,
  }) {
    if (timeList != null) {
      this.timeList = timeList;
    } else {
      this.timeList = List.generate(length, (index) => []);
    }
  }

  int? appointmentID;
  List<String> medicineID;
  RxBool? editValue = false.obs;
  String? oldData;

  List<TextEditingController> typeController, dosageController;

  TextEditingController consumeController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  List<List<TimeOfDay>> timeList = [];
  List<TimeOfDay> selectedTime = [];

  void selectTime(TimeOfDay time) {
    selectedTime.add(time);
    update();
  }

  List<String> items = [
    'day_text_1'.tr,
    'day_text_2'.tr,
    'day_text_3'.tr,
    'day_text_4'.tr,
    'day_text_5'.tr,
    'day_text_6'.tr,
    'day_text_7'.tr,
    'day_text_8'.tr,
    'day_text_9'.tr,
    'day_text_10'.tr,
  ];

  List<int> selectedValue;

  addTimeController(BuildContext context, {required int index}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    var pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;
    timeList[index].add(pickedTime);
    update();
  }

  RxBool isLoadingDoctorMedicine = false.obs;

  RxBool checkUpdateValue = false.obs;

  final formKey = GlobalKey<FormState>();

  List<TextEditingController>? nameController;

  GetMedicineMOdel? getMedicineMOdel;

  getMedicalApi({required bool isUpdate}) async {
    isLoadingDoctorMedicine.value = false;
    List<Map<String, dynamic>> map = [];
    if (oldData.toString() != jsonEncode("No Data") &&
        oldData.toString() != "null") {
      map = List<Map<String, dynamic>>.from(jsonDecode(oldData!));
    }
    for (int i = 0; i < timeList.length; i++) {
      if (nameController != null && nameController![i].text.isEmpty) {
        return Fluttertoast.showToast(
          msg: 'search_medicine_error'.tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.WHITE,
          textColor: AppColors.BLACK,
          fontSize: 16.0,
        );
      } else if (typeController[i].text.isEmpty) {
        return Fluttertoast.showToast(
          msg: 'type_error'.tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.WHITE,
          textColor: AppColors.BLACK,
          fontSize: 16.0,
        );
      } else if (dosageController[i].text.isEmpty) {
        return Fluttertoast.showToast(
          msg: 'dosage_error'.tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.WHITE,
          textColor: AppColors.BLACK,
          fontSize: 16.0,
        );
      } else if (timeList[i].isEmpty) {
        return Fluttertoast.showToast(
          msg: 'medicine_time_error'.tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.WHITE,
          textColor: AppColors.BLACK,
          fontSize: 16.0,
        );
      }
      List<Map<String, String>> jsonTimeGroup = [];

      for (var time in timeList[i]) {
        jsonTimeGroup.add({
          "t_time":
              "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
        });
      }
      map.add({
        "medicine_name": nameController![i].text,
        "repeat_days": items[selectedValue[i]].split(" ").first,
        "time": jsonTimeGroup,
        "dosage": dosageController[i].text,
        "type": typeController[i].text,
      });
    }

    customDialog(
      s1: 'reporting_dialog1'.tr,
      s2: 'please_wait_while_processing'.tr,
    );

    Map<String, dynamic> r = {"medicine": map};

    var response = await post(
      Uri.parse("${Apis.ServerAddress}/api/add_medicine_to_app"),
      body: {
        "appointment_id": appointmentID.toString(),
        "medicine_id": jsonEncode(r),
      },
    );

    if (response.statusCode == 200) {
      getMedicineMOdel = GetMedicineMOdel.fromJson(jsonDecode(response.body));
      Get.back();

      customDialog(
        s1: 'success'.tr,
        s2: getMedicineMOdel!.msg.toString(),
        onPressed: () {
          Get.back();
          Get.back();
          if (!isUpdate) {
            Get.back();
          }
        },
      );
      isLoadingDoctorMedicine.value = true;
      update();
    } else {
      isLoadingDoctorMedicine.value = false;
      Get.back();
      customDialog(
        s1: 'error'.tr,
        s2: response.body,
        onPressed: () => Get.back(),
      );
      update();
    }
    Client().close();
  }
}
