import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/screens/premium_screen.dart';

class ToolsHubScreen extends StatelessWidget {
  final Function(String mode)? onSelectTool;

  const ToolsHubScreen({Key? key, this.onSelectTool}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0715) : const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F0715) : Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Creative Suite',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
            ),
            const Text(
              'Select an AI neural model for your media',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFEC4899)),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Watermark Inpainter
          _buildToolCard(
            context,
            icon: Icons.auto_fix_high_rounded,
            gradient: const [Color(0xFFEC4899), Color(0xFFF43F5E)],
            title: 'Watermark & Text Remover',
            description: 'Brush over copyright stamps, logos, subtitles, and TikTok stamps to erase in 1-tap.',
            badge: 'POPULAR',
            onTap: () {
              HapticFeedback.mediumImpact();
              if (onSelectTool != null) onSelectTool!('watermark');
            },
          ),
          const SizedBox(height: 14),

          // 2. Object & People Eraser
          _buildToolCard(
            context,
            icon: Icons.person_remove_rounded,
            gradient: const [Color(0xFFFB7185), Color(0xFFE11D48)],
            title: 'Magic Object & People Eraser',
            description: 'Erase photobombers, power lines, trash, and unwanted background distractions.',
            badge: 'AI NEURAL',
            onTap: () {
              HapticFeedback.mediumImpact();
              if (onSelectTool != null) onSelectTool!('object');
            },
          ),
          const SizedBox(height: 14),

          // 3. Background Cutout Studio
          _buildToolCard(
            context,
            icon: Icons.cut_rounded,
            gradient: const [Color(0xFF10B981), Color(0xFF059669)],
            title: 'AI Background Remover (Cutout)',
            description: 'Generate instant transparent PNG cutouts for e-commerce, portraits, and thumbnails.',
            badge: '1-TAP HD',
            onTap: () {
              HapticFeedback.mediumImpact();
              if (onSelectTool != null) onSelectTool!('background');
            },
          ),
          const SizedBox(height: 14),

          // 4. 4K Super-Resolution Upscaler
          _buildToolCard(
            context,
            icon: Icons.hd_rounded,
            gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
            title: '4K Ultra-HD AI Upscaler',
            description: 'Enhance low-resolution photos, recover crisp textures, and upscale 4x without pixelation.',
            badge: '4K LOSSLESS',
            onTap: () {
              HapticFeedback.mediumImpact();
              if (onSelectTool != null) onSelectTool!('upscale');
            },
          ),
          const SizedBox(height: 14),

          // 5. Video Inpainter (PRO)
          _buildToolCard(
            context,
            icon: Icons.videocam_rounded,
            gradient: const [Color(0xFFA855F7), Color(0xFFEC4899)],
            title: 'Temporal Video Inpainter',
            description: 'Erase moving watermarks and objects across 60 FPS video tracks with keyframe propagation.',
            badge: 'PRO TIER',
            isPro: true,
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required List<Color> gradient,
    required String title,
    required String description,
    required String badge,
    required VoidCallback onTap,
    bool isPro = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B0C24) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFCE7F3),
            width: 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 26, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPro
                              ? const Color(0xFFEC4899)
                              : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFDF2F8)),
                          borderRadius: BorderRadius.circular(6),
                          border: isPro
                              ? null
                              : Border.all(
                                  color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFFCE7F3)),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: isPro ? Colors.white : const Color(0xFFEC4899),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.4,
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
