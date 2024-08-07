import 'package:flutter/material.dart';
import 'package:monlamai_app/screens/home.dart';
import 'package:monlamai_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';

// light bg color
const lightBgColor = Color(0xFFF2F2F2);
const lightBtnBgColor = Color(0xFF444444);
const lightBtnTextColor = Color(0xFFFFFFFF);

// dark bg color
const darkBgColor = Color(0xFF202020);
const darkBtnBgColor = Color(0xFF444444);
const darkBtnTextColor = Color(0xFFFFFFFF);

// light theme
final lightTheme = ThemeData().copyWith(
  appBarTheme: const AppBarTheme(
    backgroundColor: lightBgColor,
    foregroundColor: Color.fromRGBO(24, 24, 24, 100),
    titleTextStyle: TextStyle(
      color: Color.fromRGBO(24, 24, 24, 100),
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
      backgroundColor: lightBtnBgColor,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
    ),
  ),
  brightness: Brightness.light,
);

// dark theme
final darkTheme = ThemeData.dark().copyWith(
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
    ),
  ),
  brightness: Brightness.dark,
);

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monlam AI App',
      theme: Provider.of<ThemeProvider>(context).themeData,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
