import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ComfortFoodScreen extends StatefulWidget {
  const ComfortFoodScreen({super.key});

  @override
  State<ComfortFoodScreen> createState() => _ComfortFoodScreenState();
}

class _ComfortFoodScreenState extends State<ComfortFoodScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _locationController;
  late Animation<double> _fadeAnimation;

  bool _locationGranted = false;
  bool _isLoadingLocation = false;
  int _selectedMood = 1; // default: lagi stres
  int _selectedCategory = 0;
  String? _selectedFood;

  final List<Map<String, dynamic>> _moodTriggers = [
    {'emoji': '😰', 'label': 'Cemas', 'color': Color(0xFFE8834A)},
    {'emoji': '😤', 'label': 'Stres', 'color': Color(0xFFE85858)},
    {'emoji': '😢', 'label': 'Sedih', 'color': Color(0xFF5AB8C0)},
    {'emoji': '😴', 'label': 'Capek', 'color': Color(0xFF8BBF9F)},
    {'emoji': '😐', 'label': 'Hampa', 'color': Color(0xFFF5D77A)},
  ];

  final List<String> _categories = ['Semua', 'Manis', 'Hangat', 'Gurih', 'Minuman'];

  final List<Map<String, dynamic>> _allFoods = [
    // Manis
    {
      'name': 'Martabak Manis',
      'emoji': '🥞',
      'category': 'Manis',
      'warung': 'Martabak Bang Haji',
      'distance': '0.3 km',
      'time': '~10 mnt',
      'price': 'Rp 25.000',
      'rating': '4.8',
      'mood': ['Sedih', 'Hampa', 'Stres'],
      'color': Color(0xFFFAF0D0),
      'desc': 'Manis, hangat, dan bikin hati senang!',
    },
    {
      'name': 'Es Krim Coklat',
      'emoji': '🍦',
      'category': 'Manis',
      'warung': 'Kedai Manis Ibu Sari',
      'distance': '0.5 km',
      'time': '~12 mnt',
      'price': 'Rp 15.000',
      'rating': '4.6',
      'mood': ['Sedih', 'Stres', 'Cemas'],
      'color': Color(0xFFFAEADE),
      'desc': 'Dingin dan manis, ampuh usir galau.',
    },
    {
      'name': 'Pisang Goreng Keju',
      'emoji': '🍌',
      'category': 'Manis',
      'warung': 'Gorengan Pak Marto',
      'distance': '0.2 km',
      'time': '~8 mnt',
      'price': 'Rp 12.000',
      'rating': '4.7',
      'mood': ['Capek', 'Hampa', 'Sedih'],
      'color': Color(0xFFFAF0D0),
      'desc': 'Renyah di luar, lembut di dalam.',
    },
    // Hangat
    {
      'name': 'Mie Ayam Bakso',
      'emoji': '🍜',
      'category': 'Hangat',
      'warung': 'Mie Pak Budi',
      'distance': '0.4 km',
      'time': '~15 mnt',
      'price': 'Rp 18.000',
      'rating': '4.9',
      'mood': ['Capek', 'Stres', 'Cemas'],
      'color': Color(0xFFD8EEF0),
      'desc': 'Kuah gurih, bikin perut dan hati hangat.',
    },
    {
      'name': 'Soto Ayam',
      'emoji': '🥣',
      'category': 'Hangat',
      'warung': 'Soto Bu Endang',
      'distance': '0.6 km',
      'time': '~18 mnt',
      'price': 'Rp 15.000',
      'rating': '4.8',
      'mood': ['Capek', 'Sedih', 'Hampa'],
      'color': Color(0xFFD4E8D8),
      'desc': 'Segar dan hangat, kayak pelukan dari rumah.',
    },
    {
      'name': 'Indomie Telur',
      'emoji': '🍳',
      'category': 'Hangat',
      'warung': 'Warung Kopi Mas Eko',
      'distance': '0.1 km',
      'time': '~5 mnt',
      'price': 'Rp 10.000',
      'rating': '4.5',
      'mood': ['Stres', 'Capek', 'Hampa'],
      'color': Color(0xFFFAEADE),
      'desc': 'Klasik anak kos sejati, solusi segala galau.',
    },
    // Gurih
    {
      'name': 'Nasi Goreng Kampung',
      'emoji': '🍳',
      'category': 'Gurih',
      'warung': 'Nasi Goreng Pak Rahmat',
      'distance': '0.3 km',
      'time': '~12 mnt',
      'price': 'Rp 14.000',
      'rating': '4.7',
      'mood': ['Cemas', 'Stres', 'Hampa'],
      'color': Color(0xFFEDE0D8),
      'desc': 'Aroma wangi yang langsung bikin lapar hilang.',
    },
    {
      'name': 'Ayam Geprek',
      'emoji': '🍗',
      'category': 'Gurih',
      'warung': 'Geprek Juara Pak Joko',
      'distance': '0.5 km',
      'time': '~15 mnt',
      'price': 'Rp 20.000',
      'rating': '4.9',
      'mood': ['Frustasi', 'Stres', 'Cemas'],
      'color': Color(0xFFFAEADE),
      'desc': 'Pedenya bisa ikut "menggepreki" stresmu!',
    },
    {
      'name': 'Gorengan Mix',
      'emoji': '🧆',
      'category': 'Gurih',
      'warung': 'Gorengan Ibu Yati',
      'distance': '0.1 km',
      'time': '~5 mnt',
      'price': 'Rp 8.000',
      'rating': '4.6',
      'mood': ['Capek', 'Hampa', 'Sedih'],
      'color': Color(0xFFD4E8D8),
      'desc': 'Murah meriah, ampuh usir kejenuhan.',
    },
    // Minuman
    {
      'name': 'Es Teh Manis',
      'emoji': '🧋',
      'category': 'Minuman',
      'warung': 'Warung Kopi Mas Eko',
      'distance': '0.1 km',
      'time': '~5 mnt',
      'price': 'Rp 5.000',
      'rating': '4.5',
      'mood': ['Capek', 'Stres', 'Hampa'],
      'color': Color(0xFFD4E8D8),
      'desc': 'Manis dan menyegarkan, teman setia anak kos.',
    },
    {
      'name': 'Wedang Jahe',
      'emoji': '☕',
      'category': 'Minuman',
      'warung': 'Angkringan Pak Slamet',
      'distance': '0.4 km',
      'time': '~10 mnt',
      'price': 'Rp 7.000',
      'rating': '4.8',
      'mood': ['Capek', 'Sedih', 'Cemas'],
      'color': Color(0xFFEDE0D8),
      'desc': 'Hangat dari dalam, bikin pikiran lebih tenang.',
    },
    {
      'name': 'Boba Brown Sugar',
      'emoji': '🧋',
      'category': 'Minuman',
      'warung': 'Boba Station',
      'distance': '0.7 km',
      'time': '~20 mnt',
      'price': 'Rp 22.000',
      'rating': '4.7',
      'mood': ['Sedih', 'Stres', 'Hampa'],
      'color': Color(0xFFFAEADE),
      'desc': 'Treat yourself! Kamu layak mendapatkannya.',
    },
  ];

  List<Map<String, dynamic>> get _filteredFoods {
    final moodLabel = _moodTriggers[_selectedMood]['label'];
    final category = _categories[_selectedCategory];
    return _allFoods.where((f) {
      final moodMatch =
      (f['mood'] as List).contains(moodLabel);
      final catMatch = category == 'Semua' || f['category'] == category;
      return moodMatch && catMatch;
    }).toList();
  }

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

    _locationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _requestLocation() async {
    setState(() => _isLoadingLocation = true);
    _locationController.repeat();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    _locationController.stop();
    setState(() {
      _isLoadingLocation = false;
      _locationGranted = true;
    });
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
                                  'Comfort Food 🍜',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'UMKM terdekat dari kosmu',
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.darkButton,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 11, color: AppColors.accentOrange),
                                SizedBox(width: 4),
                                Text(
                                  'LBS',
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

                      const SizedBox(height: 16),

                      // Mood trigger selector
                      const Text(
                        'Kamu lagi ngerasa...',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_moodTriggers.length, (i) {
                          final isSelected = _selectedMood == i;
                          final mood = _moodTriggers[i];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedMood = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (mood['color'] as Color)
                                    .withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(14),
                                border: isSelected
                                    ? Border.all(
                                  color: mood['color'] as Color,
                                  width: 2,
                                )
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Text(mood['emoji'],
                                      style: const TextStyle(fontSize: 22)),
                                  const SizedBox(height: 3),
                                  Text(
                                    mood['label'],
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? mood['color'] as Color
                                          : AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
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
                child: Column(
                  children: [
                    // Location banner / category filter
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: [
                          // Location bar
                          _locationGranted
                              ? _buildLocationBar()
                              : _buildLocationRequest(),

                          const SizedBox(height: 14),

                          // Category chips
                          SizedBox(
                            height: 36,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              itemBuilder: (context, i) {
                                final isSelected = _selectedCategory == i;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedCategory = i),
                                  child: AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.darkButton
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _categories[i],
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

                    const SizedBox(height: 16),

                    // Food list
                    Expanded(
                      child: _filteredFoods.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            20, 0, 20, 100),
                        itemCount: _filteredFoods.length,
                        itemBuilder: (context, i) =>
                            _buildFoodCard(_filteredFoods[i]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRequest() {
    return GestureDetector(
      onTap: _isLoadingLocation ? null : _requestLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accentOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accentOrange.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _locationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _isLoadingLocation
                      ? _locationController.value * 2 * 3.14159
                      : 0,
                  child: const Icon(
                    Icons.location_searching_rounded,
                    color: AppColors.accentOrange,
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isLoadingLocation
                    ? 'Mencari lokasi kosmu...'
                    : 'Aktifkan lokasi untuk temukan UMKM terdekat',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
            if (!_isLoadingLocation)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Aktifkan',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              color: AppColors.sageDeep, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Jl. Manyar Kertoarjo V, Surabaya',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.sageDeep,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '📍 Aktif',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    final isSelected = _selectedFood == food['name'];
    return GestureDetector(
      onTap: () => setState(
              () => _selectedFood = isSelected ? null : food['name'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: isSelected
              ? Border.all(color: AppColors.sageDark, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Food emoji in colored box
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: food['color'] as Color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(food['emoji'],
                          style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food['name'],
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          food['warung'],
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          food['desc'],
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Info row
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: (food['color'] as Color).withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
              child: Row(
                children: [
                  _buildInfoChip(
                      Icons.location_on_rounded, food['distance'],
                      AppColors.sageDeep),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                      Icons.access_time_rounded, food['time'],
                      AppColors.accentOrange),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                      Icons.star_rounded, food['rating'],
                      const Color(0xFFE8C84A)),
                  const Spacer(),
                  Text(
                    food['price'],
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // Expanded order section
            if (isSelected) _buildOrderSection(food),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection(Map<String, dynamic> food) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF0F0F0), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showOrderDialog(food, 'Jastip'),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🛵', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Jastip',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.sageDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showOrderDialog(food, 'Gojek'),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00AA13).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🟢', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'GoFood',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00AA13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showOrderDialog(food, 'Grab'),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B14F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🟩', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'GrabFood',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00B14F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDialog(Map<String, dynamic> food, String method) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderBottomSheet(food: food, method: method),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'Belum ada rekomendasi\nuntuk mood & kategori ini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _selectedCategory = 0),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.backgroundGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.sageDeep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order Bottom Sheet ─────────────────────────────────────────────
class _OrderBottomSheet extends StatelessWidget {
  final Map<String, dynamic> food;
  final String method;

  const _OrderBottomSheet({required this.food, required this.method});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),

          // Food info
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: food['color'] as Color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(food['emoji'],
                      style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food['name'],
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      food['warung'],
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                food['price'],
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Map placeholder
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.backgroundGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                // Fake map grid
                CustomPaint(
                  size: const Size(double.infinity, 130),
                  painter: _FakeMapPainter(),
                ),
                // Markers
                const Positioned(
                  left: 60,
                  top: 40,
                  child: _MapMarker(emoji: '🏪', label: 'Warung',
                      color: Color(0xFF5A9E7A)),
                ),
                const Positioned(
                  right: 80,
                  top: 55,
                  child: _MapMarker(emoji: '🏠', label: 'Kosmu',
                      color: Color(0xFF5AB8C0)),
                ),
                // ETA
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: AppColors.accentOrange),
                          const SizedBox(width: 4),
                          Text(
                            'Tiba dalam ${food['time']}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Delivery info row
          Row(
            children: [
              _buildDetailChip(Icons.directions_bike_rounded,
                  food['distance'], AppColors.sageDeep),
              const SizedBox(width: 8),
              _buildDetailChip(
                  Icons.access_time_rounded, food['time'], AppColors.accentOrange),
              const SizedBox(width: 8),
              _buildDetailChip(Icons.store_rounded, 'UMKM Lokal',
                  AppColors.sageDark),
            ],
          ),

          const SizedBox(height: 20),

          // Order button
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Membuka $method untuk pesan ${food['name']}... 🛵',
                    style: const TextStyle(fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: AppColors.darkButton,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.darkButton,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  'Pesan via $method  →',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  const _MapMarker(
      {required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1), blurRadius: 6),
            ],
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 17))),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _FakeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB5D5C5).withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Horizontal grid lines
    for (int i = 1; i < 5; i++) {
      final y = size.height / 5 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical grid lines
    for (int i = 1; i < 7; i++) {
      final x = size.width / 7 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Fake road
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(50, 100)
      ..quadraticBezierTo(size.width / 2, 60, size.width - 90, 80);
    canvas.drawPath(path, roadPaint);

    // Dotted route
    final dotPaint = Paint()
      ..color = AppColors.accentOrange.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const dashWidth = 8.0;
    const dashSpace = 5.0;
    double startX = 96;
    while (startX < size.width - 100) {
      canvas.drawLine(
        Offset(startX, 80),
        Offset(startX + dashWidth, 79),
        dotPaint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
