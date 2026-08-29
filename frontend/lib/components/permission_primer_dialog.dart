import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MediaPickSource { gallery, camera, demo }

class PermissionPrimerDialog extends StatelessWidget {
  final Function(MediaPickSource) onSelectSource;

  const PermissionPrimerDialog({Key? key, required this.onSelectSource}) : super(key: key);

  static Future<MediaPickSource?> show(BuildContext context) {
    return showModalBottomSheet<MediaPickSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PermissionPrimerDialog(
        onSelectSource: (src) => Navigator.pop(context, src),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF38BDF8), size: 24),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import Watermarked Media',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Choose image source for AI inpainting',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Option 1: Gallery Picker
          _buildSourceTile(
            context,
            icon: Icons.photo_library_rounded,
            iconColor: const Color(0xFF38BDF8),
            title: 'Choose from Gallery',
            subtitle: 'PNG, JPG, WebP, HEIC photos',
            badge: 'RECOMMENDED',
            onTap: () {
              HapticFeedback.mediumImpact();
              onSelectSource(MediaPickSource.gallery);
            },
          ),
          const SizedBox(height: 10),

          // Option 2: Camera Capture
          _buildSourceTile(
            context,
            icon: Icons.camera_alt_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Take a Photo with Camera',
            subtitle: 'Capture document, screen or watermark live',
            onTap: () {
              HapticFeedback.mediumImpact();
              onSelectSource(MediaPickSource.camera);
            },
          ),
          const SizedBox(height: 10),

          // Option 3: Instant Demo Sample
          _buildSourceTile(
            context,
            icon: Icons.auto_fix_normal_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Try 4K Demo Preset',
            subtitle: 'Instant sample image to test inpainting magic',
            onTap: () {
              HapticFeedback.lightImpact();
              onSelectSource(MediaPickSource.demo);
            },
          ),
          const SizedBox(height: 20),

          // Privacy Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_rounded, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text('100% Private • Transient In-Memory Processing',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSourceTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.2), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
