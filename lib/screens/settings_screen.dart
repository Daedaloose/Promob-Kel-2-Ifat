import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _notifDaily = true;
  bool _notifMood = true;
  bool _notifStreak = false;
  bool _darkMode = false;
  bool _soundEnabled = true;

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
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.backgroundGreen,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                    child: Column(
                      children: [
                        // Profile card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Stack(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      color: AppColors.sageDark,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '👩',
                                        style: TextStyle(fontSize: 32),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: AppColors.darkButton,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Chloe Brooke',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'chloe.brooke@email.com',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.sageDark,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        '✨ Premium Member',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textGrey,
                                size: 22,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Quick stats row
                        Row(
                          children: [
                            _buildQuickStat('14', 'Day\nStreak', '🔥'),
                            const SizedBox(width: 10),
                            _buildQuickStat('28', 'Sessions', '🧘‍♀️'),
                            const SizedBox(width: 10),
                            _buildQuickStat('5', 'Journals', '📓'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Settings content
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notifications section
                      _buildSectionTitle('Notifications'),
                      const SizedBox(height: 10),
                      _buildSettingsCard([
                        _buildToggleItem(
                          icon: Icons.notifications_outlined,
                          iconColor: AppColors.sageDark,
                          iconBg: AppColors.backgroundGreen,
                          title: 'Daily Reminder',
                          subtitle: 'Get notified at 9:00 AM',
                          value: _notifDaily,
                          onChanged: (v) => setState(() => _notifDaily = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.mood_outlined,
                          iconColor: const Color(0xFF5AB8C0),
                          iconBg: const Color(0xFFD8EEF0),
                          title: 'Mood Check-in',
                          subtitle: 'Remind me to log my mood',
                          value: _notifMood,
                          onChanged: (v) => setState(() => _notifMood = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.local_fire_department_outlined,
                          iconColor: const Color(0xFFE8834A),
                          iconBg: const Color(0xFFFAEADE),
                          title: 'Streak Alert',
                          subtitle: 'Don\'t break your streak!',
                          value: _notifStreak,
                          onChanged: (v) => setState(() => _notifStreak = v),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // Preferences section
                      _buildSectionTitle('Preferences'),
                      const SizedBox(height: 10),
                      _buildSettingsCard([
                        _buildToggleItem(
                          icon: Icons.dark_mode_outlined,
                          iconColor: const Color(0xFF5A3060),
                          iconBg: const Color(0xFFEAD8F0),
                          title: 'Dark Mode',
                          subtitle: 'Switch to dark theme',
                          value: _darkMode,
                          onChanged: (v) => setState(() => _darkMode = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.volume_up_outlined,
                          iconColor: AppColors.accentOrange,
                          iconBg: const Color(0xFFFAEADE),
                          title: 'Sound & Haptics',
                          subtitle: 'Enable app sounds',
                          value: _soundEnabled,
                          onChanged: (v) => setState(() => _soundEnabled = v),
                        ),
                        _buildDivider(),
                        _buildNavItem(
                          icon: Icons.language_outlined,
                          iconColor: const Color(0xFF3A8A92),
                          iconBg: const Color(0xFFD8EEF0),
                          title: 'Language',
                          trailing: 'English',
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // Account section
                      _buildSectionTitle('Account'),
                      const SizedBox(height: 10),
                      _buildSettingsCard([
                        _buildNavItem(
                          icon: Icons.person_outline_rounded,
                          iconColor: AppColors.sageDark,
                          iconBg: AppColors.backgroundGreen,
                          title: 'Edit Profile',
                          trailing: null,
                        ),
                        _buildDivider(),
                        _buildNavItem(
                          icon: Icons.lock_outline_rounded,
                          iconColor: const Color(0xFF5AB8C0),
                          iconBg: const Color(0xFFD8EEF0),
                          title: 'Privacy & Security',
                          trailing: null,
                        ),
                        _buildDivider(),
                        _buildNavItem(
                          icon: Icons.star_outline_rounded,
                          iconColor: const Color(0xFFE8C84A),
                          iconBg: const Color(0xFFFAF2D0),
                          title: 'Upgrade to Premium',
                          trailing: null,
                          trailingWidget: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        _buildDivider(),
                        _buildNavItem(
                          icon: Icons.help_outline_rounded,
                          iconColor: AppColors.textGrey,
                          iconBg: const Color(0xFFEEEEEE),
                          title: 'Help & Support',
                          trailing: null,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // Logout button
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE85858).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFE85858),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Log Out',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFE85858),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Version info
                      const Center(
                        child: Text(
                          'Peaceful Mind v1.0.0',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                          ),
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
    );
  }

  Widget _buildQuickStat(String value, String label, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textGrey,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.sageDark,
            activeTrackColor: AppColors.sageMedium,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFDDDDDD),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String? trailing,
    Widget? trailingWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          if (trailingWidget != null) trailingWidget,
          if (trailing != null) ...[
            const SizedBox(width: 6),
            Text(
              trailing,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ],
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textLight,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 70),
      child: Divider(
        height: 1,
        thickness: 1,
        color: const Color(0xFFF0F0F0),
      ),
    );
  }
}
