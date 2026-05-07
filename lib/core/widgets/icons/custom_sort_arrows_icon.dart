import 'package:flutter/material.dart';

class CustomSortArrowsIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const CustomSortArrowsIcon({
    super.key,
    this.size = 22.0,
    required this.color,
    this.strokeWidth = 2.2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SortArrowsIconPainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _SortArrowsIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _SortArrowsIconPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Geometry tuned to match XPlayer-like "two vertical arrows".
    // Increase the gap between arrows by ~3px total.
    final gapDelta = 1.5; // px
    final upX = (w * 0.40) - gapDelta;
    final downX = (w * 0.60) + gapDelta;
    final arrowHeight = h * 0.62;
    final top = h * 0.20;
    final bottom = h * 0.80;
    final head = w * 0.22;

    // Up arrow stem
    canvas.drawLine(
      Offset(upX, top + arrowHeight),
      Offset(upX, top),
      p,
    );
    // Up arrow head
    final upHead = Path()
      ..moveTo(upX - head / 2, top + head / 2)
      ..lineTo(upX, top)
      ..lineTo(upX + head / 2, top + head / 2);
    canvas.drawPath(upHead, p);

    // Down arrow stem
    canvas.drawLine(
      Offset(downX, bottom - arrowHeight),
      Offset(downX, bottom),
      p,
    );
    // Down arrow head
    final downHead = Path()
      ..moveTo(downX - head / 2, bottom - head / 2)
      ..lineTo(downX, bottom)
      ..lineTo(downX + head / 2, bottom - head / 2);
    canvas.drawPath(downHead, p);
  }

  @override
  bool shouldRepaint(covariant _SortArrowsIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

