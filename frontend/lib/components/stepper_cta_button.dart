import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StepperCtaButton extends StatefulWidget {
  final bool isProcessing;
  final bool isEnabled;
  final String statusText;
  final String progressText;
  final VoidCallback onPressed;

  const StepperCtaButton({
    Key? key,
    required this.isProcessing,
    required this.isEnabled,
    required this.statusText,
    required this.progressText,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<StepperCtaButton> createState() => _StepperCtaButtonState();
}

class _StepperCtaButtonState extends State<StepperCtaButton> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _pressController]),
      builder: (context, _) {
        return GestureDetector(
          onTapDown: widget.isEnabled && !widget.isProcessing ? (_) {
            _pressController.animateTo(0.96);
            HapticFeedback.lightImpact();
          } : null,
          onTapUp: widget.isEnabled && !widget.isProcessing ? (_) {
            _pressController.animateTo(1.0);
            widget.onPressed();
          } : null,
          onTapCancel: () => _pressController.animateTo(1.0),
          child: Transform.scale(
            scale: _pressController.value,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: widget.isEnabled
                    ? const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF38BDF8), Color(0xFF1D4ED8)],
                      )
                    : null,
                color: widget.isEnabled
                    ? null
                    : (isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F5F9)),
                border: widget.isEnabled
                    ? null
                    : Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
                      ),
                boxShadow: widget.isEnabled && !widget.isProcessing
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Shimmer sweep
                    if (widget.isEnabled && !widget.isProcessing)
                      Positioned(
                        left: (_shimmerController.value * 2 - 0.5) * MediaQuery.of(context).size.width,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Content
                    Center(
                      child: widget.isProcessing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      child: Text(
                                        widget.statusText,
                                        key: ValueKey(widget.statusText),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Text(
                                        widget.progressText,
                                        key: ValueKey(widget.progressText),
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_fix_high_rounded,
                                  color: widget.isEnabled
                                      ? Colors.white
                                      : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Erase Watermark',
                                  style: TextStyle(
                                    color: widget.isEnabled
                                        ? Colors.white
                                        : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: widget.isEnabled
                                        ? Colors.white.withValues(alpha: 0.18)
                                        : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bolt_rounded,
                                        size: 14,
                                        color: widget.isEnabled
                                            ? Colors.white
                                            : (isDark ? Colors.white24 : const Color(0xFF64748B)),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '1 Credit',
                                        style: TextStyle(
                                          color: widget.isEnabled
                                              ? Colors.white
                                              : (isDark ? Colors.white24 : const Color(0xFF64748B)),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
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
      },
    );
  }
}
