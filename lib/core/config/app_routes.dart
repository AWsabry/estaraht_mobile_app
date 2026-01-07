part of 'routes.dart';

abstract class Routes {
  Routes._();

  static const splashScreen = _Paths.splashScreen;

  static const roleSelectionScreen = _Paths.roleSelectionScreen;
  static const therapistOnboardingScreen = _Paths.therapistOnboardingScreen;

  static const onboardingScreen = _Paths.onboardingScreen;

  static const languageSelectionScreen = _Paths.languageSelectionScreen;
  static const patientOnboardingScreen = _Paths.patientOnboardingScreen;

  static const doctorTabScreen = _Paths.doctorTabScreen;
  static const photoViewerScreen = _Paths.photoViewerScreen;
  static const videoPlayerScreen = _Paths.videoPlayerScreen;
  static const chatScreen = _Paths.chatScreen;
  static const incomingCallScreen = _Paths.incomingCallScreen;
  static const callScreen = _Paths.callScreen;

  /// doctor side screen
  static const doctorLoginScreen = _Paths.doctorLoginScreen;
  static const doctorRegisterScreen = _Paths.doctorRegisterScreen;
  static const otpScreen = _Paths.otpScreen;
  static const chooseYourPlanScreen = _Paths.chooseYourPlanScreen;
  static const dMyPhotoViewerScreen = _Paths.dMyPhotoViewerScreen;
  static const dChangePasswordScreen = _Paths.dChangePasswordScreen;
  static const dSubscriptionListScreen = _Paths.dSubscriptionListScreen;
  static const dIncomeReportScreen = _Paths.dIncomeReportScreen;
  static const dBankDetailsScreen = _Paths.dBankDetailsScreen;
  static const dAllAppointmentsScreen = _Paths.dAllAppointmentsScreen;
  static const dAppointmentDetailScreen = _Paths.dAppointmentDetailScreen;
  static const dSearchMedicineScreen = _Paths.dSearchMedicineScreen;
  static const dStepThreeDetailScreen = _Paths.dStepThreeDetailScreen;
  static const dHolidayManageScreen = _Paths.dHolidayManageScreen;
  static const dAvailabilityManagementScreen =
      _Paths.dAvailabilityManagementScreen;

  /// patient side screen
  static const userTabScreen = _Paths.userTabScreen;
  static const notificationScreen = _Paths.notificationScreen;
  static const profileParametersScreen = _Paths.profileParametersScreen;
  static const termsAndConditionScreen = _Paths.termsAndConditionScreen;
  static const aboutUSScreen = _Paths.aboutUSScreen;
  static const reportIssuesScreen = _Paths.reportIssuesScreen;
  static const editProfileScreen = _Paths.editProfileScreen;
  static const specialityScreen = _Paths.specialityScreen;
  static const specialityDoctorScreen = _Paths.specialityDoctorScreen;
  static const doctorDetailScreen = _Paths.doctorDetailScreen;
  static const doctorReviewScreen = _Paths.doctorReviewScreen;
  static const forgetPasswordScreen = _Paths.forgetPasswordScreen;
  static const loginUserScreen = _Paths.loginUserScreen;
  static const makeAppointmentScreen = _Paths.makeAppointmentScreen;
  static const inAppWebViewScreen = _Paths.inAppWebViewScreen;
  static const patientRegisterScreen = _Paths.patientRegisterScreen;
  static const uAppointmentDetailScreen = _Paths.uAppointmentDetailScreen;
  static const uAllAppointmentsScreen = _Paths.uAllAppointmentsScreen;
  static const dAllNearbyScreen = _Paths.dAllNearbyScreen;
  static const dSearchScreen = _Paths.dSearchScreen;
  static const uAppointmentPdfScreen = _Paths.uAppointmentPdfScreen;
  static const userPaymentScreen = _Paths.userPaymentScreen;
  static const paymentPlansScreen = _Paths.paymentPlansScreen;
  static const planPaymentScreen = _Paths.planPaymentScreen;

  static const doctorProfileViewScreen = _Paths.doctorProfileViewScreen;
  static const doctorEditProfileScreen = '/doctor-edit-profile';

  // New: in-demand doctors screen
  static const indemandDoctorScreen = _Paths.indemandDoctorScreen;
}

abstract class _Paths {
  static const doctorProfileViewScreen = '/doctor-profile-view-screen';
  static const userPaymentScreen = '/user-payment-screen';

  static const splashScreen = '/splash-screen';
  static const roleSelectionScreen = '/role-selection-screen';

  static const languageSelectionScreen = '/language-selection-screen';
  static const therapistOnboardingScreen = '/therapist-onboarding-screen';
  static const patientOnboardingScreen = '/patient-onboarding-screen';

  static const onboardingScreen = '/onboarding-screen';
  static const doctorTabScreen = '/doctor-tab-screen';
  static const photoViewerScreen = '/photo-viewer-screen';
  static const videoPlayerScreen = '/video-player-screen';
  static const incomingCallScreen = '/incoming-call-screen';
  static const callScreen = '/call-screen';

  /// doctor side screen
  static const doctorRegisterScreen = '/doctor-register-screen';
  static const doctorLoginScreen = '/doctor-login-screen';
  static const otpScreen = '/otp-screen'; // <-- AJOUTÉ ICI
  static const chooseYourPlanScreen = '/doctor-choose-your-plan-screen';
  static const dMyPhotoViewerScreen = '/doctor-my-photo-viewer-screen';
  static const dChangePasswordScreen = '/doctor-change-password-screen';
  static const dSubscriptionListScreen = '/doctor-subscription-list-screen';
  static const dIncomeReportScreen = '/doctor-income-report-screen';
  static const dBankDetailsScreen = '/doctor-bank-details-screen';
  static const dAllAppointmentsScreen = '/doctor-all-appointments-screen';
  static const dAppointmentDetailScreen = '/doctor-appointment-detail-screen';
  static const dSearchMedicineScreen = '/doctor-search-medicine-screen';
  static const dStepThreeDetailScreen = '/doctor-step-three-detail-screen';
  static const dHolidayManageScreen = '/doctor-holiday-manage-screen';
  static const dAvailabilityManagementScreen =
      '/doctor-availability-management-screen';

  /// patient side screen
  static const userTabScreen = '/user-tab-screen';
  static const notificationScreen = '/notification-screen';
  static const profileParametersScreen = '/profile-parameters-screen';
  static const termsAndConditionScreen = '/terms-and-condition-screen';
  static const aboutUSScreen = '/about-us-screen';
  static const reportIssuesScreen = '/report-issues-screen';
  static const editProfileScreen = '/edit-profile-screen';
  static const specialityScreen = '/speciality-screen';
  static const specialityDoctorScreen = '/speciality-doctor-screen';
  static const doctorDetailScreen = '/doctor-detail-screen';
  static const doctorReviewScreen = '/doctor-review-screen';
  static const forgetPasswordScreen = '/forget-password-screen';
  static const loginUserScreen = '/login-user-screen';
  static const makeAppointmentScreen = '/make-appointment-screen';
  static const inAppWebViewScreen = '/in-app-web-view-screen';
  static const patientRegisterScreen = '/patient-register-screen';
  static const uAppointmentDetailScreen = '/user-appointment-detail-screen';
  static const uAllAppointmentsScreen = '/user-all-appointments-screen';
  static const dAllNearbyScreen = '/doctor-all-nearby-screen';
  static const dSearchScreen = '/doctor-search-screen';
  static const chatScreen = '/chat-screen';
  static const uAppointmentPdfScreen = '/user-appointment-pdf-screen';
  static const doctorEditProfileScreen = '/doctor-edit-profile-screen';
  static const paymentPlansScreen = '/payment-plans-screen';
  static const planPaymentScreen = '/plan-payment-screen';

  // New: in-demand
  static const indemandDoctorScreen = '/indemand-doctor-screen';
  
  // Session files PDF viewer
  static const sessionPdfViewerScreen = '/session-pdf-viewer';
}
