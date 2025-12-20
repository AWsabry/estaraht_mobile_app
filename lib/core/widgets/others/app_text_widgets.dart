import 'package:videocalling/core/config/app_imports.dart';

class AppTextWidgets {
  // i added this
  static Widget directionAwareText({
    required String text,
    Color? color,
    double? size,
    FontWeight weight = FontWeight.normal,
    TextAlign? textAlign,
  }) {
    final languageController = Get.find<LanguageController>();
    final isRtl = languageController.currentLanguage.value == 'ar';

    return Text(
      text,
      textAlign: textAlign ?? (isRtl ? TextAlign.right : TextAlign.left),
      style: TextStyle(
        fontFamily: AppFontHelper.getFontFamily(),
        fontWeight: weight,
        color: color,
        fontSize: size,
      ),
    );
  }

//
  static Widget boldTextNormal({
    required String text,
    required double size,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.bold,
        fontSize: size,
      ),
    );
  }

  static Widget boldTextWithColor({
    required String text,
    required Color color,
    required double size,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.bold,
        color: color,
        fontSize: size,
      ),
    );
  }

  static Widget regularText({
    required String text,
    required Color color,
    required double size,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.regular,
        color: color,
        fontSize: size,
      ),
    );
  }

  static Widget regularTextWithColor({
    required String text,
    required Color color,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.regular,
        color: color,
      ),
    );
  }

  static Widget regularTextWithSize({
    required String text,
    required double size,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.regular,
        fontSize: size,
      ),
    );
  }

  static Widget mediumText({
    required String text,
    required Color color,
    required double size,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.medium,
        color: color,
        fontSize: size,
      ),
    );
  }

  static Widget mediumTextWithColor({
    required String text,
    required Color color,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.medium,
        color: color,
      ),
    );
  }

  static Widget mediumTextWithSize({
    required String text,
    required double size,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.medium,
        fontSize: size,
      ),
    );
  }

  static Widget semiBoldText({
    required String text,
    required Color color,
    required double size,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.semiBold,
        color: color,
        fontSize: size,
      ),
    );
  }

  static Widget semiBoldTextWithSize({
    required String text,
    required double size,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.semiBold,
        fontSize: size,
      ),
    );
  }

  static Widget semiBoldTextWithColor({
    required String text,
    required Color color,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.semiBold,
        color: color,
      ),
    );
  }

  static Widget blackText({
    required String text,
    required Color color,
    required double size,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.black,
        color: color,
        fontSize: size,
      ),
    );
  }

  static Widget blackTextWithSize({
    required String text,
    required double size,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.black,
        fontSize: size,
      ),
    );
  }

  static Widget blackTextWithColor({
    required String text,
    required Color color,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFontStyleTextStrings.black,
        color: color,
      ),
    );
  }
}

class AppFontStyleTextStrings {
  /// Returns the font family based on current language
  static String get _fontFamily => AppFontHelper.getFontFamily();

  /// bold and w700
  static String get bold => _fontFamily;

  /// w900
  static String get black => _fontFamily;

  /// w500
  static String get medium => _fontFamily;

  /// w600
  static String get semiBold => _fontFamily;

  /// w400 and normal
  static String get regular => _fontFamily;

  /// w300
  static String get light => _fontFamily;
}
