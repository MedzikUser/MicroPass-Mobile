import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static const int light = 0;
  static const int dark = 1;
}

final lightCustomColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.blue,
  brightness: Brightness.light,
  primary: const Color(0xff1B73E8),
);

final lightCustomTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightCustomColorScheme,
  navigationBarTheme: NavigationBarThemeData(
    labelTextStyle: MaterialStateProperty.all(
      TextStyle(
        color: lightCustomColorScheme.secondary,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
);

final darkCustomColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.blue,
  brightness: Brightness.dark,
  primary: const Color(0xffA5CAFF),
  surface: const Color(0xff1B1A1D),
);

final darkCustomTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkCustomColorScheme,
  navigationBarTheme: NavigationBarThemeData(
    labelTextStyle: MaterialStateProperty.all(
      TextStyle(
        color: darkCustomColorScheme.secondary,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  canvasColor: const Color(0xff1B1A1D),
  scaffoldBackgroundColor: const Color(0xff1B1A1D),
  toggleableActiveColor: const Color(0xffA5CAFF),
  textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
);

final themeCollection = ThemeCollection(
  themes: {
    AppThemes.light: lightCustomTheme,
    AppThemes.dark: darkCustomTheme,
  },
  fallbackTheme: lightCustomTheme,
);
