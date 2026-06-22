import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/local_journal_state.dart';
import '../widgets/mochi_face.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGreen,
        elevation: 0,
        title: const Text(
          'My Journal 📓',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.sageDeep,
          labelColor: AppColors.sageDeep,
          unselectedLabelColor: AppColors.textGrey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          tabs: const [
            Tab(text: 'Jurnal Mood'),
            Tab(text: 'Jurnal Aktivitas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoodTab(),
          _buildActivityTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddMoodSheet();
          } else {
            _showAddActivitySheet();
          }
        },
        backgroundColor: AppColors.sageDark,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  // --- TAB: MOOD JOURNALS ---
  Widget _buildMoodTab() {
    if (LocalJournalState.moodJournals.isEmpty) {
      return const Center(
        child: Text('Belum ada jurnal mood. Yuk tulis sekarang!', style: TextStyle(color: AppColors.textGrey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: LocalJournalState.moodJournals.length,
      itemBuilder: (context, index) {
        final entry = LocalJournalState.moodJournals[index];
        final List<String> images = entry['images'] ?? [];
        return GestureDetector(
          onTap: () {
            _showJournalDetail(entry);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: entry['moodColor'],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: MiniMochiFace(mood: entry['mood'], baseColor: entry['moodColor'], size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry['title'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${entry['date']} • ${entry['time']}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                entry['preview'],
                style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.5),
              ),
              if (images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, i) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(File(images[i])),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: entry['tagColor'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry['tag'],
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: entry['tagTextColor']),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    entry['wordCount'],
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight),
                  ),
                ],
              ),
            ],
          ),
        ));
      },
    );
  }

  // --- TAB: ACTIVITY JOURNALS ---
  Widget _buildActivityTab() {
    if (LocalJournalState.activityJournals.isEmpty) {
      return const Center(
        child: Text('Belum ada log aktivitas. Yuk mulai bergerak!', style: TextStyle(color: AppColors.textGrey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: LocalJournalState.activityJournals.length,
      itemBuilder: (context, index) {
        final entry = LocalJournalState.activityJournals[index];
        return GestureDetector(
          onTap: () {
            _showActivityDetail(entry);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: entry['color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(entry['emoji'], style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['activityName'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry['date']} • ${entry['time']}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    entry['duration'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.sageDeep),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry['intensity'],
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.sageDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
      },
    );
  }

  void _showJournalDetail(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) {
        final List<String> images = entry['images'] ?? [];
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: const Color(0xFFF5F5F0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: entry['moodColor'], borderRadius: BorderRadius.circular(16)),
                      child: Center(child: MiniMochiFace(mood: entry['mood'], baseColor: entry['moodColor'], size: 32)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          Text('${entry['date']} • ${entry['time']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(entry['preview'], style: const TextStyle(fontSize: 15, color: AppColors.textDark, height: 1.6)),
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Lampiran Foto:', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: images.map((path) => Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
                      ),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.sageDeep)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showActivityDetail(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: const Color(0xFFF5F5F0),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: entry['color'], borderRadius: BorderRadius.circular(24)),
                  child: Center(child: Text(entry['emoji'] ?? '✨', style: const TextStyle(fontSize: 40))),
                ),
                const SizedBox(height: 20),
                Text(entry['activityName'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text('${entry['date']} • ${entry['time']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textLight)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActivityStatBox('Durasi', entry['duration'], Icons.timer),
                    _buildActivityStatBox('Intensitas', entry['intensity'], Icons.local_fire_department),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.sageDeep)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityStatBox(String title, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sageMedium.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.sageDeep, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  // --- ADD MOOD JOURNAL SHEET ---
  void _showAddMoodSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedMood = 'Bahagia';
    String selectedTag = 'Reflection';
    List<String> selectedImages = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F0),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  const Text('Tulis Jurnal Mood 📓', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'Judul Jurnal',
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: contentController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Ceritakan harimu di sini...',
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Bagaimana perasaanmu?', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Bahagia', 'Tenang', 'Cemas', 'Sedih', 'Lelah'].map((mood) {
                            final isSelected = selectedMood == mood;
                            Color mColor = const Color(0xFF8FCC8F);
                            if (mood == 'Cemas') mColor = const Color(0xFFF5D77A);
                            if (mood == 'Sedih') mColor = const Color(0xFF5AB8C0);
                            if (mood == 'Lelah') mColor = const Color(0xFFE8834A);
                            return ChoiceChip(
                              avatar: CircleAvatar(
                                backgroundColor: mColor,
                                child: MiniMochiFace(mood: mood, baseColor: mColor, size: 20),
                              ),
                              label: Text(mood),
                              selected: isSelected,
                              selectedColor: AppColors.sageDeep,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w700),
                              onSelected: (val) => setSheetState(() => selectedMood = mood),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text('Pilih Kategori/Tag', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            {'name': 'Gratitude', 'emoji': '🙏'},
                            {'name': 'Reflection', 'emoji': '📓'},
                            {'name': 'Movement', 'emoji': '🏃‍♀️'},
                            {'name': 'Family', 'emoji': '👨‍👩‍👧‍👦'},
                            {'name': 'Productivity', 'emoji': '⚡'},
                          ].map((tag) {
                            final isSelected = selectedTag == tag['name'];
                            return ChoiceChip(
                              avatar: Text(tag['emoji']!, style: const TextStyle(fontSize: 16)),
                              label: Text(tag['name']!),
                              selected: isSelected,
                              selectedColor: AppColors.sageDeep,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w700),
                              onSelected: (val) => setSheetState(() => selectedTag = tag['name']!),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Lampirkan Foto (Maks 4)', style: TextStyle(fontWeight: FontWeight.w800)),
                            IconButton(
                              icon: const Icon(Icons.add_a_photo_rounded, color: AppColors.sageDeep),
                              onPressed: () async {
                                if (selectedImages.length >= 4) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimal 4 gambar!')));
                                  return;
                                }
                                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  setSheetState(() => selectedImages.add(image.path));
                                }
                              },
                            )
                          ],
                        ),
                        if (selectedImages.isNotEmpty)
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: selectedImages.length,
                              itemBuilder: (context, i) {
                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8, top: 8),
                                      width: 70, height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(image: FileImage(File(selectedImages[i])), fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0, top: 0,
                                      child: GestureDetector(
                                        onTap: () => setSheetState(() => selectedImages.removeAt(i)),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkButton, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        if (titleController.text.isEmpty || contentController.text.isEmpty) return;
                        final now = DateTime.now();
                        await LocalJournalState.addMood({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'date': 'Hari ini',
                          'time': '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}',
                          'mood': selectedMood,
                          'moodColor': selectedMood == 'Bahagia' ? const Color(0xFF8FCC8F) : const Color(0xFFF5D77A),
                          'title': titleController.text,
                          'preview': contentController.text,
                          'tag': selectedTag,
                          'tagColor': const Color(0xFFD4E8D8),
                          'tagTextColor': const Color(0xFF5A9E7A),
                          'wordCount': '${contentController.text.split(' ').length} kata',
                          'images': List<String>.from(selectedImages),
                        });
                        Navigator.pop(context);
                        _refresh();
                      },
                      child: const Text('Simpan Jurnal', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- ADD ACTIVITY JOURNAL SHEET ---
  void _showAddActivitySheet() {
    String selectedActivity = 'Morning Yoga';
    String selectedDuration = '15 menit';
    String selectedIntensity = 'Sedang';

    final activities = [
      {'name': 'Morning Yoga', 'emoji': '🧘‍♀️', 'color': const Color(0xFFEDE0D8)},
      {'name': 'Journaling', 'emoji': '📓', 'color': const Color(0xFFE8D8E8)},
      {'name': 'Meditation', 'emoji': '🧠', 'color': const Color(0xFFD8E8F0)},
      {'name': 'Breathing', 'emoji': '💨', 'color': const Color(0xFFD8F0E8)},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F0),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  const Text('Log Aktivitas 🏃‍♀️', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  const SizedBox(height: 24),
                  
                  const Text('Pilih Aktivitas', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: activities.map((act) {
                      final isSelected = selectedActivity == act['name'];
                      // Using MiniMochiFace to simulate custom illustrations for activities
                      String actMood = 'Tenang';
                      if (act['name'] == 'Journaling') actMood = 'Lelah'; // sleepy eyes
                      if (act['name'] == 'Breathing') actMood = 'Bahagia'; // happy eyes
                      if (act['name'] == 'Meditation') actMood = 'Sedih'; // closed eyes
                      
                      return ChoiceChip(
                        avatar: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: MiniMochiFace(mood: actMood, baseColor: act['color'] as Color, size: 24),
                        ),
                        label: Text('${act['name']}'),
                        selected: isSelected,
                        selectedColor: act['color'] as Color,
                        labelStyle: TextStyle(color: AppColors.textDark, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600),
                        onSelected: (val) => setSheetState(() => selectedActivity = act['name'] as String),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  const Text('Durasi', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['5 menit', '10 menit', '15 menit', '30 menit', '1 jam'].map((dur) {
                      final isSelected = selectedDuration == dur;
                      return ChoiceChip(
                        label: Text(dur),
                        selected: isSelected,
                        selectedColor: AppColors.sageDeep,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w700),
                        onSelected: (val) => setSheetState(() => selectedDuration = dur),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  const Text('Intensitas', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Rendah', 'Sedang', 'Tinggi'].map((intense) {
                      final isSelected = selectedIntensity == intense;
                      return ChoiceChip(
                        label: Text(intense),
                        selected: isSelected,
                        selectedColor: AppColors.sageDeep,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w700),
                        onSelected: (val) => setSheetState(() => selectedIntensity = intense),
                      );
                    }).toList(),
                  ),

                  const Spacer(),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkButton, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        final now = DateTime.now();
                        await LocalJournalState.addActivity({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'date': 'Hari ini',
                          'time': '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}',
                          'activityName': selectedActivity,
                          'emoji': activities.firstWhere((a) => a['name'] == selectedActivity)['emoji'],
                          'duration': selectedDuration,
                          'intensity': selectedIntensity,
                          'color': activities.firstWhere((a) => a['name'] == selectedActivity)['color'],
                        });
                        Navigator.pop(context);
                        _refresh();
                      },
                      child: const Text('Simpan Aktivitas', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
