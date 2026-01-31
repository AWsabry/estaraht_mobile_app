import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/widgets/pdf_viewer_screen.dart';
import 'package:videocalling/features/auth/doctor_login_binding.dart';
import 'package:videocalling/features/auth/doctor_register_binding.dart';
import 'package:videocalling/features/auth/forget_password_binding.dart';
import 'package:videocalling/features/auth/otp_binding.dart';
import 'package:videocalling/features/auth/patient_login_binding.dart';
import 'package:videocalling/features/auth/patient_register_binding.dart';
import 'package:videocalling/features/auth/pages/under_review_screen.dart';
import 'package:videocalling/features/auth/pages/account_rejected_screen.dart';
import 'package:videocalling/features/auth/controllers/review_status_controller.dart';
import 'package:videocalling/features/doctor/appointments/dall_appointments_binding.dart';
import 'package:videocalling/features/doctor/appointments/dappointment_details_binding.dart';
import 'package:videocalling/features/doctor/appointments/pages/appointment_detail_page.dart';
import 'package:videocalling/features/doctor/appointments/pages/appointments_list_page.dart';
import 'package:videocalling/features/doctor/availability/add_holiday_binding.dart';
import 'package:videocalling/features/doctor/availability/davailability_management_binding.dart';
import 'package:videocalling/features/doctor/availability/pages/availability_page.dart';
import 'package:videocalling/features/doctor/availability/pages/holiday_page.dart';
import 'package:videocalling/features/doctor/finance/add_bank_details_binding.dart';
import 'package:videocalling/features/doctor/finance/doctor_choose_plan_binding.dart';
import 'package:videocalling/features/doctor/finance/income_report_binding.dart';
import 'package:videocalling/features/doctor/finance/pages/bank_details_page.dart';
import 'package:videocalling/features/doctor/finance/pages/choose_plan_page.dart';
import 'package:videocalling/features/doctor/finance/pages/income_report_page.dart';
import 'package:videocalling/features/doctor/finance/pages/subscription_page.dart';
import 'package:videocalling/features/doctor/finance/subscription_list_binding.dart';
import 'package:videocalling/features/doctor/more/dmy_photo_viewer.dart';
import 'package:videocalling/features/doctor/more/dmy_photo_viewer_binding.dart';
import 'package:videocalling/features/doctor/more/search_medicine_binding.dart';
import 'package:videocalling/features/doctor/more/search_medicine_screen.dart';
import 'package:videocalling/features/doctor/profile/change_password_binding.dart';
import 'package:videocalling/features/doctor/profile/doctor_edit_profile_binding.dart';
import 'package:videocalling/features/doctor/profile/pages/change_password_page.dart';
import 'package:videocalling/features/doctor/profile/pages/edit_profile_page.dart';
import 'package:videocalling/features/doctor/profile/pages/step_three_page.dart';
import 'package:videocalling/features/doctor/profile/step_three_details_binding.dart';
import 'package:videocalling/features/doctor/tabs/pages/tabs_page.dart';
import 'package:videocalling/features/doctor/tabs/tab_screen_binding.dart';
import 'package:videocalling/features/patient/appointments/make_appointment_binding.dart';
import 'package:videocalling/features/patient/appointments/pages/appointment_detail_page.dart';
import 'package:videocalling/features/patient/appointments/pages/appointments_list_page.dart';
import 'package:videocalling/features/patient/appointments/pages/make_appointment_page.dart';
import 'package:videocalling/features/patient/appointments/pages/pdf_viewer_page.dart';
import 'package:videocalling/features/patient/appointments/pdf_viewer_binding.dart';
import 'package:videocalling/features/patient/appointments/uall_appointments_binding.dart';
import 'package:videocalling/features/patient/appointments/uappointment_detail_binding.dart';
import 'package:videocalling/features/patient/doctors/dall_nearby_binding.dart';
import 'package:videocalling/features/patient/doctors/doctor_detail_binding.dart';
import 'package:videocalling/features/patient/doctors/dsearch_binding.dart';
import 'package:videocalling/features/patient/doctors/in_demande_doctor_binding.dart';
import 'package:videocalling/features/patient/doctors/pages/doctor_detail_page.dart';
import 'package:videocalling/features/patient/doctors/pages/doctor_search_page.dart';
import 'package:videocalling/features/patient/doctors/pages/indemand_doctors_page.dart';
import 'package:videocalling/features/patient/doctors/pages/nearby_doctors_page.dart';
import 'package:videocalling/features/patient/doctors/pages/review_page.dart';
import 'package:videocalling/features/patient/doctors/pages/speciality_doctors_page.dart';
import 'package:videocalling/features/patient/doctors/pages/speciality_page.dart';
import 'package:videocalling/features/patient/doctors/review_binding.dart';
import 'package:videocalling/features/patient/doctors/speciality_binding.dart';
import 'package:videocalling/features/patient/doctors/speciality_doctor_binding.dart';
import 'package:videocalling/features/patient/more/about_us_binding.dart';
import 'package:videocalling/features/patient/more/notification_binding.dart';
import 'package:videocalling/features/patient/more/pages/about_us_page.dart';
import 'package:videocalling/features/patient/more/pages/notification_page.dart';
import 'package:videocalling/features/patient/more/pages/report_issue_page.dart';
import 'package:videocalling/features/patient/more/pages/terms_page.dart';
import 'package:videocalling/features/patient/more/report_issue_binding.dart';
import 'package:videocalling/features/patient/more/term_and_condition_binding.dart';
import 'package:videocalling/features/patient/payment/pages/payment_page.dart';
import 'package:videocalling/features/patient/payment/payment_binding.dart';
import 'package:videocalling/features/patient/payment_plans/pages/payment_plans_page.dart';
import 'package:videocalling/features/patient/payment_plans/payment_plans_binding.dart';
import 'package:videocalling/features/patient/profile/pages/profile_page.dart';
import 'package:videocalling/features/patient/profile/pages/profile_parameters_page.dart';
import 'package:videocalling/features/patient/profile/profile_parameters_binding.dart';
import 'package:videocalling/features/patient/profile/user_edit_profile_binding.dart';
import 'package:videocalling/features/patient/tabs/binding/patient_tab_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initialRoute = Routes.splashScreen;

  static final routes = [
    GetPage(
      name: _Paths.splashScreen,
      page: () => Builder(builder: (context) => const SplashScreen()),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.languageSelectionScreen,
      page: () => const LanguageSelectionScreen(),
    ),
    GetPage(
      name: _Paths.therapistOnboardingScreen,
      page: () => const TherapistOnboardingScreen(),
    ),
    GetPage(
      name: _Paths.patientOnboardingScreen,
      page: () => const PatientOnboardingScreen(),
    ),
    GetPage(
      name: _Paths.roleSelectionScreen,
      page: () => const RoleSelectionScreen(),
    ),
    GetPage(
      name: _Paths.onboardingScreen,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingController>(() => OnboardingController());
      }),
    ),
    GetPage(
      name: _Paths.doctorTabScreen,
      page: () => const DoctorTabsScreen(),
      binding: TabScreenBinding(),
    ),
    GetPage(
      name: _Paths.videoPlayerScreen,
      page: () => MyVideoPlayer(),
      binding: MyVideoPlayerBinding(),
    ),
    GetPage(
      name: _Paths.photoViewerScreen,
      page: () => MyPhotoViewer(),
      binding: MyPhotoViewerBinding(),
    ),
    GetPage(
      name: _Paths.chatScreen,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.uAppointmentPdfScreen,
      page: () => AppointmentDetailsScreenPdf(),
      binding: AppointmentDetailsScreenPdfBinding(),
    ),
    GetPage(
      name: _Paths.incomingCallScreen,
      page: () => IncomingCallScreen(),
      binding: IncomingCallBinding(),
    ),

    /// doctor side screen
    GetPage(
      name: _Paths.doctorRegisterScreen,
      page: () => const RegisterAsDoctor(),
      binding: DoctorRegisterBinding(),
    ),
    GetPage(
      name: _Paths.chooseYourPlanScreen,
      page: () => DoctorChooseYourPlanScreen(),
      binding: DoctorChooseYourPlanBinding(),
    ),
    GetPage(
      name: _Paths.dMyPhotoViewerScreen,
      page: () => DMyPhotoView(),
      binding: DMyPhotoViewBinding(),
    ),
    GetPage(
      name: _Paths.dChangePasswordScreen,
      page: () => ChangePassword(),
      binding: DChangePasswordBinding(),
    ),
    GetPage(
      name: _Paths.dSubscriptionListScreen,
      page: () => SubscriptionListScreen(),
      binding: SubscriptionListBinding(),
    ),
    GetPage(
      name: _Paths.dIncomeReportScreen,
      page: () => IncomeReportScreen(),
      binding: IncomeReportBinding(),
    ),
    GetPage(
      name: _Paths.dBankDetailsScreen,
      page: () => BankDetailScreen(),
      binding: BankDetailBinding(),
    ),
    GetPage(
      name: _Paths.dAllAppointmentsScreen,
      page: () => DoctorAllAppointments(),
      binding: DAllAppointmentsBinding(),
    ),
    GetPage(
      name: _Paths.dAppointmentDetailScreen,
      page: () => DoctorAppointmentDetails(),
      binding: DAppointmentDetailsBinding(),
    ),
    GetPage(
      name: _Paths.dSearchMedicineScreen,
      page: () => SearchMedicineScreen(),
      binding: SearchMedicineBinding(),
    ),
    GetPage(
      name: _Paths.dStepThreeDetailScreen,
      page: () => StepThreeDetailsScreen(),
      binding: StepThreeDetailsBinding(),
    ),
    GetPage(
      name: _Paths.dHolidayManageScreen,
      page: () => ManageHolidayScreen(),
      binding: HolidayManageBinding(),
    ),
    GetPage(
      name: _Paths.dAvailabilityManagementScreen,
      page: () => const DAvailabilityManagementScreen(),
      binding: DAvailabilityManagementBinding(),
    ),
    // i added this
    GetPage(
      name: _Paths.doctorLoginScreen,
      page: () => LoginAsDoctor(),
      binding: DoctorLoginBinding(),
    ),

    GetPage(
      name: Routes.userTabScreen,
      page: () => const PatientTabsScreen(),
      binding: PatientTabsBinding(),
    ),
    GetPage(
      name: _Paths.notificationScreen,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.profileParametersScreen,
      page: () => const ProfileParametersScreen(),
      binding: ProfileParametersBinding(),
    ),
    GetPage(
      name: _Paths.termsAndConditionScreen,
      page: () => TermAndConditions(),
      binding: TermAndConditionsBinding(),
    ),
    GetPage(
      name: _Paths.aboutUSScreen,
      page: () => AboutUSScreen(),
      binding: AboutUSBinding(),
    ),
    GetPage(
      name: _Paths.reportIssuesScreen,
      page: () => ReportIssuesScreen(),
      binding: ReportIssueBinding(),
    ),
    GetPage(
      name: _Paths.editProfileScreen,
      page: () => UserEditProfile(),
      binding: UserEditBinding(),
    ),
    GetPage(
      name: _Paths.specialityScreen,
      page: () => SpecialityScreen(),
      binding: SpecialityBinding(),
    ),
    GetPage(
      name: _Paths.specialityDoctorScreen,
      page: () => SpecialityDoctorScreen(),
      binding: SpecialityDoctorBinding(),
    ),
    GetPage(
      name: _Paths.indemandDoctorScreen,
      page: () => const IndemandDoctorScreen(),
      binding: InDemandeDoctorBinding(),
    ),
    GetPage(
      name: _Paths.doctorDetailScreen,
      page: () => DoctorDetailScreen(),
      binding: DoctorDetailBinding(),
    ),
    GetPage(
      name: _Paths.doctorReviewScreen,
      page: () => ReviewsScreen(),
      binding: ReviewBinding(),
    ),
    GetPage(
      name: _Paths.forgetPasswordScreen,
      page: () => ForgetPassword(),
      binding: ForgetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.loginUserScreen,
      page: () => LoginAsUser(),
      binding: UserLoginBinding(),
    ),

    /// i added this
    GetPage(
      name: _Paths.userPaymentScreen,
      page: () => const PaymentScreen(),
      binding: PaymentBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.paymentPlansScreen,
      page: () => const PaymentPlansPage(),
      binding: PaymentPlansBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.planPaymentScreen,
      page: () => const PaymentScreen(), // Reuse existing payment screen
      binding: PaymentBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),

    // Add this to your routes list
    GetPage(
      name: _Paths.doctorEditProfileScreen,
      page: () => DoctorProfile(),
      binding: DoctorProfileBinding(),
    ),

    // Inside routes list
    GetPage(
      name: _Paths.doctorEditProfileScreen,
      page: () => DoctorProfile(),
      binding: DoctorProfileBinding(),
    ),

    GetPage(
      name: _Paths.makeAppointmentScreen,
      page: () => MakeAppointment(),
      binding: MakeAppointmentBinding(),
    ),
    GetPage(
      name: _Paths.inAppWebViewScreen,
      page: () => InAppWebViewScreen(),
      binding: InAppWebViewBinding(),
    ),
    GetPage(
      name: _Paths.patientRegisterScreen,
      page: () => const RegisterAsPatient(),
      binding: RegisterPatientBinding(),
    ),
    GetPage(
      name: _Paths.uAppointmentDetailScreen,
      page: () => UserAppointmentDetailsScreen(),
      binding: UserAppointmentDetailsBinding(),
    ),
    GetPage(
      name: _Paths.uAllAppointmentsScreen,
      page: () => UAllAppointments(),
      binding: UAllAppointmentsBinding(),
    ),
    GetPage(
      name: _Paths.dAllNearbyScreen,
      page: () => DAllNearbyScreen(),
      binding: DAllNearbyBinding(),
    ),
    GetPage(
      name: _Paths.dSearchScreen,
      page: () => const DoctorSearchScreen(),
      binding: DoctorSearchBinding(),
    ),

    GetPage(
      name: _Paths.otpScreen,
      page: () => const OtpScreen(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: _Paths.underReviewScreen,
      page: () => const UnderReviewScreen(),
      binding: ReviewStatusBinding(),
    ),
    GetPage(
      name: _Paths.accountRejectedScreen,
      page: () => const AccountRejectedScreen(),
    ),
    GetPage(
      name: '/session-pdf-viewer',
      page: () => const PdfViewerScreen(),
    ),
  ];
}
