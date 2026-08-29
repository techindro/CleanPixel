import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  static Future<Uint8List?> removeWatermark({
    required File imageFile,
    required Uint8List maskBytes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/media/remove-watermark');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      request.files.add(http.MultipartFile.fromBytes(
        'mask',
        maskBytes,
        filename: 'mask.png',
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('API status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('API request failed: $e');
      return null;
    }
  }
}
