import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monlamai_app/services/user_session.dart';

class SttService {
  final String _apiUrl =
      dotenv.env["STT_API_URL"].toString(); // Replace with your API endpoint
  final String _apiKey = dotenv.env["API_AUTH_TOKEN"]
      .toString(); // If your API requires authentication
  UserSession userSession = UserSession();

  // Fetch text from audio file
  Future<Map<String, dynamic>> fetchTextFromAudio({
    required String audioUrl,
    required String language,
  }) async {
    final user = await userSession.getUser();
    final idToken = user!.idToken;

    final url = Uri.parse(_apiUrl);
    final body = jsonEncode({
      'input': audioUrl,
      'lang': language,
    });

    log("apiUrl: $_apiUrl, apiKey: $_apiKey, body: $body");

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
        log("response: $data");
        final decodedTranscription = utf8.decode(data["output"].codeUnits);

        return {
          "success": true,
          "output": decodedTranscription,
        };
      } else {
        // Handle HTTP error
        log("Failed to fetch text from audio: ${response.statusCode}");
        return {
          "success": false,
          "error": "Failed to fetch text from audio: ${response.statusCode}",
        };
      }
    } catch (e) {
      // Handle any other exceptions
      log('Error fetching text from audio: $e');
      return {
        "success": false,
        "error": "Error fetching text from audio: $e",
      };
    }
  }
}
