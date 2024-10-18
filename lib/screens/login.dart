import 'package:flutter/material.dart';
import 'package:monlamai_app/auth/auth_service.dart';
import 'package:monlamai_app/screens/home.dart';
import 'package:monlamai_app/screens/questions/questionnaire_steps.dart';
import 'package:monlamai_app/services/user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  UserSession userSession = UserSession();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 150.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    'assets/images/monlam-logo.png',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Monlam AI',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 48),
                // Google login button
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 240, // Minimum width for the button
                    maxWidth: 280, // Maximum width for the button
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Implement Google login
                      final result = await authService.loginWithGoogle();
                      handleNavigate(result);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/google-logo.png',
                            height: 24),
                        SizedBox(width: 8),
                        Text('LOG IN WITH GOOGLE'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Apple login button
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 240, // Minimum width for the button
                    maxWidth: 280, // Maximum width for the button
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Implement Apple login
                      final result = await authService.loginWithApple();
                      handleNavigate(result);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/apple-logo.png', height: 24),
                        SizedBox(width: 8),
                        Text('LOG IN WITH APPLE'),
                      ],
                    ),
                  ),
                ),
                // Trouble logging in link
                TextButton(
                  onPressed: () {
                    // Handle trouble logging in
                  },
                  child: Text(
                    'Trouble logging in?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Spacer(),
                // Terms agreement text
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 12),
                      children: [
                        TextSpan(text: 'By clicking Log In, you agree to our '),
                        TextSpan(
                          text: 'Terms',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                '.\nLearn how we process your data in our Organisation\nby contacting us on '),
                        TextSpan(
                          text: 'tech@monlam.ai',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleNavigate(result) async {
    final isSkipped = await userSession.getSkipQuestion();
    if (result.isSuccess) {
      if (!isSkipped) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuestionnaireSteps(),
          ),
        );
      }
    } else {
      String message = result.error['message'];
      if (message == 'USER_CANCELLED') return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $message')),
      );
    }
  }
}
