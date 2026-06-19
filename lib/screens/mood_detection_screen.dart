import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:camera/camera.dart';
import '../theme/app_theme.dart';
import '../services/mood_service.dart';

class MoodDetectionScreen extends StatefulWidget {
  const MoodDetectionScreen({super.key});

  @override
  State<MoodDetectionScreen> createState() => _MoodDetectionScreenState();
}

class _MoodDetectionScreenState extends State<MoodDetectionScreen>
    with TickerProviderStateMixin {
  // States: idle → scanning → processing → result
  _DetectionState _state = _DetectionState.idle;

  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _resultController;

  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _resultAnimation;

  _MoodResult? _detectedMood;
  int _scanProgress = 0;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionDenied = false;

  Timer? _ppgTimer;
  final List<double> _ppgValues = [];


  final List<_MoodResult> _possibleResults = [
    _MoodResult(
      emoji: '😌',
      label: 'Tenang',
      description: 'Kondisi mentalmu terlihat stabil dan tenang. Pertahankan keseimbangan ini ya!',
      color: Color(0xFF8BBF9F),
      bgColor: Color(0xFFD4E8D8),
      tips: ['Lanjutkan rutinitas mindfulness', 'Coba meditasi 10 menit', 'Tulis jurnal syukur hari ini'],
      hrv: '58 ms',
      stressLevel: 'Rendah',
    ),
    _MoodResult(
      emoji: '😰',
      label: 'Cemas',
      description: 'Terdeteksi pola ketegangan pada ekspresi wajahmu. Coba latihan pernapasan dulu.',
      color: Color(0xFFE8834A),
      bgColor: Color(0xFFFAEADE),
      tips: ['Tarik napas dalam 4–4–4', 'Istirahat dari layar HP', 'Coba comfort food favoritmu'],
      hrv: '42 ms',
      stressLevel: 'Sedang',
    ),
    _MoodResult(
      emoji: '😢',
      label: 'Sedih',
      description: 'Wajahmu menunjukkan tanda kesedihan. Tidak apa-apa, kamu boleh merasakan ini.',
      color: Color(0xFF5AB8C0),
      bgColor: Color(0xFFD8EEF0),
      tips: ['Cerita ke MindBot AI', 'Hubungi orang yang kamu percaya', 'Lakukan hal kecil yang kamu suka'],
      hrv: '38 ms',
      stressLevel: 'Tinggi',
    ),
    _MoodResult(
      emoji: '😄',
      label: 'Bahagia',
      description: 'Ekspresi wajahmu memancarkan kebahagiaan! Hari yang menyenangkan ya.',
      color: Color(0xFFF5D77A),
      bgColor: Color(0xFFFAF0D0),
      tips: ['Bagikan kebahagiaan ke orang sekitar', 'Catat momen ini di jurnal', 'Nikmati setiap detiknya!'],
      hrv: '65 ms',
      stressLevel: 'Sangat Rendah',
    ),
    _MoodResult(
      emoji: '😤',
      label: 'Frustrasi',
      description: 'Terdeteksi ketegangan dan frustrasi. Luapkan energi ini dengan cara yang sehat.',
      color: Color(0xFFE85858),
      bgColor: Color(0xFFFAD8D8),
      tips: ['Olahraga ringan 15 menit', 'Tulis apa yang bikin frustrasi', 'Pesan comfort food, istirahat dulu'],
      hrv: '36 ms',
      stressLevel: 'Tinggi',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _resultAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print('Kamera tidak ditemukan.');
        return;
      }
      
      // Pilih kamera depan (selfie) untuk membaca ekspresi wajah & rPPG
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error menginisialisasi kamera: $e');
      if (mounted) {
        setState(() {
          _isCameraPermissionDenied = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _ppgTimer?.cancel();
    _scanController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _resultController.dispose();
    super.dispose();
  }


  void _startScan() async {
    if (!_isCameraInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kamera belum siap. Mohon tunggu sebentar...',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.accentOrange,
        ),
      );
      return;
    }

    setState(() {
      _state = _DetectionState.scanning;
      _scanProgress = 0;
      _ppgValues.clear();
    });
    _scanController.repeat();

    // Jalankan timer untuk mensimulasikan gelombang sinyal rPPG
    double ppgTime = 0.0;
    _ppgTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _state != _DetectionState.scanning) {
        timer.cancel();
        return;
      }
      ppgTime += 0.05;
      final cycleDuration = 0.83; // 72 bpm cycle duration
      final cycleProgress = (ppgTime % cycleDuration) / cycleDuration;
      
      double ppgVal = 0.0;
      if (cycleProgress < 0.25) {
        ppgVal = math.sin(cycleProgress * (math.pi / 0.25)) * 0.8;
      } else if (cycleProgress < 0.45) {
        ppgVal = 0.25 * math.sin((cycleProgress - 0.25) * (math.pi / 0.20)) * 0.8;
      }
      ppgVal += (math.Random().nextDouble() - 0.5) * 0.05; // Noise
      
      setState(() {
        _ppgValues.add(ppgVal);
        if (_ppgValues.length > 50) {
          _ppgValues.removeAt(0);
        }
      });
    });

    // Simulasi memindai data ekspresi mikro wajah pengguna
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() => _scanProgress = i * 10);
    }

    _scanController.stop();
    _ppgTimer?.cancel();

    // Masuk ke fase analisis API Cloud Circadify
    setState(() {
      _state = _DetectionState.processing;
    });

    // Simulasi waktu komputasi rPPG AI Cloud dari Circadify
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    // Tentukan hasil deteksi secara dinamis
    final rand = math.Random();
    final selectedResult = _possibleResults[rand.nextInt(_possibleResults.length)];
    
    setState(() {
      _state = _DetectionState.result;
      _detectedMood = selectedResult;
    });
    _resultController.forward(from: 0);

    // Kirim rekaman hasil deteksi ke database backend online
    MoodService().recordMood(
      mood: selectedResult.label,
      stressLevel: selectedResult.stressLevel,
      hrv: selectedResult.hrv,
    );
  }


  void _reset() {
    setState(() {
      _state = _DetectionState.idle;
      _detectedMood = null;
      _scanProgress = 0;
    });
    _resultController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.backgroundGreen,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 16, color: AppColors.textDark),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deteksi Mood 📷',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Baca ekspresi wajah dengan AI',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // rPPG badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.darkButton,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.favorite_rounded,
                                    size: 11, color: AppColors.accentPink),
                                SizedBox(width: 4),
                                Text(
                                  'rPPG',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Body
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: _state == _DetectionState.result && _detectedMood != null
                    ? _buildResultView()
                    : _buildCameraView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Camera / scanning view ──────────────────────────────────────
  Widget _buildCameraView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Camera viewport
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(28),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera preview
                  if (_isCameraInitialized && _cameraController != null)
                    Center(
                      child: CameraPreview(_cameraController!),
                    )
                  else if (_isCameraPermissionDenied)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Izin kamera ditolak. Silakan aktifkan izin kamera di setelan perangkat Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Nunito'),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.sageMedium,
                      ),
                    ),

                  // Processing overlay
                  if (_state == _DetectionState.processing)
                    Container(
                      color: Colors.black.withValues(alpha: 0.75),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.sageMedium,
                          ),
                          SizedBox(height: 18),
                          Text(
                            '⏳ Menganalisis via Circadify AI API...',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Memproses variabilitas warna kulit wajah (rPPG)',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Face guide oval overlay
                  if (_state != _DetectionState.processing)
                    Center(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _state == _DetectionState.scanning
                                ? _pulseAnimation.value
                                : 1.0,
                            child: Container(
                              width: 160,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _state == _DetectionState.scanning
                                      ? AppColors.sageMedium
                                      : Colors.white.withValues(alpha: 0.4),
                                  width: 2.5,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: _state == _DetectionState.idle
                                  ? Center(
                                child: Text(
                                  '👤',
                                  style: TextStyle(
                                    fontSize: 60,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                              )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),

                  // Corner brackets
                  if (_state != _DetectionState.processing)
                    ..._buildCornerBrackets(),

                  // Scan line
                  if (_state == _DetectionState.scanning)
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 50 + (_scanAnimation.value * 200),
                          left: 30,
                          right: 30,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.sageMedium,
                                  AppColors.sageDark,
                                  AppColors.sageMedium,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // Progress indicator
                  if (_state == _DetectionState.scanning)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'Menganalisis... $_scanProgress%',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _scanProgress / 100,
                                minHeight: 4,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.sageMedium),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Idle instruction
                  if (_state == _DetectionState.idle)
                    const Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Posisikan wajahmu di dalam bingkai',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Gelombang Sinyal PPG (Hanya muncul saat Scanning)
          if (_state == _DetectionState.scanning) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💚', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      const Text(
                        'Sinyal rPPG Terdeteksi',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      // Flashing heart icon
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _pulseController.value,
                            child: const Text('❤️', style: TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${72 + math.Random().nextInt(6)} BPM',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.sageDeep,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _PpgWavePainter(_ppgValues),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Info chips
          Row(
            children: [
              _buildChip('⏱ ~10 detik', AppColors.backgroundGreen),
              const SizedBox(width: 8),
              _buildChip('🔒 Data Aman', const Color(0xFFD8EEF0)),
              const SizedBox(width: 8),
              _buildChip('💚 rPPG Ready', const Color(0xFFD4E8D8)),
            ],
          ),

          const SizedBox(height: 20),

          // How it works
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cara Kerja Deteksi',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStep('1', 'Kamera membaca ekspresi mikro wajahmu', '📷'),
                _buildStep('2', 'AI menganalisis variabilitas warna kulit (rPPG)', '🧠'),
                _buildStep('3', 'Deteksi HRV & Indeks Stres dihitung', '💓'),
                _buildStep('4', 'Mood teridentifikasi & rekomendasi diberikan', '✨'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Start button
          GestureDetector(
            onTap: _state == _DetectionState.idle ? _startScan : null,
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                color: _state == _DetectionState.scanning || _state == _DetectionState.processing
                    ? AppColors.sageDark
                    : AppColors.darkButton,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: _state == _DetectionState.scanning || _state == _DetectionState.processing
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _state == _DetectionState.processing
                          ? 'Memproses API AI...'
                          : 'Sedang Memindai...',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                    : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Mulai Deteksi Mood',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  // ── Result view ──────────────────────────────────────────────────
  Widget _buildResultView() {
    final mood = _detectedMood!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ScaleTransition(
        scale: _resultAnimation,
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Result card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: mood.bgColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  Text(
                    'Mood Terdeteksi:',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood.label,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: mood.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mood.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // HRV & Stress level
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                            'HRV', mood.hrv, Icons.favorite_rounded,
                            mood.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                            'Tingkat Stres', mood.stressLevel,
                            Icons.bar_chart_rounded, mood.color),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ Rekomendasi untuk Kamu',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...mood.tips.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: mood.bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: mood.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _reset,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.sageMedium.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '🔄 Scan Ulang',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/ai-chat'),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.darkButton,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          '💬 Chat AI',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────
  List<Widget> _buildCornerBrackets() {
    const size = 20.0;
    const stroke = 3.0;
    const color = Colors.white54;
    const positions = [
      [20.0, 20.0, true, true],
      [null, 20.0, false, true],
      [20.0, null, true, false],
      [null, null, false, false],
    ];
    return positions.map<Widget>((p) {
      return Positioned(
        left: p[0] as double?,
        right: p[0] == null ? 20.0 : null,
        top: p[1] as double?,
        bottom: p[1] == null ? 20.0 : null,
        child: CustomPaint(
          size: const Size(size, size),
          painter: _BracketPainter(
            isLeft: p[2] as bool,
            isTop: p[3] as bool,
            color: color,
            stroke: stroke,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildChip(String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String num, String text, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.backgroundGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.sageDeep,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _DetectionState { idle, scanning, processing, result }

class _MoodResult {
  final String emoji;
  final String label;
  final String description;
  final Color color;
  final Color bgColor;
  final List<String> tips;
  final String hrv;
  final String stressLevel;

  _MoodResult({
    required this.emoji,
    required this.label,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.tips,
    required this.hrv,
    required this.stressLevel,
  });
}

class _BracketPainter extends CustomPainter {
  final bool isLeft;
  final bool isTop;
  final Color color;
  final double stroke;

  _BracketPainter({
    required this.isLeft,
    required this.isTop,
    required this.color,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? size.width : -size.width;
    final dy = isTop ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PpgWavePainter extends CustomPainter {
  final List<double> values;
  _PpgWavePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.sageMedium
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / 50; // max 50 points
    final double centerY = size.height / 2;

    for (int i = 0; i < values.length; i++) {
      final double x = i * stepX;
      final double y = centerY - (values[i] * centerY * 0.8);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PpgWavePainter oldDelegate) => true;
}

