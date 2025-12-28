import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/doctor/dashboard/pages/dashboard_page.dart';
import 'package:videocalling/features/doctor/finance/pages/income_report_page.dart';
import 'package:videocalling/features/doctor/more/pages/more_page.dart';
import 'package:videocalling/features/doctor/consultations/pages/consultations_page.dart';

class DoctorTabController extends GetxController {
  RxInt currentTabIndex = 0.obs;
  RxInt index = 0.obs; // Added missing index property

  @override
  void onInit() {
    super.onInit();
    initializeServices();
  }

  void initializeServices() {
    print('Doctor tab controller initialized');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleIncomingMessage(message);
    });
  }

  void handleIncomingMessage(RemoteMessage message) {
    print('Incoming message: ${message.data}');
    // Handle incoming call notifications with Agora
    if (message.data.containsKey('call_type')) {
      // Show incoming call screen
      Get.toNamed(
        Routes.incomingCallScreen,
        arguments: {
          'sessionId': message.data['session_id'] ?? '',
          'callerName': message.data['caller_name'] ?? 'Unknown',
          'callerImage': message.data['caller_image'] ?? '',
          'callType':
              int.tryParse(message.data['call_type'] ?? '1') ??
              CallType.VIDEO_CALL,
        },
      );
    }
  }

  void changeTabIndex(int tabIndex) {
    currentTabIndex.value = tabIndex;
    index.value = tabIndex;
  }

  // Added missing getPage method
  Widget getPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return DoctorDashboard(); // Doctor dashboard/home
      case 1:
        return const DoctorConsultationsPage(); // Consultations screen with Appointments & Chat tabs
      case 2:
        return IncomeReportScreen(); // Financial screen
      case 3:
        return MoreInfoScreen(); // Settings/more screen
      default:
        return DoctorDashboard();
    }
  }

  // Added missing willPopScope method
  Future<bool> willPopScope() async {
    return true; // Allow back navigation
  }
}
