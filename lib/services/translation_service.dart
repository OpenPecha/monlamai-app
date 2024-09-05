import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranslationService {
  final String _apiUrl = dotenv.env["TRANSLATON_API_URL"]
      .toString(); // Replace with your API endpoint
  final String _apiKey = 'YOUR_API_KEY'; // If your API requires authentication

  // Function to translate text with input and target language
  Future<Map<String, dynamic>> translateText(
      String inputText, String targetLanguage) async {
    String translatedText =
        await _mockTranslationModel(inputText, targetLanguage);

    // Returning the result as a JSON-like map
    return {
      'originalText': inputText,
      'targetLanguage': targetLanguage,
      'translatedText': translatedText,
    };
  }

  // Mock translation model function
  Future<String> _mockTranslationModel(
      String inputText, String targetLanguage) async {
    await Future.delayed(
        const Duration(seconds: 2)); // Simulate a network delay

    // Replace this with actual translation logic or API call
    return "Translated [$targetLanguage]: $inputText"; // Simulated translated text
  }

  Future<Map<String, dynamic>> translateText2(
      String inputText, String targetLanguage) async {
    try {
      // Make the HTTP POST request
      final http.Response response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey', // If required
        },
        body: jsonEncode(
          {
            'inpur': inputText,
            'target': targetLanguage,
          },
        ),
      );

      // Check for successful response
      if (response.statusCode == 200) {
        // Parse the response JSON
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          "succes": true,
          "translated_text": responseData["translated_text"],
        };
      } else {
        // Handle unsuccessful response
        return {
          "success": false,
          "error":
              "Failed to translate text. Status Code: ${response.statusCode}",
        };
      }
    } catch (e) {
      // Handle any errors that occurred during the request
      return {
        "success": false,
        "error": "Failed to translate text. Error: ${e.toString()}",
      };
    }
  }
}
