import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monlamai_app/services/user_session.dart';

class OcrService {
  final String _apiUrl =
      dotenv.env["OCR_API_URL"].toString(); // Replace with your API endpoint
  final String _apiKey = dotenv.env["API_AUTH_TOKEN"]
      .toString(); // If your API requires authentication
  UserSession userSession = UserSession();

  Future<Map<String, dynamic>> fetchTextFromImage({
    required String imageUrl,
  }) async {
    final user = await userSession.getUser();
    final idToken = user!.idToken;
    final url = Uri.parse(_apiUrl);
    final body = jsonEncode({
      'input': imageUrl,
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
        debugPrint("Fetched text from image: $data");

        return {
          "success": true,
          "output": data["coordinates"],
          "width": data["width"],
          "height": data["height"],
        };
      } else {
        // Handle HTTP error
        debugPrint("Failed to fetch text from image: ${response.statusCode}");
        return {
          "success": false,
          "error": "Failed to fetch text from image: ${response.statusCode}",
        };
      }
    } catch (e) {
      // Handle any other exceptions
      debugPrint("Error fetching text from image: $e");
      return {
        "success": false,
        "error": "Error fetching text from image: $e",
      };
    }
  }

  List<Map<String, dynamic>> processGoogleOCRData(
      Map<String, dynamic> googleData) {
    List<Map<String, dynamic>> processedData = [];

    for (var page in googleData['fullTextAnnotation']['pages']) {
      for (var block in page['blocks']) {
        for (var paragraph in block['paragraphs']) {
          Map<String, dynamic> sentence = {
            'bounds': {
              'vertices': paragraph['boundingBox']['vertices'],
            },
            'words': paragraph['words'].map((word) {
              return {
                'text':
                    word['symbols'].map((symbol) => symbol['text']).join(''),
                'bounds': {
                  'vertices': word['boundingBox']['vertices'],
                },
              };
            }).toList(),
          };
          processedData.add(sentence);
        }
      }
    }

    return processedData;
  }
}
