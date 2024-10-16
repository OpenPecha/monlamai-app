import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:monlamai_app/models/user.dart';
import 'package:monlamai_app/services/user_service.dart';
import 'package:monlamai_app/services/user_session.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;

  late Auth0 auth0;
  UserProfile? profile;
  String idToken = "";
  UserSession userSession = UserSession();
  UserService userService = UserService();

  AuthService._internal() {
    auth0 = Auth0(
      dotenv.env['AUTH0_DOMAIN']!,
      dotenv.env['AUTH0_CLIENT_ID']!,
    );
  }

  Future<UserProfile?> init() async {
    final isLoggedIn = await auth0.credentialsManager.hasValidCredentials();
    debugPrint('Is Logged In: $isLoggedIn');
    if (isLoggedIn) {
      final credentials = await auth0.credentialsManager.credentials();
      profile = credentials.user;
    }
    return profile;
  }

  Future<Result<UserProfile?, Map<String, String>>> loginWithFacebook() async {
    return _loginWithSocial('facebook');
  }

  Future<Result<UserProfile?, Map<String, String>>> loginWithGoogle() async {
    return _loginWithSocial('google-oauth2', {'prompt': 'select_account'});
  }

  Future<Result<UserProfile?, Map<String, String>>> _loginWithSocial(
      String connection,
      [Map<String, String>? additionalParameters]) async {
    try {
      final parameters = {
        'connection': connection,
      };
      if (additionalParameters != null) {
        parameters.addAll(additionalParameters);
      }

      final credentials = await auth0
          .webAuthentication(scheme: "monlamtranslate")
          .login(parameters: parameters);

      final profile = credentials.user;
      idToken = credentials.idToken;

      // Create user in shared preferences
      User newUser = User(
        idToken: idToken,
        name: profile.name ?? '',
        nickname: profile.nickname ?? '',
        email: profile.email ?? '',
        profileUrl: profile.profileUrl?.toString() ?? '',
        pictureUrl: profile.pictureUrl?.toString() ?? '',
        gender: profile.gender ?? '',
        birthdate: profile.birthdate ?? '',
        city: "",
        country: "",
        areaOfInterest: "",
        profession: "",
      );
      await userSession.setUser(newUser);

      // Create user on the backend
      await userService.createUser({
        'email': profile.email ?? '',
        'name': profile.name ?? '',
        'pictureUrl': profile.pictureUrl?.toString() ?? '',
      });

      return Result.success(profile);
    } on WebAuthenticationException catch (e) {
      if (e.code == 'USER_CANCELLED') {
        // You might want to show a user-friendly message here
        return Result.error({'message': 'USER_CANCELLED'});
      } else {
        // Handle other WebAuthenticationExceptions
        return Result.error({'message': 'Authentication error: ${e.message}'});
      }
    } catch (e) {
      return Result.error({'message': 'Unexpected error occurred'});
    }
  }

  Future<bool> quickLogout() async {
    try {
      await userSession.clearUser();
      profile = null;
      return await auth0.credentialsManager.clearCredentials();
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await auth0.webAuthentication(scheme: "monlamtranslate").logout();
      await userSession.clearUser();
      profile = null;
    } catch (e) {
      // Handle logout error
      print('Logout error: $e');
    }
  }
}

class Result<T, E> {
  final T? value;
  final E? error;

  Result._({this.value, this.error});

  factory Result.success(T value) => Result._(value: value);

  factory Result.error(E error) => Result._(error: error);

  bool get isSuccess => value != null;

  bool get isError => error != null;
}
