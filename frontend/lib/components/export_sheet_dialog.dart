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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sizeKb = (widget.imageBytes.lengthInBytes / 1024).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : const Color(0xFF2563EB).withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, -8),
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
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Cleaned Asset',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Select output resolution & compression quality',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
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
                  '${sizeKb} KB',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Format selector
          Text(
            'FILE FORMAT',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFormatChip('PNG (Lossless)', ExportFormat.png, isDark),
              const SizedBox(width: 8),
              _buildFormatChip('JPG (Compact)', ExportFormat.jpg, isDark),
              const SizedBox(width: 8),
              _buildFormatChip('WebP (Ultra)', ExportFormat.webp, isDark),
            ],
          ),
          const SizedBox(height: 20),

          // Resolution selector
          Text(
            'OUTPUT RESOLUTION',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildResolutionTile(
                title: '4K Ultra HD (3840 x 2160)',
                subtitle: 'Lossless studio masterwork resolution',
                resolution: ExportResolution.ultra4k,
                badge: 'RECOMMENDED',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildResolutionTile(
                title: '2K Quad HD (2560 x 1440)',
                subtitle: 'Balanced for social media & web publishing',
                resolution: ExportResolution.quad2k,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildResolutionTile(
                title: '1080p Full HD (1920 x 1080)',
                subtitle: 'Standard quick messaging export',
                resolution: ExportResolution.hd1080,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 26),

          // Export Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Save to Device Gallery',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(String label, ExportFormat format, bool isDark) {
    final isSelected = _format == format;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _format = format);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB).withValues(alpha: isDark ? 0.25 : 0.12)
                : (isDark ? const Color(0xFF110817) : const Color(0xFFF0F9FF)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE0F2FE)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResolutionTile({
    required String title,
    required String subtitle,
    required ExportResolution resolution,
    String? badge,
    required bool isDark,
  }) {
    final isSelected = _resolution == resolution;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _resolution = resolution);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? const Color(0xFF110817) : const Color(0xFFF0F9FF)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE0F2FE)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white38 : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
