import 'package:flutter/material.dart';

class ComparisonSlider extends StatefulWidget {
  final ImageProvider originalImage;
  final ImageProvider cleanedImage;

  const ComparisonSlider({
    Key? key,
    required this.originalImage,
    required this.cleanedImage,
  }) : super(key: key);

  @override
  State<ComparisonSlider> createState() => _ComparisonSliderState();
}

class _ComparisonSliderState extends State<ComparisonSlider> {
  double _dividerPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Cleaned Image (Bottom layer)
              Positioned.fill(
                child: Image(
                  image: widget.cleanedImage,
                  fit: BoxFit.contain,
                ),
              ),

              // Original Image (Clipped layer)
              Positioned.fill(
                child: ClipRect(
                  clipper: _HorizontalClipper(_dividerPosition),
                  child: Image(
                    image: widget.originalImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // "Before" label
              Positioned(
                top: 12,
                left: 12,
                child: _buildLabel('BEFORE', const Color(0xFFEF4444)),
              ),

              // "After" label
              Positioned(
                top: 12,
                right: 12,
                child: _buildLabel('AFTER', const Color(0xFF10B981)),
              ),

              // Divider Line & Handle
              Positioned(
                left: (width * _dividerPosition) - 16,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dividerPosition += details.delta.dx / width;
                      _dividerPosition = _dividerPosition.clamp(0.05, 0.95);
                    });
                  },
                  child: SizedBox(
                    width: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow line
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              width: 2,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Handle
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF2563EB), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chevron_left_rounded, size: 14, color: Color(0xFF0F172A)),
                              Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF0F172A)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _HorizontalClipper extends CustomClipper<Rect> {
  final double position;

  _HorizontalClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(_HorizontalClipper oldClipper) {
    return oldClipper.position != position;
  }
}
