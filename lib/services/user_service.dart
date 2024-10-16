import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monlamai_app/models/user.dart';
import 'package:monlamai_app/services/user_session.dart';

class UserService {
  final String _apiUrl = dotenv.env['USER_API_URL'].toString();
  final String _apiKey = dotenv.env["API_AUTH_TOKEN"]
      .toString(); // If your API requires authentication
  UserSession userSession = UserSession();

  // create a new user
  Future<Map<String, dynamic>> createUser(userData) async {
    String? email = userData["email"];
    String? name = userData["name"];
    String? picture = userData["pictureUrl"];
    try {
      final url = Uri.parse('$_apiUrl/create');
      final headers = await _getHeaders();

      final body = json.encode({
        'email': email,
        'name': name,
        'picture': picture,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint('User created successfully createUser ${response.body}');
        return {
          'success': 'User created successfully',
        };
      } else {
        debugPrint(
            'Error creating user createUser: ${response.body}, ${response.statusCode}');
        return {
          'error': 'Error creating user',
        };
      }
    } catch (e) {
      debugPrint("Error creating user ::: createUser ${e.toString()}");
      return {'error': 'Error creating user: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> saveUserData(userData) async {
    String? gender = userData["gender"];
    String? city = userData["city"];
    String? birthDate = userData["dob"];
    String? country = userData["country"];
    List<String>? interest = userData["areaOfInterest"];
    String? profession = userData["profession"];
    try {
      final user = await userSession.getUser();
      final email = user!.email;

      final url = Uri.parse('$_apiUrl/$email/update');

      final headers = await _getHeaders();

      final body = json.encode({
        'gender': gender,
        'country': country,
        'city': city,
        'birth_date': birthDate,
        'interest': json.encode(interest),
        'profession': profession,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return {
          'success': 'User data saved successfully',
        };
      } else {
        // user friendly error message
        return {
          'error': 'Unable to save user data',
        };
      }
    } catch (e) {
      return {'error': 'Error saving user data: ${e.toString()}'};
    }
  }

  // to get user data from the server
  Future<Map<String, dynamic>> getUserDetails(String email) async {
    try {
      final url = Uri.parse('$_apiUrl/$email');
      final headers = await _getHeaders();
      final user = await userSession.getUser();

      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        User newUser = User.fromJson({
          'token': user!.idToken,
          'name': responseData['user']['username'],
          'email': responseData['user']['email'],
          'pictureUrl': responseData['user']['picture'],
          'gender': responseData['user']['gender'],
          'birthdate': responseData['user']['birth_date'],
          'city': responseData['user']['city'],
          'country': responseData['user']['country'],
          'areaOfInterest': responseData['user']['interest'],
          'profession': responseData['user']['profession'],
        });
        return {
          'success': true,
          'user': newUser,
        };
      } else {
        return {
          'success': false,
          'error': 'Error fetching user data',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": "Failed to fetch user data. Error: ${e.toString()}",
      };
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    // Implement your header generation logic here
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      // Add other necessary headers
    };
  }
}
