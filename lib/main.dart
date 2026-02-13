import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/subscription_expiry_service.dart';

import 'firebase_options.dart';

void main() async {
  // Run everything inside runZonedGuarded to ensure same zone
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Load environment variables FIRST
      await dotenv.load(fileName: ".env");

      final config = ClarityConfig(
        projectId: dotenv.env['CLARITY_PROJECT_ID'] ?? "",
        logLevel: LogLevel
            .None, // Note: Use "LogLevel.Verbose" value while te   sting to debug initialization issues.
      );
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? '',
        anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      );

      // Initialize GetStorage FIRST - this is critical
      if (kDebugMode) {
        print("🚀 App starting - initializing storage");
      }
      await GetStorage.init();

      // DEBUG: Print storage contents at startup
      if (kDebugMode) {
        final box = GetStorage();
        final appLang = box.read('app_language');
        print("🌐 Initial language from storage: $appLang");
      }

      // THEN initialize LanguageController to ensure it can access storage
      final languageController = Get.put(LanguageController(), permanent: true);
      if (kDebugMode) {
        print(
          "🔤 Language controller initialized with: ${languageController.currentLanguage.value}",
        );
      }

      // Initialize SubscriptionExpiryService for checking subscription expiry
      Get.put(SubscriptionExpiryService(), permanent: true);

      // Initialize Firebase
      try {
        if (Firebase.apps.isEmpty) {
          if (Platform.isAndroid) {
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.android,
            );
          } else {
            final app = await Firebase.initializeApp(
              options: DefaultFirebaseOptions.ios,
            );
            print("projectId: ${app.options.projectId}");
            print("appId: ${app.options.appId}");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Firebase already initialized: $e');
        }
      }
      final app = Firebase.app();
      print("🔥 projectId = ${app.options.projectId}");
      // Set up FCM background message handler BEFORE other Firebase services
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize Firebase Crashlytics
      await initializeCrashlytics();
      loggerNoStack.i('🔥 Firebase Crashlytics initialized');

      // Initialize FCM Service
      await FCMService.initialize();
      loggerNoStack.i('🔔 FCM Service initialized');

      // Initialize other services
      notificationHelper.initialize();
      Stripe.publishableKey = stripePublisherKey;

      // Set orientation
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Run your app
      runApp(
        kDebugMode
            ? ClarityWidget(app: const MyApp(), clarityConfig: config)
            : ClarityWidget(app: const MyApp(), clarityConfig: config),
      );
    },
    (error, stackTrace) {
      // Catch any errors not caught by Flutter framework
      logErrorToCrashlytics(
        error,
        stackTrace,
        reason: 'Uncaught error in runZonedGuarded',
        fatal: true,
      );
    },
  );
}
