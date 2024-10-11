import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String _apiUrl = dotenv.env['USER_API_URL'].toString();
  final String _apiKey = dotenv.env["API_AUTH_TOKEN"]
      .toString(); // If your API requires authentication

  Future<Map<String, dynamic>> saveUserData(userData) async {
    String gender = userData["gender"];
    String city = userData["city"];
    String birthDate = userData["dob"];
    String country = userData["country"];
    List<String> interest = userData["areaOfInterest"];
    String profession = userData["profession"];
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail') ?? '';

      final url = Uri.parse('$_apiUrl/api/v1/user/$email/update');

      final headers = await _getHeaders();

      final body = json.encode({
        'gender': gender,
        'country': country,
        'city': city,
        'birth_date': birthDate,
        'interest': json.encode(interest),
        'profession': profession,
      });

      return {'success': 'User data saved successfully'};

      // Uncomment the following code to make an actual API request
      // final response = await http.post(
      //   url,
      //   headers: headers,
      //   body: body,
      // );

      // if (response.statusCode == 200) {
      //   return json.decode(response.body);
      // } else {
      //   throw Exception('Failed to save user data');
      // }
    } catch (e) {
      return {'error': 'Error saving user data: ${e.toString()}'};
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    // Implement your header generation logic here
    return {
      'Content-Type': 'application/json',
      'Bearer': _apiKey,
      // Add other necessary headers
    };
  }
}
