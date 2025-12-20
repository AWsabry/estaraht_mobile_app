import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/more/search_medicine_controller.dart';

class SearchMedicineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchMedicineController>(() => SearchMedicineController());
  }
}
