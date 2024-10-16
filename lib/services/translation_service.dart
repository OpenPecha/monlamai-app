import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:monlamai_app/services/user_session.dart';

class TranslationService {
  final String _apiUrl = dotenv.env["TRANSLATION_API_URL"]
      .toString(); // Replace with your API endpoint
  final String _apiKey = dotenv.env["API_AUTH_TOKEN"]
      .toString(); // If your API requires authentication
  UserSession userSession = UserSession();

  Future<Map<String, dynamic>> translateText(
    String inputText,
    String targetLanguage,
  ) async {
    final user = await userSession.getUser();
    final idToken = user!.idToken;

    final url = Uri.parse(_apiUrl);
    final body = jsonEncode({
      'input': inputText,
      'target': targetLanguage,
    });

    try {
      // Make the HTTP POST request
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey', // If required
          'Cookie': 'id_token=$idToken',
        },
        body: body,
      );

      // Parse the response JSON
      Map<String, dynamic> responseData = jsonDecode(response.body);
      log(
        'Response: $responseData',
      );

      // Check for successful response
      if (response.statusCode == 200) {
        // Return the translated text
        final decodedTranslation =
            utf8.decode(responseData['translation'].codeUnits);
        log("Decoded Translation: $decodedTranslation");
        return {
          "success": true,
          "id": responseData['id'],
          'translatedText': decodedTranslation,
        };
      } else {
        // Handle unsuccessful response
        log('Failed to translate text. Status Code: ${response.statusCode}');
        return {
          "success": false,
          "error":
              "Failed to translate text. Status Code: ${response.statusCode}",
        };
      }
    } catch (e) {
      // Handle any errors that occurred during the request
      log('Error translating text: $e');
      return {
        "success": false,
        "error": "Failed to translate text. Error: ${e.toString()}",
      };
    }
  }
}
