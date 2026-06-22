import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../services/mood_service.dart';
import '../services/local_journal_state.dart';

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

  List<Map<String, dynamic>> _activities = [
    {
      'name': 'Morning Yoga',
      'emoji': '🧘‍♀️',
      'sessions': 0,
      'total': 15,
      'color': const Color(0xFFEDE0D8),
    },
    {
      'name': 'Journaling',
      'emoji': '📓',
      'sessions': 0,
      'total': 30,
      'color': const Color(0xFFE8D8E8),
    },
    {
      'name': 'Meditation',
      'emoji': '🧠',
      'sessions': 0,
      'total': 15,
      'color': const Color(0xFFD8E8F0),
    },
    {
      'name': 'Breathing',
      'emoji': '💨',
      'sessions': 0,
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

    // Give a small delay to simulate processing and allow UI to render smoothly
    await Future.delayed(const Duration(milliseconds: 300));

    final moodJournals = LocalJournalState.moodJournals;
    final activityJournals = LocalJournalState.activityJournals;

    _totalSessions = moodJournals.length + activityJournals.length;

    // Determine Start Date for the selected period
    final now = DateTime.now();
    DateTime startDate;
    if (_selectedPeriod == 0) { // Week
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else if (_selectedPeriod == 1) { // Month
      startDate = DateTime(now.year, now.month, 1);
    } else { // Year
      startDate = DateTime(now.year, 1, 1);
    }

    // Calculate streak across ALL data
    final Map<String, bool> activeDays = {};
    for (final item in moodJournals) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(int.parse(item['id'])).toLocal();
        activeDays['${date.year}-${date.month}-${date.day}'] = true;
      } catch (_) {}
    }
    for (final item in activityJournals) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(int.parse(item['id'])).toLocal();
        activeDays['${date.year}-${date.month}-${date.day}'] = true;
      } catch (_) {}
    }

    int streak = 0;
    DateTime checkDate = DateTime.now();
    while (true) {
      if (activeDays['${checkDate.year}-${checkDate.month}-${checkDate.day}'] == true) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    _streak = streak;

    // Parse Data for Trend & Distribution
    double totalScore = 0.0;
    int happyCount = 0, calmCount = 0, anxiousCount = 0, sadCount = 0, frustratedCount = 0;
    int validMoods = 0;

    int pointsCount = _selectedPeriod == 0 ? 7 : (_selectedPeriod == 1 ? 4 : 12);
    final List<double> pointScores = List.filled(pointsCount, 0.0);
    final List<int> pointCounts = List.filled(pointsCount, 0);
    final List<String> pointEmojis = List.filled(pointsCount, '🙂');
    
    List<String> pointNames = [];
    if (_selectedPeriod == 0) pointNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    else if (_selectedPeriod == 1) pointNames = ['W1', 'W2', 'W3', 'W4'];
    else pointNames = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

    for (final item in moodJournals) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(int.parse(item['id'])).toLocal();
        // Ignore data outside the selected period for the chart
        if (date.isBefore(startDate)) continue; 
        
        final mood = item['mood'] ?? 'Tenang';
        double score = 7.5;
        String emoji = '😌';
        
        if (mood == 'Bahagia' || mood == 'Great') { score = 9.5; emoji = '😄'; happyCount++; }
        else if (mood == 'Tenang' || mood == 'Good') { score = 8.0; emoji = '😌'; calmCount++; }
        else if (mood == 'Cemas' || mood == 'Neutral') { score = 5.0; emoji = '😰'; anxiousCount++; }
        else if (mood == 'Sedih' || mood == 'Sad') { score = 3.5; emoji = '😢'; sadCount++; }
        else if (mood == 'Lelah' || mood == 'Frustrasi') { score = 2.0; emoji = '😤'; frustratedCount++; }
        
        totalScore += score;
        validMoods++;

        int index = 0;
        if (_selectedPeriod == 0) {
          index = date.weekday - 1;
        } else if (_selectedPeriod == 1) {
          int week = ((date.day - 1) / 7).floor();
          index = week > 3 ? 3 : week;
        } else {
          index = date.month - 1;
        }

        pointScores[index] += score;
        pointCounts[index]++;
        pointEmojis[index] = emoji;
      } catch (_) {}
    }

    _avgMoodScore = validMoods > 0 ? double.parse((totalScore / validMoods).toStringAsFixed(1)) : 0.0;

    _weekData = List.generate(pointsCount, (i) {
      final avgScore = pointCounts[i] == 0 ? 0.0 : (pointScores[i] / pointCounts[i]);
      return {
        'day': pointNames[i],
        'score': avgScore == 0 ? 5.0 : avgScore,
        'mood': pointEmojis[i],
      };
    });

    final int totalCount = happyCount + calmCount + anxiousCount + sadCount + frustratedCount;
    if (totalCount > 0) {
      _moodDistribution = [
        {'label': 'Bahagia', 'emoji': '😄', 'pct': happyCount / totalCount, 'color': const Color(0xFFF5D77A)},
        {'label': 'Tenang', 'emoji': '😌', 'pct': calmCount / totalCount, 'color': const Color(0xFF8FCC8F)},
        {'label': 'Cemas', 'emoji': '😰', 'pct': anxiousCount / totalCount, 'color': const Color(0xFFE8834A)},
        {'label': 'Sedih', 'emoji': '😢', 'pct': sadCount / totalCount, 'color': const Color(0xFF5AB8C0)},
        {'label': 'Lelah/Frustrasi', 'emoji': '😤', 'pct': frustratedCount / totalCount, 'color': const Color(0xFFE85858)},
      ].where((element) => (element['pct'] as double) > 0).toList();
    } else {
      // Dummy data if empty
      _moodDistribution = [
        {'label': 'Kosong', 'emoji': '😶', 'pct': 1.0, 'color': Colors.grey[300]!},
      ];
    }

    setState(() {
      _isLoading = false;
    });
    _calculateActivityStats();
  }

  void _calculateActivityStats() {
    // Import LocalJournalState here or at the top of the file
    // Let's assume we import it. If we haven't, the compiler will catch it.
    // Count activities from LocalJournalState
    final activityJournals = LocalJournalState.activityJournals;
    
    // Reset sessions
    for (var a in _activities) {
      a['sessions'] = 0;
    }

    for (final journal in activityJournals) {
      final name = journal['activityName'];
      for (var a in _activities) {
        if (a['name'] == name) {
          a['sessions'] = (a['sessions'] as int) + 1;
        }
      }
    }
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
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Track your mindful journey',
                          style: TextStyle(
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
                                  onTap: () {
                                    if (_selectedPeriod != i) {
                                      setState(() => _selectedPeriod = i);
                                      _loadStats();
                                    }
                                  },
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedPeriod == 0 ? 'This week\'s emotional flow' : (_selectedPeriod == 1 ? 'This month\'s emotional flow' : 'This year\'s emotional flow'),
                                    style: const TextStyle(
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
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.textGrey,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${(item['pct'] * 100).toInt()}%',
                                                    style: const TextStyle(
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
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${activity['sessions']}/${activity['total']}',
                                                style: const TextStyle(
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
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
