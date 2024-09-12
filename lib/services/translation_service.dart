import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranslationService {
  final String _apiUrl = dotenv.env["TRANSLATON_API_URL"]
      .toString(); // Replace with your API endpoint
  final String _apiKey = dotenv.env["API_AUTH_TOKEN"]
      .toString(); // If your API requires authentication

  // Function to translate text with input and target language
  Future<Map<String, dynamic>> mockTranslateText(
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

  Future<Map<String, dynamic>> translateText(
      String inputText, String targetLanguage) async {
    try {
      // Make the HTTP POST request
      final http.Response response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey', // If required
        },
        body: jsonEncode({
          'input': inputText,
          'target': targetLanguage,
        }),
      );

      // Parse the response JSON
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check for successful response
      if (response.statusCode == 200) {
        // Return the translated text
        final decodedTranslation =
            utf8.decode(responseData['translation'].codeUnits);
        return {
          "succes": true,
          'translatedText': decodedTranslation,
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
