import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/features/patient/home/models/home_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final languageController = Get.find<LanguageController>();
final bool isArabic = languageController.currentLanguage.value == 'ar';

int PHONE_LENGTH = 8;
int PASS_LENGTH = 6;

String CURRENCY = isArabic ? "أوقية" : "MRU";
String CURRENCY_CODE = "MRU";

// Load from .env
String ServerToken = dotenv.env['FCM_SERVER_TOKEN'] ?? '';

StringChangeNotifier changeNotifier = StringChangeNotifier();

String latitude = "";
String longitude = "";

FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
SharedPreferences? prefs;

final picker = ImagePicker();
final box = GetStorage();
final connect = GetConnect();

NotificationHelper notificationHelper = NotificationHelper();

List<SpecialityData> varSpecialityList = <SpecialityData>[];
List<BannerList> varBannerList = <BannerList>[];

// Load from .env
String stripePublisherKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
String stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';
