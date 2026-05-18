import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnim = CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background decorations
          _buildBgDecorations(),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTopBar(),
                    const SizedBox(height: 36),
                    _buildGreetingSection(),
                    const SizedBox(height: 28),
                    _buildStatusCard(),
                    const SizedBox(height: 28),
                    _buildVitalsRow(),
                    const SizedBox(height: 28),
                    _buildQuickActions(),
                    const SizedBox(height: 28),
                    _buildInsightCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          // Bottom nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildBgDecorations() {
    return Stack(
      children: [
        // Top-right blob
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accent.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom-left blob
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentCyan.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'MediCore',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: AppTheme.textSecondary, size: 20),
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.accentPink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, Ifat 👋',
          style: AppTheme.displayMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Bagaimana kondisimu hari ini?',
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value * 4),
        child: child,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderColor: AppTheme.accent.withOpacity(0.3),
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.15),
            AppTheme.accentCyan.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.accentGreen.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'STATUS NORMAL',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentGreen,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kondisi tubuhmu\nterlihat baik hari ini',
                    style: AppTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pemindaian terakhir: 30 menit lalu',
                    style: AppTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    child: Row(
                      children: [
                        Text(
                          'Lihat detail',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppTheme.accentCyan, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GlowingOrb(mood: 'calm', size: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vital Signs', style: AppTheme.titleMedium),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: VitalChip(
                label: 'DETAK JANTUNG',
                value: '72',
                unit: 'bpm',
                color: AppTheme.accentPink,
                icon: Icons.favorite_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VitalChip(
                label: 'STRES',
                value: '34',
                unit: '%',
                color: AppTheme.accentCyan,
                icon: Icons.psychology_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: VitalChip(
                label: 'SpO₂',
                value: '98',
                unit: '%',
                color: AppTheme.accentGreen,
                icon: Icons.air_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VitalChip(
                label: 'SUHU TUBUH',
                value: '36.6',
                unit: '°C',
                color: AppTheme.accent,
                icon: Icons.thermostat_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aksi Cepat', style: AppTheme.titleMedium),
        const SizedBox(height: 14),
        Row(
          children: [
            _QuickActionButton(
              icon: Icons.camera_alt_rounded,
              label: 'Scan\nWajah',
              gradient: AppTheme.cyanGradient,
              onTap: () => Navigator.pushNamed(context, '/compvis'),
            ),
            const SizedBox(width: 12),
            _QuickActionButton(
              icon: Icons.mood_rounded,
              label: 'Mood\nTracker',
              gradient: AppTheme.pinkGradient,
              onTap: () => Navigator.pushNamed(context, '/mood-tracker'),
            ),
            const SizedBox(width: 12),
            _QuickActionButton(
              icon: Icons.smart_toy_rounded,
              label: 'AI\nDokter',
              gradient: AppTheme.primaryGradient,
              onTap: () => Navigator.pushNamed(context, '/consultation'),
            ),
            const SizedBox(width: 12),
            _QuickActionButton(
              icon: Icons.history_rounded,
              label: 'Riwayat',
              gradient: AppTheme.greenGradient,
              onTap: () => Navigator.pushNamed(context, '/features'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard() {
    return GlassCard(
      borderColor: AppTheme.accentPink.withOpacity(0.2),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.pinkGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.lightbulb_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insight Hari Ini',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level stresmu sedikit meningkat. Coba lakukan pemindaian wajah untuk evaluasi lebih lanjut.',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Beranda', active: true),
          _NavItem(icon: Icons.bar_chart_rounded, label: 'Statistik'),
          _NavItem(icon: Icons.history_rounded, label: 'Riwayat'),
          _NavItem(icon: Icons.person_rounded, label: 'Profil'),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppTheme.surfaceLight,
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => gradient.createShader(bounds),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? AppTheme.accent : AppTheme.textMuted,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppTheme.accent : AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
