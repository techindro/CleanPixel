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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0F19).withOpacity(0.8),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Brush / Eraser Toggle
              _ToolButton(
                icon: isBrush ? Icons.brush_rounded : Icons.auto_fix_high_rounded,
                isActive: true,
                color: const Color(0xFFEC4899),
                onTap: onToggleTool,
                tooltip: isBrush ? 'Brush' : 'Eraser',
              ),
              const SizedBox(width: 4),
              _Divider(),
              const SizedBox(width: 4),

              // Stroke Size Slider
              SizedBox(
                width: 90,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFEC4899),
                    inactiveTrackColor: Colors.white.withOpacity(0.12),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
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
                width: 36,
                alignment: Alignment.center,
                child: Text(
                  '${strokeWidth.toInt()}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                ),
              ),
              _Divider(),
              const SizedBox(width: 2),

              // Undo / Redo / Clear
              _ToolButton(
                icon: Icons.undo_rounded,
                isActive: canUndo,
                color: Colors.white,
                onTap: canUndo ? onUndo : null,
                tooltip: 'Undo',
              ),
              _ToolButton(
                icon: Icons.redo_rounded,
                isActive: canRedo,
                color: Colors.white,
                onTap: canRedo ? onRedo : null,
                tooltip: 'Redo',
              ),
              _ToolButton(
                icon: Icons.delete_outline_rounded,
                isActive: true,
                color: const Color(0xFFEF4444),
                onTap: onClear,
                tooltip: 'Clear',
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
  final VoidCallback? onTap;
  final String tooltip;

  const _ToolButton({
    required this.icon,
    required this.isActive,
    required this.color,
    this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Center(
              child: Icon(
                icon,
                color: isActive ? color : Colors.white.withOpacity(0.2),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Colors.white.withOpacity(0.08),
    );
  }
}
