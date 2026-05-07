import 'package:flutter/material.dart';

/// Simple premium music-note icon (vector) tuned for NavigationBar.
class CustomMusicNoteIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool filled;
  final double strokeWidth;

  const CustomMusicNoteIcon({
    super.key,
    this.color,
    this.size = 24,
    this.filled = false,
    this.strokeWidth = 2.2,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.white70;
    return CustomPaint(
      size: Size.square(size),
      painter: _MusicNotePainter(
        color: c,
        filled: filled,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _MusicNotePainter extends CustomPainter {
  final Color color;
  final bool filled;
  final double strokeWidth;

  const _MusicNotePainter({
    required this.color,
    required this.filled,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke;

    // A minimal, clean "note" shape:
    // - vertical stem
    // - angled flag
    // - round head

    final stemX = w * 0.62;
    final stemTopY = h * 0.18;
    final stemBottomY = h * 0.70;

    final headCenter = Offset(w * 0.38, h * 0.74);
    final headR = w * 0.14;

    // Stem
    if (!filled) {
      canvas.drawLine(Offset(stemX, stemTopY), Offset(stemX, stemBottomY), paint);
    } else {
      // Filled stem as a thin rect.
      final stemW = strokeWidth;
      canvas.drawRect(
        Rect.fromLTWH(stemX - stemW / 2, stemTopY, stemW, stemBottomY - stemTopY),
        paint,
      );
    }

    // Flag (top right curve-ish)
    final flagPath = Path()
      ..moveTo(stemX, stemTopY)
      ..quadraticBezierTo(w * 0.83, h * 0.22, w * 0.84, h * 0.38)
      ..quadraticBezierTo(w * 0.83, h * 0.30, stemX, h * 0.30);

    if (filled) {
      canvas.drawPath(flagPath, paint);
    } else {
      canvas.drawPath(flagPath, paint);
    }

    // Head (circle)
    canvas.drawCircle(headCenter, headR, paint);

    // Connect head to stem (short diagonal)
    final connector = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(stemX, stemBottomY), Offset(headCenter.dx + headR * 0.55, headCenter.dy - headR * 0.35), connector);
  }

  @override
  bool shouldRepaint(covariant _MusicNotePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.filled != filled ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

