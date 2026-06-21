import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Map<String, dynamic> activity;
  const ActivityDetailScreen({super.key, required this.activity});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen>
    with SingleTickerProviderStateMixin {
  late YoutubePlayerController _ytController;
  late AnimationController _animationController;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi video ID berdasarkan judul aktivitas
    final videoId = _getVideoId(widget.activity['title']);
    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(_onPlayerStateChange);

    // Kontroler animasi untuk visualisasi komik Mochi-Brain
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  void _onPlayerStateChange() {
    if (mounted && _ytController.value.isReady && !_isPlayerReady) {
      setState(() {
        _isPlayerReady = true;
      });
    }
  }

  @override
  void dispose() {
    _ytController.removeListener(_onPlayerStateChange);
    _ytController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getVideoId(String title) {
    final cleaned = title.replaceAll('\n', ' ').toLowerCase();
    if (cleaned.contains('yoga')) {
      return 'sTANio_2E0Q'; // Yoga For Beginners
    } else if (cleaned.contains('journal')) {
      return 'YMz2P-4GPMg'; // Journaling for Clarity
    } else if (cleaned.contains('sleep') || cleaned.contains('meditation')) {
      return 'aEqlQvczU8Y'; // Guided Sleep Meditation
    } else if (cleaned.contains('breathing') || cleaned.contains('napas')) {
      return 'tEmt11yZyvs'; // Box Breathing Exercise
    }
    return 'tEmt11yZyvs';
  }

  Map<String, String> _getSourceInfo(String title) {
    final cleaned = title.replaceAll('\n', ' ').toLowerCase();
    if (cleaned.contains('yoga')) {
      return {
        'name': 'Harvard Health Publishing',
        'desc': 'Harvard Medical School menyimpulkan bahwa Yoga memperkuat respons saraf parasimpatik dan menurunkan hormon kortisol penyebab stres.',
        'url': 'https://www.health.harvard.edu/staying-healthy/the-physical-and-mental-benefits-of-yoga'
      };
    } else if (cleaned.contains('journal')) {
      return {
        'name': 'University of Rochester Medical Center',
        'desc': 'Riset URMC menunjukkan menulis jurnal membantu mengelola kecemasan, mengurangi stres, dan mengatasi depresi dengan memetakan emosi secara sadar.',
        'url': 'https://www.urmc.rochester.edu/encyclopedia/content.aspx?ContentID=4552&ContentTypeID=1'
      };
    } else if (cleaned.contains('sleep') || cleaned.contains('meditation')) {
      return {
        'name': 'Mayo Clinic & Sleep Foundation',
        'desc': 'Mayo Clinic memvalidasi meditasi tidur membantu merelaksasi sistem saraf pusat, memperlambat denyut jantung, dan meningkatkan kualitas tidur dalam (NREM).',
        'url': 'https://www.mayoclinic.org/healthy-lifestyle/stress-management/in-depth/meditation/art-20045858'
      };
    } else {
      return {
        'name': 'Cleveland Clinic (Box Breathing)',
        'desc': 'Metode pernapasan Box Breathing digunakan oleh NAVY Seals dan divalidasi oleh Cleveland Clinic untuk menyeimbangkan sistem saraf otonom secara instan.',
        'url': 'https://my.clevelandclinic.org/health/articles/24298-box-breathing'
      };
    }
  }

  List<String> _getSteps(String title) {
    final cleaned = title.replaceAll('\n', ' ').toLowerCase();
    if (cleaned.contains('yoga')) {
      return [
        'Cari matras atau permukaan empuk yang nyaman.',
        'Ambil pose duduk bersila dan tenangkan pikiran selama 1 menit.',
        'Lakukan Child\'s Pose (Balasana) untuk merilekskan tulang belakang.',
        'Transisi perlahan ke Cobra Pose untuk meregangkan dada dan melancarkan napas.',
        'Lakukan Downward Dog Pose untuk meregangkan kaki dan punggung bawah.'
      ];
    } else if (cleaned.contains('journal')) {
      return [
        'Buka jurnalmu (buku fisik atau fitur jurnal di Peaceful Mind).',
        'Tuliskan tanggal dan mood-mu saat ini sebagai pembuka.',
        'Catat 3 hal kecil yang paling kamu syukuri hari ini.',
        'Lakukan brain dump: tuangkan kekhawatiranmu tanpa sensor.',
        'Tulis 1 niat atau fokus positif untuk menjalani sisa hari.'
      ];
    } else if (cleaned.contains('sleep')) {
      return [
        'Redupkan atau matikan lampu kamar tidur Anda.',
        'Berbaringlah telentang dengan posisi tangan di samping tubuh.',
        'Tutup mata Anda perlahan dan sadari tarikan napas Anda.',
        'Lakukan body scan: sadari dan lepaskan ketegangan dari kaki ke kepala.',
        'Biarkan pikiran Anda mengalir bebas dan hanyut dalam ketenangan.'
      ];
    } else {
      return [
        'Duduklah dengan posisi tegak dan rilekskan pundak Anda.',
        'Hirup napas perlahan melalui hidung dalam hitungan 4 detik.',
        'Tahan napas Anda di dalam paru-paru selama 4 detik.',
        'Hembuskan napas perlahan melalui mulut selama 4 detik.',
        'Tahan paru-paru Anda dalam keadaan kosong selama 4 detik.'
      ];
    }
  }

  void _launchSourceUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Gagal membuka referensi ilmiah: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String cleanTitle = widget.activity['title'].replaceAll('\n', ' ');
    final sourceInfo = _getSourceInfo(widget.activity['title']);
    final steps = _getSteps(widget.activity['title']);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cleanTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Durasi: ${widget.activity['duration']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(color: Color(0xFFEFEFEF), height: 1, thickness: 1),

            // Main Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Ilustrasi Gaya Komik Mochi-Brain (Mindie)
                  MindieComicIllustration(
                    activityTitle: widget.activity['title'],
                    animation: _animationController,
                  ),

                  const SizedBox(height: 24),

                  // YouTube Player Card
                  const Text(
                    '🎬 Video Panduan Terintegrasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: YoutubePlayer(
                        controller: _ytController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: AppColors.sageDeep,
                        progressColors: const ProgressBarColors(
                          playedColor: AppColors.sageDeep,
                          handleColor: AppColors.sageDark,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Panduan langkah demi langkah
                  const Text(
                    '📝 Langkah-Langkah Kegiatan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...steps.asMap().entries.map((e) {
                    final index = e.key + 1;
                    final text = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.backgroundGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.sageDeep,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              text,
                              style: const TextStyle(
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

                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFEFEFEF), thickness: 1),
                  const SizedBox(height: 16),

                  // Referensi Ilmiah (Valid)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.sageMedium.withValues(alpha: 0.15),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🔬', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Rujukan Medis: ${sourceInfo['name']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sourceInfo['desc']!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => _launchSourceUrl(sourceInfo['url']!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.menu_book_rounded, size: 12, color: AppColors.sageDeep),
                                SizedBox(width: 6),
                                Text(
                                  'Baca Studi Referensi Asli',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.sageDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MindieComicIllustration extends StatelessWidget {
  final String activityTitle;
  final Animation<double> animation;
  const MindieComicIllustration({
    super.key,
    required this.activityTitle,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    // Teks gelembung komik berdasarkan jenis aktivitas
    String bubbleText = '';
    final cleaned = activityTitle.replaceAll('\n', ' ').toLowerCase();
    if (cleaned.contains('yoga')) {
      bubbleText = 'Yuk, ikuti gerakan ini untuk meregangkan ototmu biar segar!';
    } else if (cleaned.contains('journal')) {
      bubbleText = 'Ayo tuliskan 3 hal baik yang kita rasakan hari ini ya!';
    } else if (cleaned.contains('sleep')) {
      bubbleText = 'Matikan lampu, tarik selimut, dan mari tenangkan diri... Zzz';
    } else {
      bubbleText = 'Ikuti denyut lingkaran napas ini secara tenang dan rileks...';
    }

    return Column(
      children: [
        // Gelembung Ucapan Komik (Speech Bubble)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Stack(
            clipBehavior: ClipBehavior.none,
            children: [
              Text(
                '💬 "$bubbleText"',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
              // Ekor balon ucapan di bawah
              Positioned(
                bottom: -22,
                left: 40,
                child: CustomPaint(
                  size: const Size(12, 10),
                  painter: _BubbleTailPainter(),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 18),

        // Custom Paint Kanvas Mindie
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.sageMedium.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MindieComicPainter(
                    activityType: cleaned,
                    animVal: animation.value,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
    
    // Draw only left and right border edges for comic look
    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MindieComicPainter extends CustomPainter {
  final String activityType;
  final double animVal;

  _MindieComicPainter({required this.activityType, required this.animVal});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double cx = width / 2;
    final double cy = height / 2 + 10;

    // Tambah sedikit getaran melayang/bernapas (hover animation)
    final double hoverY = animVal * 5.0;

    // Tentukan warna tubuh Mindie (pinkish-brown brain color seperti welcome screen)
    final brainColor = const Color(0xFFC59595);
    final shadowColor = const Color(0xFFA57575);

    // ── BACKGROUND DETAILS ──
    final bgDetailPaint = Paint()
      ..color = AppColors.sageMedium.withValues(alpha: 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    // Draw comic starbursts / sparkles
    _drawSparkle(canvas, Offset(cx - 80, cy - 40), 6);
    _drawSparkle(canvas, Offset(cx + 80, cy - 25), 8);

    if (activityType.contains('yoga')) {
      // 🧘‍♀️ YOGA POSE: Mindie duduk di matras yoga
      // Matras yoga
      final matPaint = Paint()
        ..color = AppColors.sageMedium
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy + 30), width: 140, height: 6),
          const Radius.circular(3),
        ),
        matPaint,
      );

      // Kaki melipat bersila
      final legPaint = Paint()
        ..color = brainColor
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - 30, cy + 22 - hoverY), Offset(cx - 5, cy + 28 - hoverY), legPaint);
      canvas.drawLine(Offset(cx + 30, cy + 22 - hoverY), Offset(cx + 5, cy + 28 - hoverY), legPaint);

      // Sepatu Merah di samping matras (dilepas)
      final shoePaint = Paint()
        ..color = const Color(0xFFD32F2F)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 65, cy + 28), width: 14, height: 8), shoePaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 65, cy + 28), width: 14, height: 8), shoePaint);

      // Tubuh Mochi-Brain Mindie
      _drawMindieBody(canvas, Offset(cx, cy - hoverY), 34, brainColor, shadowColor);

      // Lengan Yoga: Tangan meregang ke atas / menyembah (Anjali Mudra)
      final armPaint = Paint()
        ..color = brainColor
        ..strokeWidth = 6.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      // Menggerakkan lengan ke atas menyerupai peregangan yoga
      final double armOffset = animVal * 6.0;
      canvas.drawLine(Offset(cx - 28, cy - 2 - hoverY), Offset(cx - 16, cy - 36 - armOffset - hoverY), armPaint);
      canvas.drawLine(Offset(cx + 28, cy - 2 - hoverY), Offset(cx + 16, cy - 36 - armOffset - hoverY), armPaint);
      
      // Sarung Tangan Putih (Anjali Mudra)
      _drawGlove(canvas, Offset(cx - 14, cy - 38 - armOffset - hoverY), 7);
      _drawGlove(canvas, Offset(cx + 14, cy - 38 - armOffset - hoverY), 7);

      // Wajah ekspresi rileks/senyum
      _drawMindieFace(canvas, Offset(cx, cy - hoverY), 34, smileCurvature: 3.5, eyesClosed: true);

    } else if (activityType.contains('journal')) {
      // 📓 JOURNAL POSE: Mindie memegang pensil raksasa di sebelah Buku Jurnal
      // Buku Jurnal di sebelah kiri
      final bookPaint = Paint()
        ..color = const Color(0xFF6A8EAD)
        ..style = PaintingStyle.fill;
      final bookOutline = Paint()
        ..color = AppColors.textDark
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final bookRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - 85, cy + 2 - hoverY, cx - 45, cy + 30 - hoverY),
        const Radius.circular(4),
      );
      canvas.drawRRect(bookRect, bookPaint);
      canvas.drawRRect(bookRect, bookOutline);

      // Kertas halaman dalam buku
      final paperPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTB(cx - 78, cy + 5 - hoverY, cx - 47, cy + 28 - hoverY), paperPaint);
      
      // Garis kertas notes
      final rulePaint = Paint()
        ..color = Colors.grey.shade300
        ..strokeWidth = 1;
      for (double y = cy + 10; y < cy + 26; y += 4) {
        canvas.drawLine(Offset(cx - 75, y - hoverY), Offset(cx - 50, y - hoverY), rulePaint);
      }

      // Kaki Berdiri (Mindie)
      _drawStandingLegs(canvas, Offset(cx, cy - hoverY), 34, animVal);

      // Tubuh Mochi-Brain Mindie
      _drawMindieBody(canvas, Offset(cx, cy - hoverY), 34, brainColor, shadowColor);

      // Pensil raksasa di tangan kanan Mindie
      final pencilPaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.fill;
      final leadPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;

      // Gambar pensil miring
      final pencilPath = Path()
        ..moveTo(cx + 34, cy - 25 - hoverY)
        ..lineTo(cx + 42, cy - 35 - hoverY)
        ..lineTo(cx + 48, cy - 31 - hoverY)
        ..lineTo(cx + 40, cy - 21 - hoverY)
        ..close();
      canvas.drawPath(pencilPath, pencilPaint);

      // Ujung pensil menulis di dekat buku
      final double tipX = cx - 25;
      final double tipY = cy + 5;
      
      // Garis penghubung tangan ke pensil
      final armPaint = Paint()
        ..color = brainColor
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx + 28, cy - hoverY), Offset(cx + 38, cy - 18 - hoverY), armPaint);
      _drawGlove(canvas, Offset(cx + 38, cy - 18 - hoverY), 7.5);

      // Tangan Kiri melambai
      final double waveVal = math.sin(animVal * math.pi * 2) * 5.0;
      canvas.drawLine(Offset(cx - 28, cy - hoverY), Offset(cx - 38, cy - 12 + waveVal - hoverY), armPaint);
      _drawGlove(canvas, Offset(cx - 38, cy - 12 + waveVal - hoverY), 7.5);

      // Wajah ceria
      _drawMindieFace(canvas, Offset(cx, cy - hoverY), 34, smileCurvature: 4.5, eyesClosed: false);

    } else if (activityType.contains('sleep') || activityType.contains('meditation')) {
      // 🌙 SLEEP MEDITATION: Mindie memakai topi tidur & tertidur lelap di atas awan
      // Awan tempat tidur
      final cloudPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      
      final cloudPath = Path()
        ..moveTo(cx - 60, cy + 25)
        ..cubicTo(cx - 80, cy + 10, cx - 40, cy - 5, cx - 20, cy + 10)
        ..cubicTo(cx, cy - 10, cx + 45, cy - 5, cx + 25, cy + 15)
        ..cubicTo(cx + 55, cy + 5, cx + 80, cy + 20, cx + 60, cy + 32)
        ..lineTo(cx - 60, cy + 32)
        ..close();
      canvas.drawPath(cloudPath, cloudPaint);

      // Tubuh Mochi-Brain Mindie (posisi tiduran agak miring)
      final double sleepTilt = 0.15; // radian
      canvas.save();
      canvas.translate(cx, cy - 4 - hoverY);
      canvas.rotate(-sleepTilt);
      
      _drawMindieBody(canvas, Offset.zero, 34, brainColor, shadowColor);

      // Topi tidur garis-garis biru (Nightcap) di atas kepala
      final capPaint = Paint()
        ..color = const Color(0xFF6C9CBF)
        ..style = PaintingStyle.fill;
      final capOutline = Paint()
        ..color = AppColors.textDark
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      final capPath = Path()
        ..moveTo(-20, -25)
        ..cubicTo(-10, -42, 10, -42, 15, -28)
        ..cubicTo(22, -45, 36, -30, 32, -22)
        ..lineTo(-20, -25)
        ..close();
      canvas.drawPath(capPath, capPaint);
      canvas.drawPath(capPath, capOutline);

      // Bola pom-pom putih di ujung topi tidur
      final pomPomPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(32, -22), 5, pomPomPaint);
      canvas.drawCircle(const Offset(32, -22), 5, capOutline);

      // Tangan melipat tenang di dada
      final armPaint = Paint()
        ..color = brainColor
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(-28, 4), const Offset(-10, 8), armPaint);
      canvas.drawLine(const Offset(28, 4), const Offset(10, 8), armPaint);
      _drawGlove(canvas, const Offset(-10, 8), 7);
      _drawGlove(canvas, const Offset(10, 8), 7);

      // Wajah tidur nyenyak
      _drawMindieFace(canvas, Offset.zero, 34, smileCurvature: 1.5, eyesClosed: true);

      canvas.restore();

      // Gelembung "Zzz..." tidur
      final double zOffset = (animVal * 15.0);
      final double zSize = 6.0 + animVal * 4.0;
      final zStyle = TextStyle(
        fontSize: zSize,
        fontWeight: FontWeight.bold,
        color: Colors.lightBlue.shade200,
        fontFamily: 'Courier',
      );
      final zPainter = TextPainter(
        text: TextSpan(text: 'Zzz', style: zStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      zPainter.paint(canvas, Offset(cx + 42, cy - 40 - zOffset));

    } else {
      // 💨 BREATHING EXERCISE: Mindie duduk bersila di tengah riak napas melingkar
      // Riak lingkaran pernapasan (Concentric Breathing Circles)
      // Lingkaran membesar & mengecil berdasarkan nilai animasi
      final double maxRadius = 75.0;
      final double minRadius = 45.0;
      final double currentRadius = minRadius + (animVal * (maxRadius - minRadius));

      final wavePaint = Paint()
        ..color = Colors.cyan.withValues(alpha: 0.15 - (animVal * 0.08))
        ..strokeWidth = 2.0 + (1.0 - animVal) * 3.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(cx, cy), currentRadius, wavePaint);

      final wavePaint2 = Paint()
        ..color = Colors.cyan.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), currentRadius, wavePaint2);

      // Kaki bersila (yoga-like sitting)
      final legPaint = Paint()
        ..color = brainColor
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - 30, cy + 20), Offset(cx - 5, cy + 25), legPaint);
      canvas.drawLine(Offset(cx + 30, cy + 20), Offset(cx + 5, cy + 25), legPaint);

      // Tubuh Mochi-Brain Mindie (bernapas teratur)
      // Skala tubuh sedikit membesar & mengecil mewakili tarikan/hembusan napas
      final double scale = 0.96 + (animVal * 0.08);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(scale, scale);

      _drawMindieBody(canvas, Offset.zero, 34, brainColor, shadowColor);

      // Lengan ditaruh di lutut bermeditasi
      final armPaint = Paint()
        ..color = brainColor
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(-28, 2), const Offset(-36, 16), armPaint);
      canvas.drawLine(const Offset(28, 2), const Offset(36, 16), armPaint);
      _drawGlove(canvas, const Offset(-36, 16), 7);
      _drawGlove(canvas, const Offset(36, 16), 7);

      // Wajah fokus/tenang dengan mata terpejam rileks
      _drawMindieFace(canvas, Offset.zero, 34, smileCurvature: 2.0, eyesClosed: true);

      canvas.restore();

      // Animasi awan napas di mulut
      final breathOpacity = animVal;
      final breathSize = 8.0 + animVal * 12.0;
      final breathPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: 0.2 * breathOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy + 12), breathSize, breathPaint);
    }
  }

  // Helper untuk menggambar tubuh bergelombang Mochi-Brain Mindie
  void _drawMindieBody(Canvas canvas, Offset center, double radius, Color color, Color shadow) {
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = AppColors.textDark
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    // Gambar lingkaran bergelombang (seperti awan / otak / cookies)
    final path = Path();
    const int lobes = 8;
    for (int i = 0; i < lobes; i++) {
      double angle1 = (i * 2 * math.pi) / lobes;
      double angle2 = ((i + 1) * 2 * math.pi) / lobes;
      double midAngle = (angle1 + angle2) / 2;

      // Titik kontrol melengkung keluar
      double rOuter = radius + 5.0;
      
      double x1 = center.dx + math.cos(angle1) * radius;
      double y1 = center.dy + math.sin(angle1) * radius;
      double x2 = center.dx + math.cos(angle2) * radius;
      double y2 = center.dy + math.sin(angle2) * radius;
      double mx = center.dx + math.cos(midAngle) * rOuter;
      double my = center.dy + math.sin(midAngle) * rOuter;

      if (i == 0) {
        path.moveTo(x1, y1);
      }
      path.quadraticBezierTo(mx, my, x2, y2);
    }
    path.close();

    // Gambar bayangan tubuh sisi bawah
    final shadowPaint = Paint()
      ..color = shadow
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.clipPath(path);
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.5), radius, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, bodyPaint);
    canvas.drawPath(path, outlinePaint);
  }

  // Helper untuk menggambar sarung tangan kartun putih
  void _drawGlove(Canvas canvas, Offset center, double radius) {
    final glovePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = AppColors.textDark
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, glovePaint);
    canvas.drawCircle(center, radius, outlinePaint);

    // Detail 3 garis sarung tangan kartun klasik
    final detailPaint = Paint()
      ..color = AppColors.textDark
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - 1.5, center.dy - 3), Offset(center.dx - 1.5, center.dy + 3), detailPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 3.5), Offset(center.dx, center.dy + 3.5), detailPaint);
    canvas.drawLine(Offset(center.dx + 1.5, center.dy - 3), Offset(center.dx + 1.5, center.dy + 3), detailPaint);
  }

  // Helper kaki berdiri kartun
  void _drawStandingLegs(Canvas canvas, Offset bodyCenter, double bodyRadius, double anim) {
    final legPaint = Paint()
      ..color = const Color(0xFFC59595)
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final outlinePaint = Paint()
      ..color = AppColors.textDark
      ..strokeWidth = 1.5;

    final shoePaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;
    final shoeOutline = Paint()
      ..color = AppColors.textDark
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Kaki kiri & kanan
    final double leftY = bodyCenter.dy + bodyRadius - 3;
    final double rightY = bodyCenter.dy + bodyRadius - 3;
    final double legLength = 18.0;

    // Animasi melangkah ringan
    final double walkOffset = math.sin(anim * math.pi * 2) * 2.5;

    // Kaki Kiri
    canvas.drawLine(Offset(bodyCenter.dx - 12, leftY), Offset(bodyCenter.dx - 12, leftY + legLength + walkOffset), legPaint);
    canvas.drawLine(Offset(bodyCenter.dx - 12, leftY), Offset(bodyCenter.dx - 12, leftY + legLength + walkOffset), outlinePaint);
    // Sepatu Kiri
    final shoeLeftRect = Rect.fromCenter(center: Offset(bodyCenter.dx - 15, leftY + legLength + walkOffset + 2), width: 15, height: 8);
    canvas.drawOval(shoeLeftRect, shoePaint);
    canvas.drawOval(shoeLeftRect, shoeOutline);

    // Kaki Kanan
    canvas.drawLine(Offset(bodyCenter.dx + 12, rightY), Offset(bodyCenter.dx + 12, rightY + legLength - walkOffset), legPaint);
    canvas.drawLine(Offset(bodyCenter.dx + 12, rightY), Offset(bodyCenter.dx + 12, rightY + legLength - walkOffset), outlinePaint);
    // Sepatu Kanan
    final shoeRightRect = Rect.fromCenter(center: Offset(bodyCenter.dx + 15, rightY + legLength - walkOffset + 2), width: 15, height: 8);
    canvas.drawOval(shoeRightRect, shoePaint);
    canvas.drawOval(shoeRightRect, shoeOutline);
  }

  // Helper untuk mata dan senyum khas Mindie
  void _drawMindieFace(Canvas canvas, Offset center, double radius, {required double smileCurvature, required bool eyesClosed}) {
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pupilPaint = Paint()
      ..color = AppColors.textDark
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = AppColors.textDark
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final double eyeY = center.dy - 5;
    final double eyeSpacing = 8.0;

    if (eyesClosed) {
      // Mata terpejam damai (garis lengkung ke bawah ^ atau U terbalik)
      final sleepEyePaint = Paint()
        ..color = AppColors.textDark
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      // Mata kiri
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx - eyeSpacing - 2, eyeY), width: 10, height: 7),
        0,
        math.pi,
        false,
        sleepEyePaint,
      );
      // Mata kanan
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx + eyeSpacing + 2, eyeY), width: 10, height: 7),
        0,
        math.pi,
        false,
        sleepEyePaint,
      );
    } else {
      // Mata kartun besar bulat terbuka
      // Mata Kiri
      canvas.drawCircle(Offset(center.dx - eyeSpacing, eyeY), 7, eyePaint);
      canvas.drawCircle(Offset(center.dx - eyeSpacing, eyeY), 7, outlinePaint);
      canvas.drawCircle(Offset(center.dx - eyeSpacing + 1, eyeY), 3.5, pupilPaint);
      canvas.drawCircle(Offset(center.dx - eyeSpacing - 1.2, eyeY - 2.2), 1.2, eyePaint); // Kilau mata

      // Mata Kanan
      canvas.drawCircle(Offset(center.dx + eyeSpacing, eyeY), 7, eyePaint);
      canvas.drawCircle(Offset(center.dx + eyeSpacing, eyeY), 7, outlinePaint);
      canvas.drawCircle(Offset(center.dx + eyeSpacing - 1, eyeY), 3.5, pupilPaint);
      canvas.drawCircle(Offset(center.dx + eyeSpacing - 3.2, eyeY - 2.2), 1.2, eyePaint); // Kilau mata
    }

    // Rosy Blushing Cheeks (Blush merah muda)
    final blushPaint = Paint()
      ..color = const Color(0xFFF2A2A2).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - eyeSpacing - 6, eyeY + 5), 4, blushPaint);
    canvas.drawCircle(Offset(center.dx + eyeSpacing + 6, eyeY + 5), 4, blushPaint);

    // Senyuman
    final smilePaint = Paint()
      ..color = AppColors.textDark
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final smilePath = Path()
      ..moveTo(center.dx - 8, eyeY + 10)
      ..quadraticBezierTo(center.dx, eyeY + 10 + smileCurvature, center.dx + 8, eyeY + 10);
    canvas.drawPath(smilePath, smilePaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MindieComicPainter oldDelegate) {
    return oldDelegate.animVal != animVal || oldDelegate.activityType != activityType;
  }
}
