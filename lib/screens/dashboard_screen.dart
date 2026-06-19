import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'package:peaceful_mind/screens/ai_chat_screen.dart';
import 'package:peaceful_mind/screens/mood_detection_screen.dart';
import 'package:peaceful_mind/screens/comfort_food_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMood = 3;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😠', 'label': 'Angry', 'color': Color(0xFFE85858)},
    {'emoji': '😕', 'label': 'Sad', 'color': Color(0xFFE8834A)},
    {'emoji': '😐', 'label': 'Neutral', 'color': Color(0xFFF5D77A)},
    {'emoji': '🙂', 'label': 'Good', 'color': Color(0xFF8FCC8F)},
    {'emoji': '😍', 'label': 'Great', 'color': Color(0xFF5AB8C0)},
  ];

  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Morning\nYoga Flow',
      'emoji': '🧘‍♀️',
      'color': Color(0xFFEDE0D8),
      'duration': '20 min',
    },
    {
      'title': 'Mind Clarity\nJournal',
      'emoji': '📓',
      'color': Color(0xFFE8D8E8),
      'duration': '15 min',
    },
    {
      'title': 'Deep Sleep\nMeditation',
      'emoji': '🌙',
      'color': Color(0xFFD8E8F0),
      'duration': '30 min',
    },
    {
      'title': 'Breathing\nExercise',
      'emoji': '💨',
      'color': Color(0xFFD8F0E8),
      'duration': '10 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String name = user?.displayName ?? 'Chloe Brooke';
    final String? photoUrl = user?.photoURL;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.backgroundGreen,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              color: AppColors.sageDark,
                              image: photoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(photoUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: photoUrl == null
                                ? const Center(
                                    child: Text('👩', style: TextStyle(fontSize: 26)),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    'Hi ',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                  Text('👋'),
                                ],
                              ),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text('🔔', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Greeting
                      const Text(
                        'Good morning,',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Welcome back,\nhow's your mind\ntoday?",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Search bar
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 14),
                            Icon(Icons.search_rounded,
                                color: AppColors.textLight, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Search...',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── White body ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F0),
                borderRadius:
                BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  // Daily Mood
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _sectionHeader('Daily mood', 'See all'),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_moods.length, (i) {
                        final isSelected = _selectedMood == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMood = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 58 : 52,
                            height: isSelected ? 58 : 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? (_moods[i]['color'] as Color)
                                  : (_moods[i]['color'] as Color)
                                  .withOpacity(0.55),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: (_moods[i]['color'] as Color)
                                      .withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                                  : null,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                _moods[i]['emoji'],
                                style: TextStyle(
                                    fontSize: isSelected ? 28 : 24),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Activities
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _sectionHeader('Activities', 'View all'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _activities.length,
                      itemBuilder: (_, i) =>
                          _buildActivityCard(_activities[i]),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Weekly Progress
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _sectionHeader('Weekly Progress', null),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProgressCard(),
                  ),

                  const SizedBox(height: 28),

                  // ── 3 Fitur Unggulan ───────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _sectionHeader('Fitur Unggulan', null),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildFeatureCard(
                          emoji: '🧠',
                          title: 'Chat Konsultasi AI',
                          subtitle: 'Ceritakan perasaanmu ke MindBot, konselor AI yang siap 24/7',
                          tag: 'RAG • Empatik',
                          color: const Color(0xFFD4E8D8),
                          accentColor: AppColors.sageDark,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AiChatScreen())),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          emoji: '📷',
                          title: 'Deteksi Mood via Kamera',
                          subtitle: 'AI baca ekspresi wajah & HRV-mu untuk kenali kondisi emosional',
                          tag: 'rPPG • Computer Vision',
                          color: const Color(0xFFD8EEF0),
                          accentColor: const Color(0xFF3A8A92),
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const MoodDetectionScreen())),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          emoji: '🍜',
                          title: 'Comfort Food UMKM',
                          subtitle: 'Rekomendasi makanan dari warung terdekat sesuai suasana hatimu',
                          tag: 'LBS • Jastip',
                          color: const Color(0xFFFAEADE),
                          accentColor: AppColors.accentOrange,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ComfortFoodScreen())),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Daily Quote
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildQuoteCard(),
                  ),

                  // Extra bottom space so content clears the nav bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  Widget _sectionHeader(String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        if (action != null)
          Text(
            action,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.sageDark,
            ),
          ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> act) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: act['color'],
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        act['title'],
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_outward_rounded,
                          size: 16, color: AppColors.textDark),
                    ),
                  ],
                ),
                const Spacer(),
                Text(act['emoji'],
                    style: const TextStyle(fontSize: 46)),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    act['duration'],
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
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

  Widget _buildProgressCard() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final progress = [0.8, 0.6, 1.0, 0.4, 0.7, 0.9, 0.3];
    const today = 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (i) {
              final isToday = i == today;
              final done = i < today;
              return Column(
                children: [
                  Container(
                    width: 34,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.backgroundGreen
                          : const Color(0xFFF5F5F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 34,
                        height: 60 * progress[i],
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.sageDark
                              : done
                              ? AppColors.sageMedium
                              : AppColors.sageMedium.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight:
                      isToday ? FontWeight.w800 : FontWeight.w600,
                      color: isToday
                          ? AppColors.sageDark
                          : AppColors.textLight,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGreen.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '5',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.sageDeep,
                        ),
                      ),
                      Text(
                        'Day streak 🔥',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '73%',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accentOrange,
                        ),
                      ),
                      Text(
                        'Weekly goal',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.darkButton,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ Daily Inspiration',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sageMedium,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '"Peace begins\nwith a smile."',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '— Mother Teresa',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.sageMedium.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('🕊️', style: TextStyle(fontSize: 28)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String tag,
    required Color color,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
