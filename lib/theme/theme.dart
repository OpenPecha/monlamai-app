import 'package:flutter/material.dart';

// light bg color
const lightBgColor = Color(0xFFF2F2F2);
const lightBtnBgColor = Color(0xFF444444);
const lightBtnTextColor = Colors.black;
const secondContainerColor = Color(0xFFEDEDED);

// dark bg color
const darkBgColor = Color(0xFF202020);
const darkBtnBgColor = Color(0xFF444444);
const darkBtnTextColor = Color(0xFFFFFFFF);
const darkSecondContainerColor = Color(0xFF282828);

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
      surface: lightBgColor,
      primary: lightBtnBgColor,
      secondary: lightBtnTextColor),
  appBarTheme: const AppBarTheme(
    backgroundColor: lightBgColor,
    foregroundColor: Color(0x9C181818),
    titleTextStyle: TextStyle(
      color: Color(0x9C181818),
      fontSize: 18,
      fontWeight: FontWeight.normal,
    ),
  ),
  scaffoldBackgroundColor: lightBgColor,
  cardTheme: const CardTheme(
    color: Color(0xFFFFFFFF),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: lightBtnTextColor,
      backgroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  canvasColor: secondContainerColor,
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: lightBgColor,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
      surface: darkBgColor,
      primary: darkBtnBgColor,
      secondary: darkBtnTextColor),
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBgColor,
    foregroundColor: Color.fromRGBO(255, 255, 255, 100),
    titleTextStyle: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 100),
      fontSize: 18,
      fontWeight: FontWeight.normal,
    ),
  ),
  scaffoldBackgroundColor: darkBgColor,
  cardTheme: const CardTheme(
    color: Color.fromRGBO(48, 48, 48, 100),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: darkBtnTextColor,
      backgroundColor: darkBtnBgColor,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
    ),
  ),
  canvasColor: darkSecondContainerColor,
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: darkBgColor,
  ),
);
