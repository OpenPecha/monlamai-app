import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/auth/auth_service.dart';
import 'package:monlamai_app/providers/shared_preferences_provider.dart';
import 'package:monlamai_app/providers/theme_provider.dart';
import 'package:monlamai_app/screens/home.dart';
import 'package:monlamai_app/screens/login.dart';
import 'package:monlamai_app/theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

// with Riverpod scope
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'Monlam AI',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? darkMode : lightMode,
      home: Root(),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  UserProfile? profile;
  bool isLoading = true;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    initAuth();
  }

  void initAuth() async {
    try {
      final userProfile = await authService.init();
      setState(() {
        profile = userProfile;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error during authentication: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return profile != null ? HomeScreen() : LoginScreen();
  }
}
