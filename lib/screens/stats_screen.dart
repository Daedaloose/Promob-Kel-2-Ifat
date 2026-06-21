import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../services/mood_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _selectedPeriod = 1; // 0=Week, 1=Month, 2=Year

  final List<String> _periods = ['Week', 'Month', 'Year'];

  final MoodService _moodService = MoodService();
  bool _isLoading = true;

  int _totalSessions = 0;
  int _streak = 0;
  double _avgMoodScore = 0.0;

  List<Map<String, dynamic>> _weekData = [];
  List<Map<String, dynamic>> _moodDistribution = [];

  final List<Map<String, dynamic>> _activities = [
    {
      'name': 'Morning Yoga',
      'emoji': '🧘‍♀️',
      'sessions': 12,
      'total': 15,
      'color': const Color(0xFFEDE0D8),
    },
    {
      'name': 'Journaling',
      'emoji': '📓',
      'sessions': 18,
      'total': 30,
      'color': const Color(0xFFE8D8E8),
    },
    {
      'name': 'Meditation',
      'emoji': '🧠',
      'sessions': 8,
      'total': 15,
      'color': const Color(0xFFD8E8F0),
    },
    {
      'name': 'Breathing',
      'emoji': '💨',
      'sessions': 20,
      'total': 30,
      'color': const Color(0xFFD8F0E8),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _loadStats();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final records = await _moodService.fetchMoodHistory();

    if (records.isEmpty) {
      setState(() {
        _isLoading = false;
        _totalSessions = 28;
        _streak = 14;
        _avgMoodScore = 7.4;
        _weekData = [
          {'day': 'M', 'score': 6.0, 'mood': '😐'},
          {'day': 'T', 'score': 8.5, 'mood': '😍'},
          {'day': 'W', 'score': 7.0, 'mood': '🙂'},
          {'day': 'T', 'score': 5.0, 'mood': '😕'},
          {'day': 'F', 'score': 9.0, 'mood': '😍'},
          {'day': 'S', 'score': 7.5, 'mood': '🙂'},
          {'day': 'S', 'score': 6.5, 'mood': '🙂'},
        ];
        _moodDistribution = [
          {'label': 'Great', 'emoji': '😍', 'pct': 0.30, 'color': const Color(0xFF5AB8C0)},
          {'label': 'Good', 'emoji': '🙂', 'pct': 0.35, 'color': const Color(0xFF8FCC8F)},
          {'label': 'Neutral', 'emoji': '😐', 'pct': 0.18, 'color': const Color(0xFFF5D77A)},
          {'label': 'Sad', 'emoji': '😕', 'pct': 0.12, 'color': const Color(0xFFE8834A)},
          {'label': 'Angry', 'emoji': '😠', 'pct': 0.05, 'color': const Color(0xFFE85858)},
        ];
      });
      return;
    }

    double totalScore = 0.0;
    int happyCount = 0;
    int calmCount = 0;
    int anxiousCount = 0;
    int sadCount = 0;
    int frustratedCount = 0;

    final List<double> dayScores = List.filled(7, 0.0);
    final List<int> dayCounts = List.filled(7, 0);
    final List<String> dayEmojis = List.filled(7, '🙂');
    final List<String> dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    for (final item in records) {
      final mood = item['mood'] ?? 'Tenang';
      final createdAtStr = item['created_at'];
      
      double score = 7.5;
      String emoji = '😌';
      
      if (mood == 'Bahagia' || mood == '😄' || mood == 'Great') {
        score = 9.5;
        emoji = '😄';
        happyCount++;
      } else if (mood == 'Tenang' || mood == '😌' || mood == 'Good') {
        score = 8.0;
        emoji = '😌';
        calmCount++;
      } else if (mood == 'Cemas' || mood == '😰' || mood == 'Neutral') {
        score = 5.0;
        emoji = '😰';
        anxiousCount++;
      } else if (mood == 'Sedih' || mood == '😢' || mood == 'Sad') {
        score = 3.5;
        emoji = '😢';
        sadCount++;
      } else if (mood == 'Frustrasi' || mood == '😤' || mood == 'Angry') {
        score = 2.0;
        emoji = '😤';
        frustratedCount++;
      } else {
        calmCount++;
      }

      totalScore += score;

      if (createdAtStr != null) {
        try {
          final createdAt = DateTime.parse(createdAtStr).toLocal();
          if (createdAt.isAfter(startOfWeekDate) || createdAt.isAtSameMomentAs(startOfWeekDate)) {
            final index = createdAt.weekday - 1;
            dayScores[index] += score;
            dayCounts[index]++;
            dayEmojis[index] = emoji;
          }
        } catch (_) {}
      }
    }

    _totalSessions = records.length;
    _avgMoodScore = double.parse((totalScore / _totalSessions).toStringAsFixed(1));

    final Map<String, bool> activeDays = {};
    for (final item in records) {
      if (item['created_at'] != null) {
        try {
          final date = DateTime.parse(item['created_at']).toLocal();
          final key = '${date.year}-${date.month}-${date.day}';
          activeDays[key] = true;
        } catch (_) {}
      }
    }
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    while (true) {
      final key = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
      if (activeDays[key] == true) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    _streak = streak;

    _weekData = List.generate(7, (i) {
      final avgScore = dayCounts[i] == 0 ? 0.0 : (dayScores[i] / dayCounts[i]);
      return {
        'day': dayNames[i],
        'score': avgScore == 0 ? 5.0 : avgScore,
        'mood': dayEmojis[i],
      };
    });

    final int totalCount = happyCount + calmCount + anxiousCount + sadCount + frustratedCount;
    if (totalCount > 0) {
      _moodDistribution = [
        {
          'label': 'Bahagia',
          'emoji': '😄',
          'pct': happyCount / totalCount,
          'color': const Color(0xFFF5D77A)
        },
        {
          'label': 'Tenang',
          'emoji': '😌',
          'pct': calmCount / totalCount,
          'color': const Color(0xFF8FCC8F)
        },
        {
          'label': 'Cemas',
          'emoji': '😰',
          'pct': anxiousCount / totalCount,
          'color': const Color(0xFFE8834A)
        },
        {
          'label': 'Sedih',
          'emoji': '😢',
          'pct': sadCount / totalCount,
          'color': const Color(0xFF5AB8C0)
        },
        {
          'label': 'Frustrasi',
          'emoji': '😤',
          'pct': frustratedCount / totalCount,
          'color': const Color(0xFFE85858)
        },
      ].where((element) => (element['pct'] as double) > 0).toList();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.backgroundGreen,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Progress 📊',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Track your mindful journey',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Period selector
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: List.generate(_periods.length, (i) {
                              final isSelected = _selectedPeriod == i;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedPeriod = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.darkButton
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _periods[i],
                                        style: TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // White content
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F0),
                  borderRadius:
                      BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.sageDeep,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 24),

                          // Summary stats row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                _buildStatCard(_totalSessions.toString(), 'Total\nSessions', '🎯',
                                    AppColors.backgroundGreen),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                    _streak.toString(), 'Day\nStreak', '🔥', const Color(0xFFFAEADE)),
                                const SizedBox(width: 12),
                                _buildStatCard(_avgMoodScore.toString(), 'Avg\nMood', '💚',
                                    const Color(0xFFE8D8E8)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Mood trend chart
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mood Trend',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'This week\'s emotional flow',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 160,
                                    child: CustomPaint(
                                      painter:
                                          MoodChartPainter(data: _weekData),
                                      size: Size.infinite,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // X axis labels
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: _weekData
                                        .map((d) => Text(
                                              d['day'],
                                              style: const TextStyle(
                                                fontFamily: 'Fredoka',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textGrey,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Mood distribution
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mood Distribution',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      // Donut chart
                                      SizedBox(
                                        width: 110,
                                        height: 110,
                                        child: CustomPaint(
                                          painter: DonutChartPainter(
                                            data: _moodDistribution,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      // Legend
                                      Expanded(
                                        child: Column(
                                          children: _moodDistribution.map((item) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color: item['color'],
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    item['emoji'],
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      item['label'],
                                                      style: const TextStyle(
                                                        fontFamily: 'Fredoka',
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.textGrey,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${(item['pct'] * 100).toInt()}%',
                                                    style: const TextStyle(
                                                      fontFamily: 'Fredoka',
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.textDark,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Activity completion
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Activity Completion',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ..._activities.map((activity) {
                                    final pct =
                                        activity['sessions'] / activity['total'];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: activity['color'],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    activity['emoji'],
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  activity['name'],
                                                  style: const TextStyle(
                                                    fontFamily: 'Fredoka',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${activity['sessions']}/${activity['total']}',
                                                style: const TextStyle(
                                                  fontFamily: 'Fredoka',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: LinearProgressIndicator(
                                              value: pct,
                                              minHeight: 8,
                                              backgroundColor:
                                                  AppColors.backgroundGreen
                                                      .withOpacity(0.4),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                AppColors.sageDark,
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
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, String emoji, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom line chart painter
class MoodChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  MoodChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxScore = 10.0;
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 1;

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (size.height * (i * 2.5 / maxScore));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Compute points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * (size.width / (data.length - 1));
      final y = size.height - (size.height * (data[i]['score'] / maxScore));
      points.add(Offset(x, y));
    }

    // Filled area under line
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i].dy,
      );
      final cp2 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i + 1].dy,
      );
      fillPath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.sageDark.withOpacity(0.3),
          AppColors.sageDark.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i].dy,
      );
      final cp2 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i + 1].dy,
      );
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }
    final linePaint = Paint()
      ..color = AppColors.sageDark
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = AppColors.sageDark;
    final dotWhite = Paint()..color = Colors.white;
    for (final pt in points) {
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(pt, 3, dotWhite);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Donut chart painter
class DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  DonutChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 22.0;

    double startAngle = -math.pi / 2;
    for (final item in data) {
      final sweep = (item['pct'] as double) * 2 * math.pi;
      final paint = Paint()
        ..color = item['color']
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep - 0.04,
        false,
        paint,
      );
      startAngle += sweep;
    }

    // Center text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '65%',
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 - 6,
      ),
    );
    final subPainter = TextPainter(
      text: const TextSpan(
        text: 'Positive',
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textGrey,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    subPainter.paint(
      canvas,
      Offset(
        center.dx - subPainter.width / 2,
        center.dy + 4,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
