import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OcrService {
  final String _apiUrl =
      dotenv.env["OCR_API_URL"].toString(); // Replace with your API endpoint
  final String _apiKey = dotenv.env["API_AUTH_TOKEN"]
      .toString(); // If your API requires authentication

  Future<Map<String, dynamic>> fetchTextFromImage({
    required String imageUrl,
  }) async {
    final url = Uri.parse(_apiUrl);
    final body = jsonEncode({
      'input': imageUrl,
    });

    print("apiUrl: $_apiUrl, apiKey: $_apiKey, body: $body");

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
        print("response: $data");

        return {
          "success": true,
          "output": data["coordinates"],
          "width": data["width"],
          "height": data["height"],
        };
      } else {
        // Handle HTTP error
        print("Failed to fetch text from image: ${response.statusCode}");
        return {
          "success": false,
          "error": "Failed to fetch text from image: ${response.statusCode}",
        };
      }
    } catch (e) {
      // Handle any other exceptions
      print('Error fetching text from image: $e');
      return {
        "success": false,
        "error": "Error fetching text from image: $e",
      };
    }
  }
}
