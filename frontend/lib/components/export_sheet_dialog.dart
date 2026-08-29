import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ExportFormat { png, jpg, webp }
enum ExportResolution { hd1080, quad2k, ultra4k }

class ExportSheetDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final Function(ExportFormat format, ExportResolution resolution) onExport;

  const ExportSheetDialog({
    Key? key,
    required this.imageBytes,
    required this.onExport,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required Uint8List imageBytes,
    required Function(ExportFormat format, ExportResolution resolution) onExport,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ExportSheetDialog(
        imageBytes: imageBytes,
        onExport: onExport,
      ),
    );
  }

  @override
  State<ExportSheetDialog> createState() => _ExportSheetDialogState();
}

class _ExportSheetDialogState extends State<ExportSheetDialog> {
  ExportFormat _format = ExportFormat.png;
  ExportResolution _resolution = ExportResolution.ultra4k;

  @override
  Widget build(BuildContext context) {
    final sizeKb = (widget.imageBytes.lengthInBytes / 1024).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Cleaned Asset',
                    style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Select output resolution & compression quality',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$sizeKb KB',
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 1. Resolution Selector
          const Text(
            'OUTPUT RESOLUTION',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildResOption('1080p HD', 'Web & Social', ExportResolution.hd1080),
              const SizedBox(width: 8),
              _buildResOption('2K Quad', 'Crisp Print', ExportResolution.quad2k),
              const SizedBox(width: 8),
              _buildResOption('4K Ultra', 'Lossless Master', ExportResolution.ultra4k, badge: 'PRO'),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Format Selector
          const Text(
            'FILE FORMAT',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFormatOption('PNG Lossless', ExportFormat.png),
              const SizedBox(width: 8),
              _buildFormatOption('JPEG High', ExportFormat.jpg),
              const SizedBox(width: 8),
              _buildFormatOption('WebP Compact', ExportFormat.webp),
            ],
          ),
          const SizedBox(height: 28),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF0284C7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  Navigator.pop(context);
                  widget.onExport(_format, _resolution);
                },
                icon: const Icon(Icons.download_done_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Confirm & Save to Gallery',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildResOption(String title, String subtitle, ExportResolution res, {String? badge}) {
    final isSelected = _resolution == res;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _resolution = res);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.2) : const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.06),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEC4899)]),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatOption(String title, ExportFormat fmt) {
    final isSelected = _format == fmt;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _format = fmt);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.2) : const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
