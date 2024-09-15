import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FileUpload {
  final String _apiUrl = dotenv.env['FILE_UPLOAD_API_URL'] ?? '';
  final String _apiKey = dotenv.env['API_AUTH_TOKEN'] ?? '';

  Future<Map<String, dynamic>> uploadFile({required String filePath}) async {
    final url = Uri.parse(_apiUrl);
    final request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Authorization': 'Bearer $_apiKey',
    });

    // Add file to the request
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
    ));

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        log('File upload response: $data');

        return {
          'success': true,
          'message': data['message'],
          'file_url': data['file_url'],
        };
      } else {
        log('Error uploading file. Status code: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error uploading file. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      log('Error uploading file: $e');
      return {
        'success': false,
        'error': 'Error uploading file: $e',
      };
    }
  }
}
