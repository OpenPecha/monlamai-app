import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/providers/shared_preferences_provider.dart';
import 'package:monlamai_app/providers/theme_provider.dart';
import 'package:monlamai_app/screens/home.dart';
import 'package:monlamai_app/theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

// with Riverpod scope
void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final currentTheme = ref.watch(themeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'Monlam AI App',
      theme: isDarkMode ? darkMode : lightMode,
      home: const HomeScreen(),
    );
  }
}
