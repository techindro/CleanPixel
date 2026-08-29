import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/screens/premium_screen.dart';

class ToolsHubScreen extends StatelessWidget {
  final Function(String mode)? onSelectTool;

  const ToolsHubScreen({Key? key, this.onSelectTool}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Creative Suite',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white, letterSpacing: -0.3),
            ),
            Text(
              'Select an AI neural model for your media',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. Watermark Inpainter
          _buildToolCard(
            context,
            icon: Icons.auto_fix_high_rounded,
            gradient: const [Color(0xFF38BDF8), Color(0xFF2563EB)],
            title: 'Watermark & Text Remover',
            description: 'Brush over copyright stamps, logos, subtitles, and TikTok stamps to erase in 1-tap.',
            badge: 'POPULAR',
            onTap: () {
              HapticFeedback.mediumImpact();
              if (onSelectTool != null) onSelectTool!('watermark');
            },
          ),
          const SizedBox(height: 12),

          // 2. Object & People Eraser
          _buildToolCard(
            context,
            icon: Icons.person_remove_rounded,
            gradient: const [Color(0xFFEC4899), Color(0xFF8B5CF6)],
            title: 'Magic Object & People Eraser',
            description: 'Erase photobombers, power lines, trash, and unwanted background distractions.',
            badge: 'AI NEURAL',
            onTap: () {
              HapticFeedback.mediumImpact();
              if (onSelectTool != null) onSelectTool!('object');
            },
          ),
          const SizedBox(height: 12),

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
          const SizedBox(height: 12),

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
          const SizedBox(height: 12),

          // 5. Video Inpainter (PRO)
          _buildToolCard(
            context,
            icon: Icons.videocam_rounded,
            gradient: const [Color(0xFFA855F7), Color(0xFF6366F1)],
            title: 'Temporal Video Inpainter',
            description: 'Erase moving watermarks and objects across 60 FPS video tracks with keyframe propagation.',
            badge: 'PRO EXCLUSIVE',
            isPro: true,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen()));
            },
          ),
          const SizedBox(height: 12),

          // 6. Batch Multi-Image Processor
          _buildToolCard(
            context,
            icon: Icons.layers_rounded,
            gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            title: 'Bulk Batch Queue Worker',
            description: 'Upload up to 50 photos simultaneously and process watermarks in high-speed GPU queues.',
            badge: 'ENTERPRISE',
            onTap: () {
              HapticFeedback.mediumImpact();
              if (onSelectTool != null) onSelectTool!('batch');
            },
          ),
          const SizedBox(height: 20),
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
    bool isPro = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: gradient.first.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(color: gradient.first, fontSize: 8, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
