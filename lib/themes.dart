import 'main_menu/main_menu.dart';
import 'package:flutter/material.dart';

class MyThemes {
  static final primary = eclatColor;
  static final primaryColor = eclatColor;

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    primaryColorDark: primaryColor,
    colorScheme: ColorScheme.dark(primary: primary),
    dividerColor: Colors.white,
  );

  static final lightTheme = ThemeData(
    // scaffoldBackgroundColor: Colors.white,
    primaryColorDark: primaryColor,
    colorScheme: ColorScheme.light(primary: primary),
    dividerColor: Colors.grey.shade300,
  );
}
