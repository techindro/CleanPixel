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
                ? const Color(0xFF0F0715).withOpacity(0.85)
                : Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFFCE7F3),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : const Color(0xFFEC4899).withOpacity(0.12),
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
                  color: const Color(0xFFEC4899),
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
                color: const Color(0xFFEC4899),
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
                    activeTrackColor: const Color(0xFFEC4899),
                    inactiveTrackColor: isDark
                        ? Colors.white.withOpacity(0.12)
                        : const Color(0xFFFCE7F3),
                    thumbColor: isDark ? Colors.white : const Color(0xFFEC4899),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    overlayColor: const Color(0xFFEC4899).withOpacity(0.2),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: strokeWidth,
                    min: 8,
                    max: 80,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      onStrokeChanged(v);
                    },
                  ),
                ),
              ),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  '${strokeWidth.round()}px',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _Divider(isDark: isDark),
              const SizedBox(width: 4),

              // Undo
              _ActionButton(
                icon: Icons.undo_rounded,
                isEnabled: canUndo,
                onTap: onUndo,
                tooltip: 'Undo',
                isDark: isDark,
              ),

              // Redo
              _ActionButton(
                icon: Icons.redo_rounded,
                isEnabled: canRedo,
                onTap: onRedo,
                tooltip: 'Redo',
                isDark: isDark,
              ),

              const SizedBox(width: 4),
              _Divider(isDark: isDark),
              const SizedBox(width: 4),

              // Clear
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                isEnabled: true,
                onTap: onClear,
                tooltip: 'Clear All',
                color: const Color(0xFFEF4444),
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
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ToolButton({
    Key? key,
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color.withOpacity(0.18) : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? color : Colors.white60,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;
  final bool isDark;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.isEnabled,
    required this.onTap,
    required this.tooltip,
    this.color,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          width: 32,
          height: 32,
          color: Colors.transparent,
          child: Icon(
            icon,
            size: 18,
            color: isEnabled
                ? (color ?? (isDark ? Colors.white : const Color(0xFF1E293B)))
                : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({Key? key, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      color: isDark ? Colors.white12 : const Color(0xFFFCE7F3),
    );
  }
}
