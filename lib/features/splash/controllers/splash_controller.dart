import 'package:logger/web.dart';
import 'package:videocalling/core/config/app_imports.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print('Splash controller initialized');
    checkUserStatus();
  }

  void checkUserStatus() {
    Timer(const Duration(seconds: 3), () {
      // Navigate based on user status
      if (StorageService.readData(key: LocalStorageKeys.isLoggedIn) == true) {
        bool isDoctor =
            StorageService.readData(key: LocalStorageKeys.isLoggedInAsDoctor) ??
            false;
        if (isDoctor) {
          Get.offAllNamed(Routes.doctorTabScreen);
        } else {
          Get.offAllNamed(Routes.userTabScreen);
        }
      } else {
        final box = GetStorage();
        final appLang = box.read('app_language') == null;
        Logger().i('appLang: $appLang');
        if (appLang) {
          Get.offAllNamed(Routes.languageSelectionScreen);
          return;
        }
        Get.offAllNamed(Routes.roleSelectionScreen);
      }
    });
  }
}
