import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/screens/premium_screen.dart';
import 'package:cleanpixel_ai/services/locale_service.dart';

class ToolsHubScreen extends StatelessWidget {
  final Function(String mode)? onSelectTool;

  const ToolsHubScreen({Key? key, this.onSelectTool}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: LocaleService.currentLocale,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleService.tr('ai_suite'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const Text(
                  'Choose an AI tool to get started',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
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
                gradient: const [Color(0xFF2563EB), Color(0xFF38BDF8)],
                title: LocaleService.tr('erase_watermark'),
                description: 'Erase watermarks, logos, dates & text with a single brush stroke.',
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
                gradient: const [Color(0xFF0284C7), Color(0xFF0EA5E9)],
                title: 'Remove People & Objects',
                description: 'Cleanly erase photobombers, power lines, and unwanted objects.',
                badge: 'SMART AI',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (onSelectTool != null) onSelectTool!('object');
                },
              ),
              const SizedBox(height: 14),

              // 3. Background Cutout
              _buildToolCard(
                context,
                icon: Icons.layers_clear_rounded,
                gradient: const [Color(0xFF0D9488), Color(0xFF14B8A6)],
                title: 'Remove Background',
                description: 'Create clean transparent PNG cutouts instantly with one tap.',
                badge: 'HD CUTOUT',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (onSelectTool != null) onSelectTool!('background');
                },
              ),
              const SizedBox(height: 14),

              // 4. 4K Neural Upscaler
              _buildToolCard(
                context,
                icon: Icons.high_quality_rounded,
                gradient: const [Color(0xFF4F46E5), Color(0xFF6366F1)],
                title: 'Enhance & Upscale',
                description: 'Make low-resolution and blurry photos sharp and crystal clear.',
                badge: 'ENHANCE',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (onSelectTool != null) onSelectTool!('upscale');
                },
              ),
              const SizedBox(height: 14),

              // 5. Video Temporal Inpainter
              _buildToolCard(
                context,
                icon: Icons.videocam_rounded,
                gradient: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                title: 'Video Watermark Remover',
                description: 'Erase moving logos and watermarks from your videos seamlessly.',
                badge: 'PRO',
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
      },
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.35),
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
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isPro
                                  ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                                  : const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isPro
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF2563EB).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isPro) ...[
                                  const Icon(Icons.star_rounded, color: Color(0xFFFF6B00), size: 10),
                                  const SizedBox(width: 2),
                                ],
                                Text(
                                  badge,
                                  style: TextStyle(
                                    color: isPro ? const Color(0xFFFF6B00) : const Color(0xFF2563EB),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
