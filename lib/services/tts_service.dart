import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TtsService {
  final String _apiUrl =
      dotenv.env["TTS_API_URl"].toString(); // Replace with your API endpoint
  final String _apiKey = dotenv.env["API_AUTH_TOKEN"]
      .toString(); // If your API requires authentication

  Future<Map<String, dynamic>> fetchAudioUrl({
    required String text,
    required String language,
  }) async {
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
          "Authorization": "Bearer $_apiKey"
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print("fetchAudioUrl response: $data");
        return {
          "success": true,
          "output": data["output"],
        };
      } else {
        // Handle HTTP error
        print("Failed to fetch audio URL: ${response.statusCode}");
        return {
          "success": false,
          "error": "Failed to fetch audio URL: ${response.statusCode}",
        };
      }
    } catch (e) {
      // Handle any other exceptions
      print('Error fetching audio URL: $e');
      return {
        "success": false,
        "error": "Error fetching audio URL: $e",
      };
    }
  }
}
