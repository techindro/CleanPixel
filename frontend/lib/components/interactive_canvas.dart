import 'package:flutter/material.dart';

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  DrawingPoint({required this.offset, required this.paint});
}

class InteractiveCanvas extends StatefulWidget {
  final ImageProvider? sourceImage;
  final List<DrawingPoint?> points;
  final double currentStrokeWidth;
  final bool isBrush;
  final Function(Offset) onPanStart;
  final Function(Offset) onPanUpdate;
  final VoidCallback onPanEnd;

  const InteractiveCanvas({
    Key? key,
    required this.sourceImage,
    required this.points,
    this.currentStrokeWidth = 32.0,
    this.isBrush = true,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  }) : super(key: key);

  @override
  State<InteractiveCanvas> createState() => _InteractiveCanvasState();
}

class _InteractiveCanvasState extends State<InteractiveCanvas> {
  Offset? _currentCursor;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Source Image Layer
          if (widget.sourceImage != null)
            Image(
              image: widget.sourceImage!,
              fit: BoxFit.contain,
            ),

          // 2. Gesture Drawing Mask Layer
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                _currentCursor = details.localPosition;
                _isDragging = true;
              });
              widget.onPanStart(details.localPosition);
            },
            onPanUpdate: (details) {
              setState(() {
                _currentCursor = details.localPosition;
              });
              widget.onPanUpdate(details.localPosition);
            },
            onPanEnd: (_) {
              setState(() {
                _isDragging = false;
                _currentCursor = null;
              });
              widget.onPanEnd();
            },
            onPanCancel: () {
              setState(() {
                _isDragging = false;
                _currentCursor = null;
              });
              widget.onPanEnd();
            },
            child: CustomPaint(
              painter: MaskPainter(points: widget.points),
              size: Size.infinite,
            ),
          ),

          // 3. Live Dynamic Brush Reticle HUD
          if (_isDragging && _currentCursor != null)
            Positioned(
              left: _currentCursor!.dx - (widget.currentStrokeWidth / 2),
              top: _currentCursor!.dy - (widget.currentStrokeWidth / 2),
              child: IgnorePointer(
                child: Container(
                  width: widget.currentStrokeWidth,
                  height: widget.currentStrokeWidth,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isBrush ? const Color(0xFF38BDF8) : const Color(0xFFEF4444),
                      width: 2,
                    ),
                    color: (widget.isBrush ? const Color(0xFF38BDF8) : const Color(0xFFEF4444)).withValues(alpha: 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isBrush ? const Color(0xFF38BDF8) : const Color(0xFFEF4444)).withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MaskPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  MaskPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawCircle(
          points[i]!.offset,
          points[i]!.paint.strokeWidth / 2,
          points[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant MaskPainter oldDelegate) => true;
}
