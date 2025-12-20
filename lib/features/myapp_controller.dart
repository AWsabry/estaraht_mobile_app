import 'package:videocalling/core/config/app_imports.dart';

class MyAppController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Removed ConnectyCube session creation
    print('MyApp controller initialized');
    checkAppState();
  }

  void checkAppState() {
    // App starts with splash screen via initialRoute
    // No need to navigate here - splash controller handles navigation
  }
}
