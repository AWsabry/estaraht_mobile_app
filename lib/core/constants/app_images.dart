class AppImages {
  /// splash screen
  static const String splashBg = "assets/splash/splash_bg.svg";
  static const String splashIcon = "assets/splash/splash_icon.svg";

  /// App Bar
  static const String appBarIcon = "assets/icons/app_bar.svg";
  static const String appBadging = "assets/icons/app_badging.svg";
  static const String appAccountCircle = "assets/icons/account_circle.svg";

  /// oppointment screen
  static const String appointmentEmpty = "assets/icons/opp_error.svg";
  static const String appointmentTime = "assets/icons/timer.svg";

  /// Doctor Detail screen
  static const String workIcon = "assets/icons/work.svg";
  static const String groupOfPeaple = "assets/icons/group_add.svg";
  static const String reviewsIcon = "assets/icons/cards_star.svg";

  //HOME
  static const String videoCallIcon = "assets/icons/missed_video_call.svg";

  /// doctor more
  static const String logoutIcon = "assets/more_screen/logout.svg";
  static const String availabilityIcon = "assets/more_screen/alarm.svg";
  static const String paymentsIcon = "assets/more_screen/payments.svg";
  static const String manageProfileIcon =
      "assets/more_screen/bookmark_manager.svg";
  static const String passwordIcon = "assets/more_screen/password.svg";
  static const String languageIcon = "assets/more_screen/languages-icon.svg";
  static const String aboutUsIcon = "assets/more_screen/about_us.svg";

  /// tabs screen
  static const String tab1Select = "assets/tabs/tab1_select.svg";
  static const String tab1Unselect = "assets/tabs/tab1_unselect.svg";
  static const String tab2Select = "assets/tabs/tab2_select.svg";
  static const String tab2Unselect = "assets/tabs/tab2_unselect.svg";
  static const String tab3dSelect = "assets/tabs/tab3d_select.svg";
  static const String tab3dUnselect = "assets/tabs/tab3d_unselect.svg";
  static const String tab3uSelect = "assets/tabs/tab3u_select.svg";
  static const String tab3uUnselect = "assets/tabs/tab3u_unselect.svg";
  static const String tab4Select = "assets/tabs/tab4_select.svg";
  static const String tab4Unselect = "assets/tabs/tab4_unselect.svg";
  static const String tab5Select = "assets/tabs/tab5_select.png";
  static const String tab5Unselect = "assets/tabs/tab5_unselect.png";
  static const String sliderPlaceholder =
      "assets/home_screen/slider_placeholder.png";
  static const String sliderError = "assets/home_screen/slider_error.png";

  /// patient make appointment screen
  static const String dayActive = "assets/make_appointment/day_active.png";
  static const String dayUnActive = "assets/make_appointment/day_unactive.png";
  static const String timeActive = "assets/make_appointment/time_active.png";
  static const String timeUnActive =
      "assets/make_appointment/time_unactive.png";
  static const String payment = "assets/make_appointment/payments.svg";
  static const String wallet = "assets/make_appointment/wallet.svg";
  static const String paymentVisa = "assets/make_appointment/visa.svg";
  static const String paymentMaster = "assets/make_appointment/master.svg";
  static const String bankily ="assets/logo_bankily.png";

  /// appointment detail screen
  static const String medicineIcon =
      "assets/appointment_detail_screen/medicine.svg";
  static const String reportIcon =
      "assets/appointment_detail_screen/report.svg";
  static const String editIconSvg = "assets/appointment_detail_screen/edit.svg";
  static const String deleteIconSvg =
      "assets/appointment_detail_screen/delete.svg";

  /// patient more screen
  static const String bgImage = "assets/more_screen/bgImage.jpg";
  static const String arrowIcon = "assets/more_screen/detail_arrow.png";
  static const String editIcon = "assets/more_screen/edit.png";
  static const String noChatVector = "assets/more_screen/no chat vector.png";
  static const String noAppointment = "assets/home_screen/no_appointment.png";
  static const String calender = "assets/home_screen/calender.png";
  static const String loginDoctor = "assets/login_screen/login_doctor.png";
  static const String forgetIcon = "assets/login_screen/forgetIcon.png";
  static const String loginIcon = "assets/login_screen/login_icon.png";
  static const String editHomeScreen = "assets/home_screen/edit.png";

  /// patient doctor detail screen
  static const String locationPin = "assets/detail_screen/location_pin.png";
  static const String mapIcon = "assets/detail_screen/map_icon.png";
  static const String starFill = "assets/detail_screen/star_fill.png";
  static const String starNoFill = "assets/detail_screen/star_no_fill.png";
  static const String time = "assets/detail_screen/time.png";

  /// icons
  static const String backIcon = "assets/icons/back.png";
  static const String specialityBg = "assets/more_screen/speciality_bg.png";
  static const String searchIcon = "assets/home_screen/search_icon.png";
  static const String dotsIcon = "assets/more_screen/dots.png";
  static const String defaultDoctor = "assets/default-doctor.svg";
  static const String defaultUser = "assets/default-user.png";
  static const String emailIcon =
      "assets/appointment_detail_screen/email_btn.png";
  static const String phoneIcon =
      "assets/appointment_detail_screen/phone_button.png";
  static const String timeIcon = "assets/appointment_detail_screen/time.png";
  static const String closeIcon = "assets/more_screen/close.png";
  static const String doneIcon = "assets/more_screen/done_icon.png";
  static const String searchIconPng =
      "assets/appointment_detail_screen/search.png";
  static const String dropdownIcon = "assets/home_screen/dropdown.png";
  static const String editYellowBg = "assets/more_screen/edit_yellow_bg.png";
  static const String deleteRectangle = "assets/home_screen/delete_icon.png";

  /// alternative profile image or placeholders
  static const String doctorPlaceholder = "assets/doctor.png";
  static const String femaleDoctorPlaceholder = "assets/female_doctor.png";

  /// Helper method to get placeholder based on gender
  static String getDoctorPlaceholder(String? gender) {
    if (gender != null && gender.toLowerCase() == 'female') {
      return femaleDoctorPlaceholder;
    }
    return doctorPlaceholder;
  }
}
