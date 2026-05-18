import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class CompvisScreen extends StatefulWidget {
  const CompvisScreen({super.key});

  @override
  State<CompvisScreen> createState() => _CompvisScreenState();
}

class _CompvisScreenState extends State<CompvisScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;
  late Animation<double> _scanAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _waveAnim;

  bool _isScanning = false;
  bool _scanComplete = false;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _scanAnim = CurvedAnimation(parent: _scanCtrl, curve: Curves.linear);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _waveAnim = CurvedAnimation(parent: _waveCtrl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _scanComplete = false;
      _progress = 0;
    });
    _scanCtrl.forward(from: 0);
    // Simulate progress
    for (int i = 1; i <= 100; i++) {
      Future.delayed(Duration(milliseconds: i * 30), () {
        if (mounted) {
          setState(() {
            _progress = i;
            if (_progress == 100) {
              _isScanning = false;
              _scanComplete = true;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          _buildBgFx(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        if (!_scanComplete) ...[
                          _buildCameraViewport(),
                          const SizedBox(height: 28),
                          _buildScanInfo(),
                          const SizedBox(height: 28),
                          _buildScanButton(),
                        ] else ...[
                          _buildResultsSection(),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBgFx() {
    return Stack(children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentCyan.withOpacity(0.05),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compvis Screening', style: AppTheme.titleLarge),
              Text('Deteksi via Kamera', style: AppTheme.bodySmall),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.cyanGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.camera_enhance_rounded,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraViewport() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _scanAnim, _waveAnim]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 340,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: const Color(0xFF050A14),
            border: Border.all(
              color: _isScanning
                  ? AppTheme.accentCyan.withOpacity(0.6)
                  : AppTheme.borderColor,
              width: 1.5,
            ),
            boxShadow: _isScanning
                ? [
                    BoxShadow(
                      color:
                          AppTheme.accentCyan.withOpacity(0.2 * _pulseAnim.value),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grid overlay
                CustomPaint(
                  size: const Size(double.infinity, 340),
                  painter: _GridPainter(
                    color: AppTheme.accentCyan.withOpacity(0.04),
                  ),
                ),
                // Face outline
                Container(
                  width: 180,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isScanning
                          ? AppTheme.accentCyan
                              .withOpacity(0.7 + 0.3 * _pulseAnim.value)
                          : AppTheme.textMuted.withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(120),
                  ),
                ),
                // Corner brackets
                ..._buildCornerBrackets(),
                // Scan line
                if (_isScanning)
                  Positioned(
                    top: 60 + (_scanAnim.value * 200),
                    left: 30,
                    right: 30,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.accentCyan.withOpacity(0.9),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentCyan.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                // Status text
                Positioned(
                  bottom: 20,
                  child: Column(
                    children: [
                      if (_isScanning) ...[
                        // rPPG wave simulation
                        SizedBox(
                          width: 200,
                          height: 30,
                          child: CustomPaint(
                            painter: _WavePainter(
                              progress: _waveAnim.value,
                              color: AppTheme.accentCyan,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Menganalisis sinyal rPPG... $_progress%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.accentCyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else
                        Text(
                          'Posisikan wajah di dalam bingkai',
                          style: AppTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCornerBrackets() {
    const size = 20.0;
    const strokeWidth = 2.5;
    final color = AppTheme.accentCyan;
    return [
      Positioned(
        top: 60,
        left: 60,
        child: CustomPaint(
          size: const Size(size, size),
          painter: _CornerPainter(corner: 0, color: color, sw: strokeWidth),
        ),
      ),
      Positioned(
        top: 60,
        right: 60,
        child: CustomPaint(
          size: const Size(size, size),
          painter: _CornerPainter(corner: 1, color: color, sw: strokeWidth),
        ),
      ),
      Positioned(
        bottom: 60,
        left: 60,
        child: CustomPaint(
          size: const Size(size, size),
          painter: _CornerPainter(corner: 2, color: color, sw: strokeWidth),
        ),
      ),
      Positioned(
        bottom: 60,
        right: 60,
        child: CustomPaint(
          size: const Size(size, size),
          painter: _CornerPainter(corner: 3, color: color, sw: strokeWidth),
        ),
      ),
    ];
  }

  Widget _buildScanInfo() {
    return Row(
      children: [
        _InfoChip(
          icon: Icons.timer_outlined,
          label: '~30 detik',
          color: AppTheme.accentCyan,
        ),
        const SizedBox(width: 10),
        _InfoChip(
          icon: Icons.lock_outline_rounded,
          label: 'Data Aman',
          color: AppTheme.accentGreen,
        ),
        const SizedBox(width: 10),
        _InfoChip(
          icon: Icons.sensors_rounded,
          label: 'rPPG Ready',
          color: AppTheme.accentPink,
        ),
      ],
    );
  }

  Widget _buildScanButton() {
    return GradientButton(
      label: _isScanning ? 'Memindai...' : 'Mulai Pemindaian',
      onTap: _isScanning ? () {} : _startScan,
      gradient: AppTheme.cyanGradient,
      icon: _isScanning ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded,
      width: double.infinity,
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success header
        GlassCard(
          borderColor: AppTheme.accentGreen.withOpacity(0.4),
          gradient: LinearGradient(colors: [
            AppTheme.accentGreen.withOpacity(0.1),
            AppTheme.accentCyan.withOpacity(0.05),
          ]),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppTheme.greenGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pemindaian Selesai!',
                        style: AppTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Hasil analisis tersedia di bawah',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Hasil Pemindaian', style: AppTheme.titleMedium),
        const SizedBox(height: 14),
        // Result grid
        Row(
          children: [
            Expanded(
              child: _ResultCard(
                label: 'DETAK JANTUNG',
                value: '74',
                unit: 'bpm',
                status: 'Normal',
                color: AppTheme.accentPink,
                icon: Icons.favorite_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ResultCard(
                label: 'SpO₂',
                value: '97',
                unit: '%',
                status: 'Normal',
                color: AppTheme.accentGreen,
                icon: Icons.air_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ResultCard(
                label: 'TINGKAT STRES',
                value: '42',
                unit: '%',
                status: 'Sedang',
                color: AppTheme.accent,
                icon: Icons.psychology_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ResultCard(
                label: 'VARIABILITAS HRV',
                value: '48',
                unit: 'ms',
                status: 'Cukup',
                color: AppTheme.accentCyan,
                icon: Icons.show_chart_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analisis AI', style: AppTheme.titleMedium),
              const SizedBox(height: 10),
              Text(
                'Kondisi kesehatanmu secara umum normal. Tingkat stres kamu sedikit di atas rata-rata, kemungkinan karena kurang tidur atau tekanan akademik. Disarankan untuk istirahat cukup dan lakukan teknik pernapasan dalam.',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GradientButton(
                    label: 'Scan Ulang',
                    onTap: () => setState(() => _scanComplete = false),
                    gradient: AppTheme.cyanGradient,
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    label: 'Konsultasi',
                    onTap: () => Navigator.pushNamed(context, '/consultation'),
                    gradient: AppTheme.primaryGradient,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Supporting Painters ────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          math.sin((x / size.width * 4 * math.pi) + (progress * 2 * math.pi)) *
              (size.height / 2.5);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

class _CornerPainter extends CustomPainter {
  final int corner; // 0=TL, 1=TR, 2=BL, 3=BR
  final Color color;
  final double sw;
  _CornerPainter({required this.corner, required this.color, required this.sw});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    switch (corner) {
      case 0:
        path.moveTo(size.width, 0);
        path.lineTo(0, 0);
        path.lineTo(0, size.height);
        break;
      case 1:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case 2:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case 3:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

// ─── Small helper widgets ────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String status;
  final Color color;
  final IconData icon;

  const _ResultCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 3),
                child: Text(unit,
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
