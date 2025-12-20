import 'package:flutter/material.dart';

extension TextThemeCompat on TextTheme {
  TextStyle? get bodyText1 => bodyLarge;
  TextStyle? get bodyText2 => bodyMedium;
  TextStyle? get caption => bodySmall;
  TextStyle? get subtitle1 => titleMedium;
  TextStyle? get subtitle2 => titleSmall;
  TextStyle? get headline5 => headlineSmall;
  TextStyle? get headline6 => titleLarge;
}

extension ThemeDataCompat on ThemeData {
  Color get backgroundColor => colorScheme.surface;
}
