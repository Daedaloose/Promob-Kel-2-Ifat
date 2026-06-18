import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Happy', 'Sad', 'Calm', 'Anxious'];

  final List<Map<String, dynamic>> _entries = [
    {
      'date': 'Today, June 4',
      'time': '09:14 AM',
      'mood': '🙂',
      'moodColor': Color(0xFF8FCC8F),
      'title': 'A Fresh Morning',
      'preview':
          'Woke up feeling lighter today. The morning sunlight felt different — warmer, like a gentle nudge to keep going...',
      'tag': 'Gratitude',
      'tagColor': Color(0xFFD4E8D8),
      'tagTextColor': Color(0xFF5A9E7A),
      'wordCount': '142 words',
    },
    {
      'date': 'Yesterday, June 3',
      'time': '10:30 PM',
      'mood': '😐',
      'moodColor': Color(0xFFF5D77A),
      'title': 'Overthinking Again',
      'preview':
          'Had a meeting that didn\'t go as planned. Keep replaying it in my head. I need to remind myself...',
      'tag': 'Reflection',
      'tagColor': Color(0xFFF5EAD8),
      'tagTextColor': Color(0xFFB07040),
      'wordCount': '89 words',
    },
    {
      'date': 'June 2',
      'time': '07:55 AM',
      'mood': '😍',
      'moodColor': Color(0xFF5AB8C0),
      'title': 'Yoga Changed Everything',
      'preview':
          'Did the morning flow for the first time in weeks. My body felt stiff at first but by the end...',
      'tag': 'Movement',
      'tagColor': Color(0xFFD8EEF0),
      'tagTextColor': Color(0xFF3A8A92),
      'wordCount': '215 words',
    },
    {
      'date': 'June 1',
      'time': '11:00 PM',
      'mood': '😕',
      'moodColor': Color(0xFFE8834A),
      'title': 'Missing Home',
      'preview':
          'Called mom today. Hearing her voice made me realize how much I miss being around family...',
      'tag': 'Family',
      'tagColor': Color(0xFFFAEAE0),
      'tagTextColor': Color(0xFFB06040),
      'wordCount': '67 words',
    },
    {
      'date': 'May 31',
      'time': '08:20 AM',
      'mood': '🙂',
      'moodColor': Color(0xFF8FCC8F),
      'title': 'Small Wins Matter',
      'preview':
          'Finished the report ahead of deadline. Treated myself to a good coffee. These little moments add up...',
      'tag': 'Productivity',
      'tagColor': Color(0xFFE0E8F8),
      'tagTextColor': Color(0xFF3A5A9E),
      'wordCount': '103 words',
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Journal 📓',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '5 entries this week',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Search icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: AppColors.textDark,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Filter chips
                      SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedFilter == index;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedFilter = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.darkButton
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _filters[index],
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textGrey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Entries list
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    return _buildEntryCard(_entries[index], index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // FAB - new entry
      floatingActionButton: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.darkButton,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: date + mood
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry['date'],
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: (entry['moodColor'] as Color).withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      entry['mood'],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              entry['title'],
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            // Preview text
            Text(
              entry['preview'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Bottom: tag + time + word count
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: entry['tagColor'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry['tag'],
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: entry['tagTextColor'],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry['wordCount'],
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
                const Spacer(),
                Text(
                  entry['time'],
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
