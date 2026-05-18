import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ─── Glowing Orb Widget (Digital Twin Avatar) ─────────────────────────────
class GlowingOrb extends StatefulWidget {
  final String mood; // 'calm', 'stressed', 'glitchy', 'happy'
  final double size;

  const GlowingOrb({super.key, required this.mood, this.size = 160});

  @override
  State<GlowingOrb> createState() => _GlowingOrbState();
}

class _GlowingOrbState extends State<GlowingOrb>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _glitchCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _glitchAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    _glitchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.mood == 'glitchy') {
      _glitchCtrl.repeat(reverse: true);
    }
    _glitchAnim =
        CurvedAnimation(parent: _glitchCtrl, curve: Curves.bounceOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _glitchCtrl.dispose();
    super.dispose();
  }

  Color get _primaryColor {
    switch (widget.mood) {
      case 'happy':
        return const Color(0xFF00E5A0);
      case 'calm':
        return const Color(0xFF6C63FF);
      case 'stressed':
        return const Color(0xFFFF6B9D);
      case 'glitchy':
        return const Color(0xFFFF3366);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  Color get _secondaryColor {
    switch (widget.mood) {
      case 'happy':
        return const Color(0xFF00D4FF);
      case 'calm':
        return const Color(0xFF9B59B6);
      case 'stressed':
        return const Color(0xFFFF8E53);
      case 'glitchy':
        return const Color(0xFF8B0000);
      default:
        return const Color(0xFF00D4FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _glitchAnim]),
      builder: (context, child) {
        final glitchOffset = widget.mood == 'glitchy'
            ? Offset(
                math.sin(_glitchAnim.value * math.pi * 8) * 3,
                math.cos(_glitchAnim.value * math.pi * 6) * 2,
              )
            : Offset.zero;

        return Transform.translate(
          offset: glitchOffset,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor
                            .withOpacity(0.15 + _pulseAnim.value * 0.1),
                        blurRadius: 50 + _pulseAnim.value * 20,
                        spreadRadius: 10 + _pulseAnim.value * 8,
                      ),
                    ],
                  ),
                ),
                // Main orb body
                Container(
                  width: widget.size * 0.85,
                  height: widget.size * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _primaryColor.withOpacity(0.9),
                        _secondaryColor.withOpacity(0.6),
                        _secondaryColor.withOpacity(0.1),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Inner highlight
                Positioned(
                  top: widget.size * 0.12,
                  left: widget.size * 0.2,
                  child: Container(
                    width: widget.size * 0.25,
                    height: widget.size * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
                // Face
                _buildFace(),
                // Glitch overlay
                if (widget.mood == 'glitchy')
                  Positioned(
                    left: 2,
                    child: Container(
                      width: widget.size * 0.85,
                      height: widget.size * 0.85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.cyan.withOpacity(0.2 * _glitchAnim.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFace() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Eye(mood: widget.mood, size: widget.size * 0.1),
            SizedBox(width: widget.size * 0.15),
            _Eye(mood: widget.mood, size: widget.size * 0.1),
          ],
        ),
        SizedBox(height: widget.size * 0.06),
        _Mouth(mood: widget.mood, size: widget.size),
      ],
    );
  }
}

class _Eye extends StatelessWidget {
  final String mood;
  final double size;
  const _Eye({required this.mood, required this.size});

  @override
  Widget build(BuildContext context) {
    if (mood == 'glitchy') {
      return Container(
        width: size,
        height: size * 0.4,
        color: Colors.white.withOpacity(0.9),
      );
    }
    return Container(
      width: size,
      height: mood == 'happy' ? size * 0.6 : size,
      decoration: BoxDecoration(
        shape: mood == 'happy' ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: mood == 'happy' ? BorderRadius.circular(4) : null,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }
}

class _Mouth extends StatelessWidget {
  final String mood;
  final double size;
  const _Mouth({required this.mood, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 0.3, size * 0.15),
      painter: _MouthPainter(mood: mood),
    );
  }
}

class _MouthPainter extends CustomPainter {
  final String mood;
  const _MouthPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (mood) {
      case 'happy':
        path.moveTo(cx - size.width * 0.4, cy);
        path.quadraticBezierTo(cx, cy + size.height, cx + size.width * 0.4, cy);
        break;
      case 'stressed':
      case 'glitchy':
        path.moveTo(cx - size.width * 0.4, cy + size.height * 0.3);
        path.quadraticBezierTo(cx, cy - size.height * 0.5, cx + size.width * 0.4, cy + size.height * 0.3);
        break;
      default: // calm / neutral
        path.moveTo(cx - size.width * 0.35, cy);
        path.lineTo(cx + size.width * 0.35, cy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MouthPainter old) => old.mood != mood;
}

// ─── Glassmorphic Card ──────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? borderColor;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.borderColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient ??
            LinearGradient(
              colors: [
                AppTheme.surfaceLight.withOpacity(0.8),
                AppTheme.surface.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        border: Border.all(
          color: borderColor ?? AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}

// ─── Gradient Button ───────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Gradient gradient;
  final IconData? icon;
  final double? width;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.gradient,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vitals Chip ───────────────────────────────────────────────────────────
class VitalChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const VitalChip({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label, style: AppTheme.labelStyle),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit, style: AppTheme.bodySmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
