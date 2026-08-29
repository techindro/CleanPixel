import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Remote Inpainting Endpoint (with fallback)
  static const String baseUrl = 'http://192.168.31.210:8000/api/v1';

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

      // Strict 2-second timeout to prevent UI hanging on real devices
      final streamedResponse = await request.send().timeout(const Duration(milliseconds: 2000));
      final response = await http.Response.fromStream(streamedResponse).timeout(const Duration(milliseconds: 2000));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('Fast inpaint fallback triggered: $e');
    }
    return null;
  }
}
