import 'package:flutter/material.dart';

// Komponen Ilustrasi Wajah Comic Style
class MiniMochiFace extends StatelessWidget {
  final String mood;
  final Color baseColor;
  final double size;

  const MiniMochiFace({
    super.key, 
    required this.mood, 
    required this.baseColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MiniMochiPainter(mood: mood, color: baseColor),
      ),
    );
  }
}

class _MiniMochiPainter extends CustomPainter {
  final String mood;
  final Color color;

  _MiniMochiPainter({required this.mood, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;

    // Draw main body (slightly squished circle like a mochi)
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.9,
      height: size.height * 0.8,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.35));
    
    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);

    // Draw eyes and mouth based on mood
    final eyePaint = Paint()..color = Colors.black87..style = PaintingStyle.fill;
    final mouthPaint = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = size.width * 0.05;
    
    final leftEye = Offset(size.width * 0.35, size.height * 0.45);
    final rightEye = Offset(size.width * 0.65, size.height * 0.45);
    
    // Normalization mood names mapping (Happy/Sad/Calm/Anxious/Great/Good/Neutral/Angry)
    String normalizedMood = mood.toLowerCase();
    
    if (normalizedMood.contains('cemas') || normalizedMood.contains('anxious') || normalizedMood.contains('takut') || normalizedMood.contains('stres')) {
      // Wide open eyes, straight mouth
      canvas.drawCircle(leftEye, size.width * 0.08, eyePaint);
      canvas.drawCircle(rightEye, size.width * 0.08, eyePaint);
      // mouth
      canvas.drawLine(
        Offset(size.width * 0.4, size.height * 0.65), 
        Offset(size.width * 0.6, size.height * 0.65), 
        mouthPaint
      );
    } else if (normalizedMood.contains('lelah') || normalizedMood.contains('sad') || normalizedMood.contains('sedih') || normalizedMood.contains('angry') || normalizedMood.contains('frustrasi')) {
      // Closed/line eyes
      canvas.drawLine(Offset(size.width * 0.28, leftEye.dy), Offset(size.width * 0.42, leftEye.dy), mouthPaint);
      canvas.drawLine(Offset(size.width * 0.58, rightEye.dy), Offset(size.width * 0.72, rightEye.dy), mouthPaint);
      // open mouth (yawning/sad)
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.65), size.width * 0.08, eyePaint);
    } else { // Bahagia / Neutral / Happy / Great / Good
      // happy eyes (arches)
      final eyePath = Path()
        ..moveTo(size.width * 0.3, leftEye.dy)
        ..quadraticBezierTo(size.width * 0.35, leftEye.dy - size.height * 0.1, size.width * 0.4, leftEye.dy)
        ..moveTo(size.width * 0.6, rightEye.dy)
        ..quadraticBezierTo(size.width * 0.65, rightEye.dy - size.height * 0.1, size.width * 0.7, rightEye.dy);
      canvas.drawPath(eyePath, mouthPaint);
      // smiling mouth
      final mouthPath = Path()
        ..moveTo(size.width * 0.4, size.height * 0.6)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.75, size.width * 0.6, size.height * 0.6);
      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
