import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class FeatureScreen extends StatelessWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // BG glow
          Positioned(
            top: 80,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.accent.withOpacity(0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Back + title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: AppTheme.textSecondary, size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Pilih Fitur', style: AppTheme.displayMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Text(
                      'Apa yang ingin kamu pantau hari ini?',
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Feature Cards
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _FeatureCard(
                          index: 0,
                          icon: Icons.camera_enhance_rounded,
                          title: 'Compvis\nScreening Detection',
                          subtitle:
                              'Deteksi kondisi kesehatan melalui pemindaian wajah berbasis Computer Vision & rPPG.',
                          tags: ['rPPG', 'Heart Rate', 'Stres', 'SpO₂'],
                          gradient: AppTheme.cyanGradient,
                          glowColor: AppTheme.accentCyan,
                          onTap: () => Navigator.pushNamed(context, '/compvis'),
                        ),
                        const SizedBox(height: 16),
                        _FeatureCard(
                          index: 1,
                          icon: Icons.mood_rounded,
                          title: 'Mood\nTracker',
                          subtitle:
                              'Lacak dan visualisasikan kondisi emosimu setiap hari untuk memahami pola kesehatan mental.',
                          tags: ['Emosi', 'Log Harian', 'Grafik', 'Tren'],
                          gradient: AppTheme.pinkGradient,
                          glowColor: AppTheme.accentPink,
                          onTap: () =>
                              Navigator.pushNamed(context, '/mood-tracker'),
                        ),
                        const SizedBox(height: 16),
                        _FeatureCard(
                          index: 2,
                          icon: Icons.smart_toy_rounded,
                          title: 'Konsultasi\nOnline',
                          subtitle:
                              'Konsultasikan kondisi kesehatanmu dengan AI berbasis data rPPG atau dengan dokter langsung.',
                          tags: ['AI Chat', 'Dokter', 'Avatar', 'Personalisasi'],
                          gradient: AppTheme.primaryGradient,
                          glowColor: AppTheme.accent,
                          onTap: () =>
                              Navigator.pushNamed(context, '/consultation'),
                        ),
                        const SizedBox(height: 24),
                        // Info banner
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          borderColor: AppTheme.accentGreen.withOpacity(0.25),
                          child: Row(
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: AppTheme.accentGreen, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Semua data kesehatan diproses secara lokal dan aman di perangkat kamu.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final int index;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> tags;
  final Gradient gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppTheme.cardBg,
            border: Border.all(
              color: widget.glowColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // BG glow accent
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        widget.glowColor.withOpacity(0.12),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon + number row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: widget.gradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.glowColor.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(widget.icon,
                                color: Colors.white, size: 28),
                          ),
                          Text(
                            '0${widget.index + 1}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: widget.glowColor.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(widget.subtitle, style: AppTheme.bodyMedium),
                      const SizedBox(height: 18),
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color:
                                        widget.glowColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: widget.glowColor
                                            .withOpacity(0.25)),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: widget.glowColor,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: widget.gradient,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Mulai',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ],
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
  }
}
