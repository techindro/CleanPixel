import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String id;
  final String title;
  final String mode;
  final String filePath;
  final int timestamp;
  final int sizeBytes;

  HistoryItem({
    required this.id,
    required this.title,
    required this.mode,
    required this.filePath,
    required this.timestamp,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'mode': mode,
        'filePath': filePath,
        'timestamp': timestamp,
        'sizeBytes': sizeBytes,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] ?? '',
        title: json['title'] ?? 'Cleaned Image',
        mode: json['mode'] ?? 'Watermark Remover',
        filePath: json['filePath'] ?? '',
        timestamp: json['timestamp'] ?? 0,
        sizeBytes: json['sizeBytes'] ?? 0,
      );
}

class HistoryService {
  static const String _key = 'cleanpixel_history_items';

  /// Save newly processed image to history disk storage
  static Future<HistoryItem?> saveToHistory({
    required Uint8List imageBytes,
    required String mode,
    String? customTitle,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final historyDir = Directory('${dir.path}/CleanPixel_History');
      if (!await historyDir.exists()) {
        await historyDir.create(recursive: true);
      }

      final id = 'CP_${DateTime.now().millisecondsSinceEpoch}';
      final fileName = '$id.png';
      final file = File('${historyDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      final item = HistoryItem(
        id: id,
        title: customTitle ?? 'CleanPixel Export #${DateTime.now().minute}${DateTime.now().second}',
        mode: mode,
        filePath: file.path,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        sizeBytes: imageBytes.length,
      );

      final items = await getHistory();
      items.insert(0, item);
      await _persist(items);
      return item;
    } catch (e) {
      debugPrint('Error saving to history: $e');
      return null;
    }
  }

  /// Get all history items sorted newest first
  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List list = jsonDecode(jsonStr);
      return list.map((e) => HistoryItem.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error parsing history: $e');
      return [];
    }
  }

  /// Delete a history item and remove its file
  static Future<void> deleteItem(String id) async {
    final items = await getHistory();
    final toDelete = items.where((e) => e.id == id).toList();
    for (final it in toDelete) {
      try {
        final f = File(it.filePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    items.removeWhere((e) => e.id == id);
    await _persist(items);
  }

  /// Clear entire history
  static Future<void> clearAll() async {
    final items = await getHistory();
    for (final it in items) {
      try {
        final f = File(it.filePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _persist(List<HistoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }
}
