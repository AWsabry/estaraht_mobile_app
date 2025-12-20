class Apis {
  static const int timeOut = 5;

  // static const String ServerAddress =
  //     'http://192.168.1.230/rutik/live/bookappointment';
  static const String ServerAddress = 'https://app.estaraht.com';

  /// image paths
  static const String IMAGE = "$ServerAddress/public/upload/banner/";
  static const String specialityImagePath =
      "$ServerAddress/public/upload/services/";
  static const String reportImagePath =
      "$ServerAddress/public/upload/ap_img_up/";
  static const String chatMediaPath = "$ServerAddress/public/upload/chat/";
  static const String doctorImagePath = "$ServerAddress/public/upload/doctors/";
  static const String userImagePath = "$ServerAddress/public/upload/profile/";

  static const String SUCCESS_PAYMENT_URL = "$ServerAddress/payment_success";
  static const String FAIL_PAYMENT_URL = "$ServerAddress/payment_failed";
}
