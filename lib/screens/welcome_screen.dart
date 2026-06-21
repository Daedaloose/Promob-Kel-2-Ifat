import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late AnimationController _starController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _starAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _starAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sageMedium.withOpacity(0.3),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sageDark.withOpacity(0.2),
                ),
              ),
            ),

            // Floating stars
            _buildAnimatedStar(80, 200, 18),
            _buildAnimatedStar(size.width - 60, 180, 14),
            _buildAnimatedStar(40, 380, 12),
            _buildAnimatedStar(size.width - 40, 350, 20),
            _buildAnimatedStar(120, 150, 10),
            _buildAnimatedStar(size.width - 100, 280, 16),

            // Orange sparkle dots
            _buildSparkle(60, 310, AppColors.accentOrange, 6),
            _buildSparkle(size.width - 70, 400, AppColors.accentOrange, 5),
            _buildSparkle(90, 480, AppColors.accentOrange, 4),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Speech bubble
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: _buildSpeechBubble(),
                  ),

                  const SizedBox(height: 20),

                  // Brain mascot
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: _buildBrainMascot(),
                  ),

                  const Spacer(flex: 1),

                  // Bottom text section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Step Into\nYour Peaceful\n',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.textDark,
                                  width: 2.5,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                'Mind',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Breathe deeply, relax fully, and find calm.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textGrey,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Get Started Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: Container(
                        width: double.infinity,
                        height: 62,
                        decoration: BoxDecoration(
                          color: AppColors.darkButton,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            // Mini brain icon
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '🧠',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              child: const Text(
                                '>>>',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom indicator
                  Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Start Your\nMindful Journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),
          ),
          // Bubble tail
          Positioned(
            bottom: -16,
            left: 20,
            child: CustomPaint(
              painter: BubbleTailPainter(),
              size: const Size(24, 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrainMascot() {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: BrainMascotPainter(),
      ),
    );
  }

  Widget _buildAnimatedStar(double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _starAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _starAnimation.value,
            child: Transform.scale(
              scale: _starAnimation.value,
              child: CustomPaint(
                painter: StarPainter(color: Colors.white),
                size: Size(size, size),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSparkle(double left, double top, Color color, double size) {
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _starController,
        builder: (context, child) {
          return Opacity(
            opacity: _starAnimation.value * 0.8,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom Painters
class BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarPainter extends CustomPainter {
  final Color color;
  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // 4-pointed star
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 2;
      final radius = i % 2 == 0 ? r : r * 0.4;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrainMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - 10;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(cx, cy + 20), 72, shadowPaint);

    // Brain body - main pink/mauve color
    final bodyPaint = Paint()..color = const Color(0xFFD4A0A0);
    canvas.drawCircle(Offset(cx, cy), 70, bodyPaint);

    // Brain texture bumps - darker pink
    final bumpPaint = Paint()..color = const Color(0xFFC49090);
    // Top bumps
    canvas.drawCircle(Offset(cx - 30, cy - 40), 28, bumpPaint);
    canvas.drawCircle(Offset(cx + 30, cy - 40), 28, bumpPaint);
    canvas.drawCircle(Offset(cx - 55, cy - 10), 24, bumpPaint);
    canvas.drawCircle(Offset(cx + 55, cy - 10), 24, bumpPaint);
    canvas.drawCircle(Offset(cx - 40, cy + 30), 26, bumpPaint);
    canvas.drawCircle(Offset(cx + 40, cy + 30), 26, bumpPaint);

    // Re-draw main body on top to smooth
    final bodyPaint2 = Paint()..color = const Color(0xFFD4A0A0);
    canvas.drawCircle(Offset(cx, cy), 65, bodyPaint2);

    // Cheek blush left
    final blushPaint = Paint()..color = const Color(0xFFE87878).withOpacity(0.7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 32, cy + 16), width: 28, height: 16),
      blushPaint,
    );
    // Cheek blush right
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 32, cy + 16), width: 28, height: 16),
      blushPaint,
    );

    // Eyes background (white)
    final eyeWhitePaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 20, cy - 8), width: 28, height: 32),
      eyeWhitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 20, cy - 8), width: 28, height: 32),
      eyeWhitePaint,
    );

    // Eye outline
    final eyeOutlinePaint = Paint()
      ..color = const Color(0xFF5A3060)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 20, cy - 8), width: 28, height: 32),
      eyeOutlinePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 20, cy - 8), width: 28, height: 32),
      eyeOutlinePaint,
    );

    // Pupils (dark purple)
    final pupilPaint = Paint()..color = const Color(0xFF5A3060);
    canvas.drawCircle(Offset(cx - 20, cy - 6), 10, pupilPaint);
    canvas.drawCircle(Offset(cx + 20, cy - 6), 10, pupilPaint);

    // Eye shine
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 16, cy - 10), 4, shinePaint);
    canvas.drawCircle(Offset(cx + 24, cy - 10), 4, shinePaint);

    // Mouth (smile)
    final mouthPaint = Paint()
      ..color = const Color(0xFFE85858)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path();
    mouthPath.moveTo(cx - 18, cy + 20);
    mouthPath.quadraticBezierTo(cx, cy + 34, cx + 18, cy + 20);
    canvas.drawPath(mouthPath, mouthPaint);

    // Left arm (white glove hand)
    _drawArm(canvas, Offset(cx - 70, cy + 10), true);
    // Right arm (white glove hand)
    _drawArm(canvas, Offset(cx + 70, cy + 10), false);

    // Left leg
    _drawLeg(canvas, Offset(cx - 24, cy + 65), false);
    // Right leg
    _drawLeg(canvas, Offset(cx + 24, cy + 65), true);
  }

  void _drawArm(Canvas canvas, Offset pos, bool isLeft) {
    // Arm stub
    final armPaint = Paint()..color = const Color(0xFFD4A0A0);
    final armRect = isLeft
        ? Rect.fromCenter(center: Offset(pos.dx + 20, pos.dy), width: 40, height: 18)
        : Rect.fromCenter(center: Offset(pos.dx - 20, pos.dy), width: 40, height: 18);
    canvas.drawOval(armRect, armPaint);

    // White glove
    final glovePaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 16, glovePaint);

    // Glove outline
    final gloveOutline = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(pos, 16, gloveOutline);

    // Finger lines
    final fingerPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    if (isLeft) {
      // Raised hand fingers pointing up
      canvas.drawLine(
        Offset(pos.dx - 6, pos.dy + 6),
        Offset(pos.dx - 6, pos.dy - 8),
        fingerPaint,
      );
      canvas.drawLine(
        Offset(pos.dx, pos.dy + 4),
        Offset(pos.dx, pos.dy - 10),
        fingerPaint,
      );
      canvas.drawLine(
        Offset(pos.dx + 6, pos.dy + 6),
        Offset(pos.dx + 6, pos.dy - 8),
        fingerPaint,
      );
    } else {
      canvas.drawLine(
        Offset(pos.dx - 6, pos.dy + 6),
        Offset(pos.dx - 6, pos.dy - 8),
        fingerPaint,
      );
      canvas.drawLine(
        Offset(pos.dx, pos.dy + 4),
        Offset(pos.dx, pos.dy - 10),
        fingerPaint,
      );
      canvas.drawLine(
        Offset(pos.dx + 6, pos.dy + 6),
        Offset(pos.dx + 6, pos.dy - 8),
        fingerPaint,
      );
    }
  }

  void _drawLeg(Canvas canvas, Offset pos, bool isRight) {
    // Leg
    final legPaint = Paint()..color = const Color(0xFFD4A0A0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(pos.dx, pos.dy + 10), width: 18, height: 30),
        const Radius.circular(8),
      ),
      legPaint,
    );

    // Shoe (dark red/maroon)
    final shoePaint = Paint()..color = const Color(0xFFCC3333);
    final shoeOffset = isRight ? Offset(pos.dx + 8, pos.dy + 28) : Offset(pos.dx - 8, pos.dy + 28);
    canvas.drawOval(
      Rect.fromCenter(center: shoeOffset, width: 36, height: 20),
      shoePaint,
    );

    // Shoe shine
    final shoeShinePaint = Paint()..color = Colors.white.withOpacity(0.3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(shoeOffset.dx - 4, shoeOffset.dy - 3),
        width: 12,
        height: 6,
      ),
      shoeShinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
