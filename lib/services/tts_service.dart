import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import 'package:monlamai_app/services/user_session.dart';

class TtsService {
  final String _apiUrl =
      dotenv.env["TTS_API_URl"].toString(); // Replace with your API endpoint
  final String _apiKey = dotenv.env["API_AUTH_TOKEN"]
      .toString(); // If your API requires authentication
  UserSession userSession = UserSession();

  Future<Map<String, dynamic>> fetchAudioUrl({
    required String text,
    required String language,
  }) async {
    final user = await userSession.getUser();
    final idToken = user!.idToken;

    final url = Uri.parse(_apiUrl);
    final body = jsonEncode({
      'input': text,
      // 'language': language,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $_apiKey",
          // "Cookie": "id_token=$idToken",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        developer.log("Fetched audio URL: $data");
        return {
          "success": true,
          "output": data["output"],
        };
      } else {
        // Handle HTTP error
        developer.log("Failed to fetch audio URL: ${response.statusCode}");
        return {
          "success": false,
          "error": "Failed to fetch audio URL: ${response.statusCode}",
        };
      }
    } catch (e) {
      // Handle any other exceptions
      developer.log("Error fetching audio URL: $e");
      return {
        "success": false,
        "error": "Error fetching audio URL: $e",
      };
    }
  }
}
