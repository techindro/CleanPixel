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
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: widget.isEnabled
                    ? const LinearGradient(
                        colors: [Color(0xFFEC4899), Color(0xFFF43F5E), Color(0xFFE11D48)],
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFF1E293B),
                          const Color(0xFF1E293B).withValues(alpha: 0.8),
                        ],
                      ),
                boxShadow: widget.isEnabled && !widget.isProcessing
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
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
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.12),
                                Colors.white.withOpacity(0.0),
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
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white.withOpacity(0.9),
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
                                          fontWeight: FontWeight.w700,
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
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 11,
                                          fontFamily: 'monospace',
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
                                Icon(Icons.auto_fix_high_rounded,
                                    color: widget.isEnabled ? Colors.white : Colors.white38, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Erase Watermark',
                                  style: TextStyle(
                                    color: widget.isEnabled ? Colors.white : Colors.white38,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(widget.isEnabled ? 0.15 : 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt_rounded, size: 14,
                                          color: widget.isEnabled ? const Color(0xFF7DD3FC) : Colors.white24),
                                      const SizedBox(width: 2),
                                      Text(
                                        '1 Credit',
                                        style: TextStyle(
                                          color: widget.isEnabled ? const Color(0xFF7DD3FC) : Colors.white24,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
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
