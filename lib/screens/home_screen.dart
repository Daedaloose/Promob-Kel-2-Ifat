import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'package:peaceful_mind/screens/dashboard_screen.dart';
import 'package:peaceful_mind/screens/journal_screen.dart';
import 'package:peaceful_mind/screens/stats_screen.dart';
import 'package:peaceful_mind/screens/settings_screen.dart';
import 'package:peaceful_mind/services/local_journal_state.dart';
import 'package:peaceful_mind/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    JournalScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    NotificationService.requestPermission();
  }

  Future<void> _loadUserData() async {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'default';
    await LocalJournalState.loadData(email);
    if (mounted) setState(() {});
  }

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.article_outlined, label: 'Journal'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Stats'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F0),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : AppColors.darkButton,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.black.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navItems.length, (index) {
              final isSelected = _currentIndex == index;
              final item = _navItems[index];
              return GestureDetector(
                onTap: () => _onNavTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.backgroundGreen.withOpacity(0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          item.icon,
                          color: isSelected
                              ? (isDark ? AppColors.sageLight : AppColors.sageMedium)
                              : (isDark ? Colors.white54 : Colors.white38),
                          size: isSelected ? 26 : 24,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? AppColors.sageLight : AppColors.sageMedium)
                              : (isDark ? Colors.white54 : Colors.white38),
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
