import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;
  // Auth0 instance
  Auth0 auth0 = Auth0(
    dotenv.env['AUTH0_DOMAIN']!, // Accessing the Auth0 domain
    dotenv.env['AUTH0_CLIENT_ID']!, // Accessing the Auth0 client ID
  );
  UserProfile? profile;

  AuthService._internal();

  Future init() async {
    final isLoggedIn = await auth0.credentialsManager.hasValidCredentials();
    if (isLoggedIn) {
      final credentials = await auth0.credentialsManager.credentials();
      profile = credentials.user;
    }
    return profile;
  }

  // Login with WebAuth
  Future login() async {
    try {
      final credentials = await auth0
          .webAuthentication(
            scheme: "monlamtranslate",
          )
          .login();
      profile = credentials.user;
      print('Access Token: ${credentials.accessToken}');
      print('ID Token: ${credentials.idToken}');
      return profile;
    } catch (e) {
      print('Login Error: $e');
    }
  }

  // Logout with WebAuth
  Future<void> logout() async {
    try {
      await auth0
          .webAuthentication(
            scheme: "monlamtranslate",
          )
          .logout();
      print('Logged out');
    } catch (e) {
      print('Logout Error: $e');
    }
  }
}
