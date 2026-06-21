import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/journal_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final JournalService _journalService = JournalService();
  bool _isLoading = true;

  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Happy', 'Sad', 'Calm', 'Anxious'];

  final List<Map<String, dynamic>> _entries = [];

  final List<Map<String, dynamic>> _defaultMockEntries = [
    {
      'date': 'Today, June 4',
      'time': '09:14 AM',
      'mood': '🙂',
      'moodColor': const Color(0xFF8FCC8F),
      'title': 'A Fresh Morning',
      'preview':
          'Woke up feeling lighter today. The morning sunlight felt different — warmer, like a gentle nudge to keep going...',
      'tag': 'Gratitude',
      'tagColor': const Color(0xFFD4E8D8),
      'tagTextColor': const Color(0xFF5A9E7A),
      'wordCount': '142 words',
    },
    {
      'date': 'Yesterday, June 3',
      'time': '10:30 PM',
      'mood': '😐',
      'moodColor': const Color(0xFFF5D77A),
      'title': 'Overthinking Again',
      'preview':
          'Had a meeting that didn\'t go as planned. Keep replaying it in my head. I need to remind myself...',
      'tag': 'Reflection',
      'tagColor': const Color(0xFFF5EAD8),
      'tagTextColor': const Color(0xFFB07040),
      'wordCount': '89 words',
    },
    {
      'date': 'June 2',
      'time': '07:55 AM',
      'mood': '😍',
      'moodColor': const Color(0xFF5AB8C0),
      'title': 'Yoga Changed Everything',
      'preview':
          'Did the morning flow for the first time in weeks. My body felt stiff at first but by the end...',
      'tag': 'Movement',
      'tagColor': const Color(0xFFD8EEF0),
      'tagTextColor': const Color(0xFF3A8A92),
      'wordCount': '215 words',
    },
    {
      'date': 'June 1',
      'time': '11:00 PM',
      'mood': '😕',
      'moodColor': const Color(0xFFE8834A),
      'title': 'Missing Home',
      'preview':
          'Called mom today. Hearing her voice made me realize how much I miss being around family...',
      'tag': 'Family',
      'tagColor': const Color(0xFFFAEAE0),
      'tagTextColor': const Color(0xFFB06040),
      'wordCount': '67 words',
    },
    {
      'date': 'May 31',
      'time': '08:20 AM',
      'mood': '🙂',
      'moodColor': const Color(0xFF8FCC8F),
      'title': 'Small Wins Matter',
      'preview':
          'Finished the report ahead of deadline. Treated myself to a good coffee. These little moments add up...',
      'tag': 'Productivity',
      'tagColor': const Color(0xFFE0E8F8),
      'tagTextColor': const Color(0xFF3A5A9E),
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
    _loadJournals();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadJournals() async {
    setState(() => _isLoading = true);
    final backendList = await _journalService.fetchJournals();
    
    final List<Map<String, dynamic>> parsedEntries = [];
    
    for (final item in backendList) {
      final moodStr = item['mood'] ?? 'Calm';
      final moodDetails = _getMoodDetails(moodStr);
      final tagStr = item['tag'] ?? 'Reflection';
      final tagColors = _getTagColors(tagStr);
      
      final content = item['content'] ?? '';
      final words = content.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
      final wordCount = '$words words';
      
      parsedEntries.add({
        'id': item['id'],
        'date': _formatDate(item['created_at']),
        'time': _formatTime(item['created_at']),
        'mood': moodDetails['emoji'],
        'moodColor': moodDetails['color'],
        'title': item['title'] ?? 'Untitled',
        'preview': content,
        'tag': tagStr,
        'tagColor': tagColors['bg'],
        'tagTextColor': tagColors['text'],
        'wordCount': wordCount,
      });
    }
    
    setState(() {
      _entries.clear();
      if (parsedEntries.isNotEmpty) {
        _entries.addAll(parsedEntries);
      } else {
        _entries.addAll(_defaultMockEntries);
      }
      _isLoading = false;
    });
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      
      if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
        return 'Today, ${_getMonthName(dateTime.month)} ${dateTime.day}';
      }
      
      final yesterday = now.subtract(const Duration(days: 1));
      if (dateTime.year == yesterday.year && dateTime.month == yesterday.month && dateTime.day == yesterday.day) {
        return 'Yesterday, ${_getMonthName(dateTime.month)} ${dateTime.day}';
      }
      
      return '${_getMonthName(dateTime.month)} ${dateTime.day}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'June', 'July', 'August', 'September', 'October', 'November',
      'December', 'January', 'February', 'March', 'April', 'May'
    ];
    // We adjust mapping, standard calendar month is 1-indexed
    const stdMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month < 1 || month > 12) return '';
    return stdMonths[month - 1];
  }

  String _formatTime(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
      final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minuteStr = dateTime.minute.toString().padLeft(2, '0');
      return '${hour.toString().padLeft(2, '0')}:$minuteStr $ampm';
    } catch (e) {
      return '';
    }
  }

  Map<String, dynamic> _getMoodDetails(String? mood) {
    switch (mood) {
      case 'Happy':
      case '😄':
      case '😍':
        return {
          'emoji': '😄',
          'color': const Color(0xFFF5D77A),
        };
      case 'Sad':
      case '😢':
      case '😕':
        return {
          'emoji': '😢',
          'color': const Color(0xFF5AB8C0),
        };
      case 'Calm':
      case '😌':
      case '🙂':
        return {
          'emoji': '😌',
          'color': const Color(0xFF8FCC8F),
        };
      case 'Anxious':
      case '😰':
      case '😐':
        return {
          'emoji': '😰',
          'color': const Color(0xFFE8834A),
        };
      default:
        return {
          'emoji': '😌',
          'color': const Color(0xFF8FCC8F),
        };
    }
  }

  Map<String, Color> _getTagColors(String? tag) {
    switch (tag) {
      case 'Gratitude':
        return {
          'bg': const Color(0xFFD4E8D8),
          'text': const Color(0xFF5A9E7A),
        };
      case 'Reflection':
        return {
          'bg': const Color(0xFFF5EAD8),
          'text': const Color(0xFFB07040),
        };
      case 'Movement':
        return {
          'bg': const Color(0xFFD8EEF0),
          'text': const Color(0xFF3A8A92),
        };
      case 'Family':
        return {
          'bg': const Color(0xFFFAEAE0),
          'text': const Color(0xFFB06040),
        };
      case 'Productivity':
        return {
          'bg': const Color(0xFFE0E8F8),
          'text': const Color(0xFF3A5A9E),
        };
      default:
        return {
          'bg': const Color(0xFFEFEFEF),
          'text': const Color(0xFF8A8A8A),
        };
    }
  }

  List<Map<String, dynamic>> get _filteredEntries {
    if (_selectedFilter == 0) return _entries;
    final filterName = _filters[_selectedFilter];
    return _entries.where((entry) {
      final entryMood = entry['mood'];
      if (filterName == 'Happy' && (entryMood == '😄' || entryMood == '😍')) return true;
      if (filterName == 'Sad' && (entryMood == '😢' || entryMood == '😕')) return true;
      if (filterName == 'Calm' && (entryMood == '😌' || entryMood == '🙂')) return true;
      if (filterName == 'Anxious' && (entryMood == '😰' || entryMood == '😐')) return true;
      return false;
    }).toList();
  }

  void _showAddJournalSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedMood = 'Calm';
    String selectedTag = 'Reflection';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tulis Jurnal Baru 📓',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Judul Jurnal',
                        hintStyle: const TextStyle(color: AppColors.textLight),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ceritakan harimu di sini...',
                        hintStyle: const TextStyle(color: AppColors.textLight),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bagaimana perasaanmu?',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['Happy', 'Sad', 'Calm', 'Anxious'].map((mood) {
                        final emojiMap = {
                          'Happy': '😄',
                          'Sad': '😢',
                          'Calm': '😌',
                          'Anxious': '😰',
                        };
                        final isSelected = selectedMood == mood;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedMood = mood),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.darkButton
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  emojiMap[mood]!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  mood,
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Kategori/Tag',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          'Gratitude',
                          'Reflection',
                          'Movement',
                          'Family',
                          'Productivity'
                        ].map((tag) {
                          final isSelected = selectedTag == tag;
                          return GestureDetector(
                            onTap: () => setSheetState(() => selectedTag = tag),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.darkButton
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textGrey,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final title = titleController.text.trim();
                                final content = contentController.text.trim();
                                if (title.isEmpty || content.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Judul dan isi jurnal wajib diisi.'),
                                    ),
                                  );
                                  return;
                                }

                                setSheetState(() => isSaving = true);
                                final result =
                                    await _journalService.createJournal(
                                  title: title,
                                  content: content,
                                  mood: selectedMood,
                                  tag: selectedTag,
                                );

                                if (result != null) {
                                  Navigator.pop(context);
                                  _loadJournals();
                                } else {
                                  setSheetState(() => isSaving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal menyimpan jurnal ke server.'),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkButton,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Simpan Jurnal',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: RefreshIndicator(
        onRefresh: _loadJournals,
        color: AppColors.sageDeep,
        child: FadeTransition(
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'My Journal 📓',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_entries.length} entries total',
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
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
                                      fontFamily: 'Fredoka',
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
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.sageDeep,
                          ),
                        )
                      : filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada jurnal yang sesuai filter.',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  color: AppColors.textGrey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _buildEntryCard(filtered[index], index);
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),

      // FAB - new entry
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddJournalSheet,
        backgroundColor: AppColors.darkButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 6,
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
                      fontFamily: 'Fredoka',
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
                fontFamily: 'Fredoka',
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
                fontFamily: 'Fredoka',
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
                      fontFamily: 'Fredoka',
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
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
                const Spacer(),
                Text(
                  entry['time'],
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
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
