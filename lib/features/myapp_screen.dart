import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videocalling/core/config/app_imports.dart';

class MyApp extends GetView<SplashController> {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyAppController());
    final languageController = Get.find<LanguageController>();

    return Obx(() {
      // Get dynamic font family based on current language
      final fontFamily = AppFontHelper.getFontFamily();

      return SafeArea(
        top: false,
        bottom: true,
        child: ScreenUtilInit(
          designSize: const Size(375, 812), // iPhone X design size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return GetMaterialApp(
              useInheritedMediaQuery: true,
              locale: Locale(languageController.currentLanguage.value),
              initialRoute: AppPages.initialRoute,
              getPages: AppPages.routes,
              defaultTransition: Transition.cupertino,
              transitionDuration: const Duration(milliseconds: 500),
              translations: Words(),
              fallbackLocale: const Locale('en', 'US'),
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                // White theme configuration
                scaffoldBackgroundColor: Colors.white,
                useMaterial3: false,

                // AppBar theme
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.black87),
                  titleTextStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Card theme
                cardTheme: CardThemeData(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                // Button themes
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),

                // Switch theme
                switchTheme: SwitchThemeData(
                  thumbColor: MaterialStateProperty.all(Colors.white),
                  trackColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.grey.shade300;
                    }
                    return Colors.grey.shade200;
                  }),
                ),

                // Time picker theme
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: Colors.white,
                  dayPeriodTextColor: Colors.black87,
                  hourMinuteTextColor: Colors.black87,
                  dialHandColor: Colors.grey.shade300,
                  dialBackgroundColor: Colors.grey.shade100,
                  helpTextStyle: TextStyle(
                    fontFamily: fontFamily,
                    color: Colors.black87,
                  ),
                ),

                // Color scheme
                colorScheme: ColorScheme.light(
                  primary: Colors.grey.shade800,
                  secondary: Colors.grey.shade600,
                  onPrimary: Colors.white,
                  onSecondary: Colors.white,
                  surface: Colors.white,
                  background: Colors.white,
                  error: Colors.redAccent.shade200,
                ),

                // Other color settings
                hintColor: Colors.grey.shade500,
                primaryColor: Colors.grey.shade800,
                primaryColorLight: Colors.grey.shade100,
                primaryColorDark: Colors.grey.shade700,
                disabledColor: Colors.grey.shade300,
                dividerColor: Colors.grey.shade200,

                // Text theme (migrated names)
                textTheme: TextTheme(
                  displayLarge: TextStyle(
                    fontFamily: fontFamily,
                    color: Colors.black87,
                  ),
                  displayMedium: TextStyle(
                    fontFamily: fontFamily,
                    color: Colors.black87,
                  ),
                  displaySmall: TextStyle(
                    fontFamily: fontFamily,
                    color: Colors.black87,
                  ),
                  headlineMedium: TextStyle(
                    fontFamily: fontFamily,
                    color: Colors.black87,
                  ),
                  headlineSmall: TextStyle(
                    fontFamily: fontFamily,
                    color: Colors.black87,
                  ),
                  titleLarge: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  titleMedium: TextStyle(
                    fontFamily: fontFamily,
                    color: Colors.black87,
                  ),
                  titleSmall: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  bodySmall: TextStyle(
                    fontSize: 10,
                    fontFamily: fontFamily,
                    color: Colors.grey.shade600,
                  ),
                  bodyLarge: TextStyle(
                    fontSize: 13,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  bodyMedium: TextStyle(
                    fontSize: 13,
                    fontFamily: fontFamily,
                    color: Colors.black87,
                  ),
                  labelLarge: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'EN'),
                Locale('ar', 'MR'),
                Locale('fr', 'FR'),
              ],
            );
          },
        ),
      );
    });
  }
}
