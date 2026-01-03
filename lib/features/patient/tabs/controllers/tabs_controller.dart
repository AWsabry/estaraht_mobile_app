import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/doctors/pages/indemand_doctors_page.dart';
import 'package:videocalling/features/patient/more/pages/more_page.dart';
import 'package:videocalling/features/patient/consultations/pages/consultations_page.dart';
import 'package:videocalling/features/patient/payment_plans/pages/payment_plans_page.dart';

class PatientTabController extends GetxController {
  RxInt currentTabIndex = 0.obs;
  RxInt index = 0.obs; // Added missing index property

  @override
  void onInit() {
    super.onInit();
    initializeServices();
  }

  void initializeServices() {
    print('Patient tab controller initialized');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleIncomingMessage(message);
    });
  }

  void handleIncomingMessage(RemoteMessage message) {
    print('Incoming message: ${message.data}');
    // Handle incoming call notifications with Agora
    if (message.data.containsKey('call_type')) {
      // Show incoming call screen
      Get.toNamed(Routes.incomingCallScreen, arguments: {
        'sessionId': message.data['session_id'] ?? '',
        'callerName': message.data['caller_name'] ?? 'Unknown',
        'callerImage': message.data['caller_image'] ?? '',
        'callType': int.tryParse(message.data['call_type'] ?? '1') ?? CallType.VIDEO_CALL,
      });
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
        return UserHomeScreen(); // Patient home screen
      case 1:
        return const IndemandDoctorScreen(); // Doctors screen
      case 2:
        return const ConsultationsPage(); // Consultations screen with Appointments & Chat tabs
      case 3:
        return const PaymentPlansPage(); // Payment plans screen
      case 4:
        return MoreScreen(); // Settings/more screen
      default:
        return UserHomeScreen();
    }
  }
}
