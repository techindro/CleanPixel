import 'package:flutter/material.dart';

class PaywallBadge extends StatefulWidget {
  final int currentCredits;
  final int maxCredits;
  final VoidCallback onTap;

  const PaywallBadge({
    Key? key,
    this.currentCredits = 142,
    this.maxCredits = 150,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PaywallBadge> createState() => _PaywallBadgeState();
}

class _PaywallBadgeState extends State<PaywallBadge> with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, _) {
        final angle = _sparkleController.value * 6.28;

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: SweepGradient(
                startAngle: angle,
                colors: const [
                  Color(0xFFF59E0B),
                  Color(0xFFEC4899),
                  Color(0xFF8B5CF6),
                  Color(0xFF38BDF8),
                  Color(0xFFF59E0B),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.25 + _sparkleController.value * 0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B0C24) : Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium_rounded, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 5),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                    ).createShader(bounds),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 1,
                    height: 12,
                    color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.currentCredits}/${widget.maxCredits}',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      fontSize: 10,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
