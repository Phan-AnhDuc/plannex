import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable circular graphic with checklist icon
/// Commonly used as hero illustration in intro/onboarding screens
class ChecklistGraphic extends StatelessWidget {
  final double? size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ChecklistGraphic({
    super.key,
    this.size,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final double graphicSize = size ?? 200.w;
    
    return Container(
      width: graphicSize,
      height: graphicSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFB8A5D8), // Light purple
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: ChecklistIconPainter(
          color: foregroundColor ?? Colors.white,
        ),
        size: Size(graphicSize * 0.6, graphicSize * 0.6),
      ),
    );
  }
}

/// Custom painter for drawing checklist items (checkmarks + lines)
class ChecklistIconPainter extends CustomPainter {
  final Color color;
  
  ChecklistIconPainter({this.color = Colors.white});
  
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final itemHeight = size.height / 3;
    final startX = size.width * 0.15;
    final lineStartX = size.width * 0.35;
    final lineEndX = size.width * 0.85;

    // Draw three checklist items
    for (int i = 0; i < 3; i++) {
      final y = itemHeight * (i + 0.5);
      
      // Draw checkmark
      final checkPath = Path();
      final checkStartX = startX;
      final checkMidX = startX + size.width * 0.06;
      final checkEndX = startX + size.width * 0.15;
      
      checkPath.moveTo(checkStartX, y);
      checkPath.lineTo(checkMidX, y + itemHeight * 0.15);
      checkPath.lineTo(checkEndX, y - itemHeight * 0.15);
      canvas.drawPath(checkPath, checkPaint);

      // Draw two horizontal lines (task items representation)
      canvas.drawLine(
        Offset(lineStartX, y - itemHeight * 0.08),
        Offset(lineEndX, y - itemHeight * 0.08),
        linePaint,
      );
      canvas.drawLine(
        Offset(lineStartX, y + itemHeight * 0.08),
        Offset(lineEndX * 0.7, y + itemHeight * 0.08),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
