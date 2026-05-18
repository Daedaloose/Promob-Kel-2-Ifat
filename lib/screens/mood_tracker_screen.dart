import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  int _selectedMoodIndex = 2;
  bool _logged = false;
  final TextEditingController _noteCtrl = TextEditingController();

  final List<_MoodOption> _moods = [
    _MoodOption(
      emoji: '😔',
      label: 'Sangat\nBuruk',
      color: const Color(0xFF8B0000),
      orbMood: 'glitchy',
    ),
    _MoodOption(
      emoji: '😟',
      label: 'Buruk',
      color: AppTheme.accentPink,
      orbMood: 'stressed',
    ),
    _MoodOption(
      emoji: '😐',
      label: 'Biasa',
      color: AppTheme.accent,
      orbMood: 'calm',
    ),
    _MoodOption(
      emoji: '🙂',
      label: 'Baik',
      color: AppTheme.accentCyan,
      orbMood: 'calm',
    ),
    _MoodOption(
      emoji: '😄',
      label: 'Luar\nBiasa',
      color: AppTheme.accentGreen,
      orbMood: 'happy',
    ),
  ];

  // Simulated weekly log
  final List<_WeeklyEntry> _weekEntries = [
    _WeeklyEntry(day: 'Sen', moodIndex: 3, color: AppTheme.accentCyan),
    _WeeklyEntry(day: 'Sel', moodIndex: 2, color: AppTheme.accent),
    _WeeklyEntry(day: 'Rab', moodIndex: 1, color: AppTheme.accentPink),
    _WeeklyEntry(day: 'Kam', moodIndex: 3, color: AppTheme.accentCyan),
    _WeeklyEntry(day: 'Jum', moodIndex: 4, color: AppTheme.accentGreen),
    _WeeklyEntry(day: 'Sab', moodIndex: 2, color: AppTheme.accent),
    _WeeklyEntry(day: 'Min', moodIndex: -1, color: AppTheme.textMuted),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMood = _moods[_selectedMoodIndex];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),
                      _buildAvatarSection(selectedMood),
                      const SizedBox(height: 28),
                      _buildMoodSelector(),
                      const SizedBox(height: 24),
                      _buildEmotionTags(),
                      const SizedBox(height: 24),
                      _buildNoteInput(),
                      const SizedBox(height: 24),
                      _buildLogButton(selectedMood),
                      const SizedBox(height: 28),
                      _buildWeeklyView(),
                      const SizedBox(height: 28),
                      _buildInsightSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              Text('Mood Tracker', style: AppTheme.titleLarge),
              Text('Sabtu, 3 Mei 2026', style: AppTheme.bodySmall),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.pinkGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '7 Hari',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(_MoodOption mood) {
    return Center(
      child: Column(
        children: [
          Text(
            'Bagaimana perasaanmu sekarang?',
            style: AppTheme.displayMedium.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Animated orb with aura
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow ring
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      mood.color.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              GlowingOrb(mood: mood.orbMood, size: 150),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              mood.label.replaceAll('\n', ' '),
              key: ValueKey(mood.label),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: mood.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilih Mood', style: AppTheme.titleMedium),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_moods.length, (i) {
            final mood = _moods[i];
            final isSelected = _selectedMoodIndex == i;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedMoodIndex = i;
                _logged = false;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 58,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isSelected
                      ? mood.color.withOpacity(0.15)
                      : AppTheme.surfaceLight,
                  border: Border.all(
                    color: isSelected ? mood.color : AppTheme.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(
                      mood.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? mood.color : AppTheme.textMuted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmotionTags() {
    final tags = [
      'Lelah 😩', 'Stres 😤', 'Cemas 😰', 'Fokus 🎯',
      'Bahagia 😊', 'Bersemangat ⚡', 'Sedih 😢', 'Tenang 🧘',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Apa yang kamu rasakan?', style: AppTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return _TagChip(label: tag);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Catatan (opsional)', style: AppTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: TextField(
            controller: _noteCtrl,
            maxLines: 3,
            style: GoogleFonts.inter(
                fontSize: 14, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ceritakan perasaanmu hari ini...',
              hintStyle: AppTheme.bodySmall,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogButton(_MoodOption mood) {
    return GestureDetector(
      onTap: () => setState(() => _logged = true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _logged
              ? AppTheme.greenGradient
              : LinearGradient(
                  colors: [mood.color, mood.color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: mood.color.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _logged ? Icons.check_circle_rounded : Icons.save_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              _logged ? 'Mood Tercatat!' : 'Catat Mood Sekarang',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Grafik Minggu Ini', style: AppTheme.titleMedium),
        const SizedBox(height: 14),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _weekEntries.map((entry) {
              final hasEntry = entry.moodIndex >= 0;
              final barH = hasEntry ? 20.0 + (entry.moodIndex * 20) : 8.0;
              return Column(
                children: [
                  if (hasEntry)
                    Text(
                      _moods[entry.moodIndex].emoji,
                      style: const TextStyle(fontSize: 16),
                    )
                  else
                    const SizedBox(height: 20),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    width: 28,
                    height: barH,
                    decoration: BoxDecoration(
                      color: hasEntry
                          ? entry.color.withOpacity(0.8)
                          : AppTheme.textMuted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: hasEntry
                          ? [
                              BoxShadow(
                                color: entry.color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.day,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Insight Mingguan', style: AppTheme.titleMedium),
        const SizedBox(height: 14),
        GlassCard(
          borderColor: AppTheme.accentPink.withOpacity(0.2),
          child: Column(
            children: [
              _InsightRow(
                icon: '📈',
                text: 'Mood terbaikmu di hari Jumat',
                color: AppTheme.accentGreen,
              ),
              const SizedBox(height: 12),
              _InsightRow(
                icon: '⚠️',
                text: 'Stres cukup tinggi di tengah minggu',
                color: AppTheme.accentPink,
              ),
              const SizedBox(height: 12),
              _InsightRow(
                icon: '💡',
                text: 'Coba lakukan meditasi 5 menit sebelum tidur',
                color: AppTheme.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoodOption {
  final String emoji;
  final String label;
  final Color color;
  final String orbMood;
  _MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.orbMood,
  });
}

class _WeeklyEntry {
  final String day;
  final int moodIndex;
  final Color color;
  _WeeklyEntry({required this.day, required this.moodIndex, required this.color});
}

class _TagChip extends StatefulWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  State<_TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<_TagChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: _selected ? AppTheme.primaryGradient : null,
          color: _selected ? null : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selected ? AppTheme.accent : AppTheme.borderColor,
          ),
        ),
        child: Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: _selected ? FontWeight.w600 : FontWeight.w400,
            color: _selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String icon;
  final String text;
  final Color color;
  const _InsightRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
        Container(
          width: 4,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
