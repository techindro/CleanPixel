import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContextualToolbar extends StatelessWidget {
  final bool isBrush;
  final double strokeWidth;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onToggleTool;
  final Function(double) onStrokeChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback? onAutoDetect;

  const ContextualToolbar({
    Key? key,
    required this.isBrush,
    required this.strokeWidth,
    required this.canUndo,
    required this.canRedo,
    required this.onToggleTool,
    required this.onStrokeChanged,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    this.onAutoDetect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0B0F19).withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : const Color(0xFF2563EB).withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🪄 1-Tap Auto Detect
              if (onAutoDetect != null) ...[
                _ToolButton(
                  icon: Icons.auto_awesome_rounded,
                  isActive: true,
                  color: const Color(0xFF2563EB),
                  onTap: onAutoDetect!,
                  tooltip: 'Auto Detect',
                ),
                const SizedBox(width: 4),
                _Divider(isDark: isDark),
                const SizedBox(width: 4),
              ],

              // Brush / Eraser Toggle
              _ToolButton(
                icon: isBrush ? Icons.brush_rounded : Icons.auto_fix_high_rounded,
                isActive: true,
                color: const Color(0xFF2563EB),
                onTap: onToggleTool,
                tooltip: isBrush ? 'Brush' : 'Eraser',
              ),
              const SizedBox(width: 4),
              _Divider(isDark: isDark),
              const SizedBox(width: 4),

              // Stroke Size Slider
              SizedBox(
                width: 80,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF2563EB),
                    inactiveTrackColor: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : const Color(0xFFE0F2FE),
                    thumbColor: isDark ? Colors.white : const Color(0xFF2563EB),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    overlayColor: const Color(0xFF2563EB).withValues(alpha: 0.2),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: strokeWidth,
                    min: 10.0,
                    max: 80.0,
                    onChanged: onStrokeChanged,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _Divider(isDark: isDark),
              const SizedBox(width: 4),

              // Undo Button
              _ToolButton(
                icon: Icons.undo_rounded,
                isActive: canUndo,
                onTap: onUndo,
                tooltip: 'Undo',
                isDark: isDark,
              ),

              // Redo Button
              _ToolButton(
                icon: Icons.redo_rounded,
                isActive: canRedo,
                onTap: onRedo,
                tooltip: 'Redo',
                isDark: isDark,
              ),
              const SizedBox(width: 4),
              _Divider(isDark: isDark),
              const SizedBox(width: 4),

              // Clear All Canvas
              _ToolButton(
                icon: Icons.refresh_rounded,
                isActive: true,
                onTap: onClear,
                tooltip: 'Clear All',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;
  final bool isDark;

  const _ToolButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
    this.color,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (isActive
            ? (isDark ? Colors.white : const Color(0xFF0F172A))
            : (isDark ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFCBD5E1)));

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: isActive
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 20,
              color: effectiveColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 18,
      color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
    );
  }
}
