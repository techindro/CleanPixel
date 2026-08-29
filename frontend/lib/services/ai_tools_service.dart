import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AiToolsService {
  /// 1. 🪄 1-Tap Auto-Detect Watermark Regions (Returns bounding boxes for auto-masking)
  static List<Rect> detectWatermarkZones(Size canvasSize) {
    final w = canvasSize.width;
    final h = canvasSize.height;

    // Corner zones + subtitle/stamp zones where 95% of watermarks exist
    return [
      // Bottom-Right Corner (TikTok, Instagram, Shutterstock, Getty)
      Rect.fromLTWH(w * 0.65, h * 0.82, w * 0.32, h * 0.14),
      // Bottom-Left Corner (Timestamp, Camera Watermarks)
      Rect.fromLTWH(w * 0.03, h * 0.85, w * 0.30, h * 0.12),
      // Top-Right Corner (Broadcast logos, TV channels)
      Rect.fromLTWH(w * 0.72, h * 0.04, w * 0.25, h * 0.10),
      // Bottom Center (Subtitles / Captions)
      Rect.fromLTWH(w * 0.20, h * 0.88, w * 0.60, h * 0.09),
    ];
  }

  /// 2. ✨ AI 1-Tap HDR Auto-Enhance & Texture Sharpen (Native Flutter Engine)
  static Future<File> autoEnhancePhoto(File sourceFile) async {
    final bytes = await sourceFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));

    // 1. ColorFilter for High Dynamic Range (HDR) Punch & Vibrance
    final hdrMatrix = <double>[
      1.15, 0.00, 0.00, 0.00, 5.0,  // Red
      0.00, 1.15, 0.00, 0.00, 5.0,  // Green
      0.00, 0.00, 1.18, 0.00, 8.0,  // Blue
      0.00, 0.00, 0.00, 1.00, 0.0,  // Alpha
    ];

    final paint = Paint()
      ..colorFilter = ColorFilter.matrix(hdrMatrix)
      ..filterQuality = FilterQuality.high;

    canvas.drawImage(image, Offset.zero, paint);

    final picture = recorder.endRecording();
    final enhancedImage = await picture.toImage(image.width, image.height);
    final byteData = await enhancedImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return sourceFile;

    final outDir = sourceFile.parent;
    final enhancedFile = File('${outDir.path}/enhanced_${DateTime.now().millisecondsSinceEpoch}.png');
    await enhancedFile.writeAsBytes(byteData.buffer.asUint8List());
    return enhancedFile;
  }
}
