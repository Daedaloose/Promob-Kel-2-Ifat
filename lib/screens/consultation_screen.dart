import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _typingCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _typingAnim;

  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  bool _consultWithAI = true;
  bool _isTyping = false;
  String _currentAvatarMood = 'calm'; // Digital twin mood

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          'Halo! Saya adalah AI MediCore, asisten kesehatan virtualmu. Berdasarkan data rPPG terakhirmu, tingkat stresmu sedikit meningkat. Ada yang ingin kamu ceritakan?',
      isAI: true,
      time: '15:30',
    ),
    _ChatMessage(
      text: 'Iya dok, akhir-akhir ini saya sering merasa lelah dan susah fokus.',
      isAI: false,
      time: '15:31',
    ),
    _ChatMessage(
      text:
          'Saya memahami kondisimu. Berdasarkan data biometrik dan mood tracker minggu ini, terlihat pola stres yang berulang di tengah minggu. Ini sering terjadi pada mahasiswa semester aktif. Apakah kualitas tidurmu akhir-akhir ini terganggu?',
      isAI: true,
      time: '15:31',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _typingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _typingAnim =
        CurvedAnimation(parent: _typingCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _typingCtrl.dispose();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isAI: false, time: '15:35'));
      _isTyping = true;
      _currentAvatarMood = 'calm';
      _msgCtrl.clear();
    });
    _typingCtrl.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _typingCtrl.stop();
          _messages.add(_ChatMessage(
            text:
                'Terima kasih sudah berbagi. Saya sarankan untuk mengatur jadwal tidur yang konsisten dan mencoba teknik breathing 4-7-8 sebelum tidur. Apakah kamu ingin saya buatkan rencana pemulihan stres?',
            isAI: true,
            time: '15:35',
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildAppBar(context),
              _buildModeToggle(),
              if (_consultWithAI) _buildDigitalTwinBanner(),
              Expanded(child: _buildChatArea()),
              _buildInputBar(),
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
              Text('Konsultasi Online', style: AppTheme.titleLarge),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _consultWithAI ? 'AI MediCore aktif' : 'Dokter tersedia',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.accentGreen),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Icon(Icons.more_vert_rounded,
                color: AppTheme.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _consultWithAI = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient:
                        _consultWithAI ? AppTheme.primaryGradient : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy_rounded,
                        size: 16,
                        color: _consultWithAI
                            ? Colors.white
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Konsultasi AI',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _consultWithAI
                              ? Colors.white
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _consultWithAI = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient:
                        !_consultWithAI ? AppTheme.cyanGradient : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_rounded,
                        size: 16,
                        color: !_consultWithAI
                            ? Colors.white
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Konsultasi Dokter',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: !_consultWithAI
                              ? Colors.white
                              : AppTheme.textMuted,
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

  // ─── Digital Twin Banner ──────────────────────────────────────────────────
  Widget _buildDigitalTwinBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: AppTheme.accent.withOpacity(0.3),
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.1),
            AppTheme.accentPink.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: [
            // Digital Twin Avatar (mini)
            GlowingOrb(mood: _currentAvatarMood, size: 80),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'DIGITAL TWIN',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Avatar kamu saat ini: ${_getMoodLabel(_currentAvatarMood)}',
                    style: AppTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tampilan avatar berubah mengikuti kondisi rPPG & Mood Tracker. Aura mencerminkan kondisi mentalmu.',
                    style: AppTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  // Mood switcher (simulate)
                  Row(
                    children: [
                      _MoodDot('calm', 'Tenang', AppTheme.accent),
                      const SizedBox(width: 8),
                      _MoodDot('stressed', 'Stres', AppTheme.accentPink),
                      const SizedBox(width: 8),
                      _MoodDot('glitchy', 'Burnout', const Color(0xFFFF3366)),
                      const SizedBox(width: 8),
                      _MoodDot('happy', 'Bahagia', AppTheme.accentGreen),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _MoodDot(String moodKey, String label, Color color) {
    final isSelected = _currentAvatarMood == moodKey;
    return GestureDetector(
      onTap: () => setState(() => _currentAvatarMood = moodKey),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : color.withOpacity(0.3),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
                  : [],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              color: isSelected ? color : AppTheme.textMuted,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'calm':
        return 'Tenang & Stabil';
      case 'stressed':
        return 'Sedikit Stres';
      case 'glitchy':
        return 'Burnout';
      case 'happy':
        return 'Semangat!';
      default:
        return 'Normal';
    }
  }

  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _TypingIndicator(animation: _typingAnim);
        }
        return _ChatBubble(message: _messages[index]);
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          // Voice button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Icon(Icons.mic_rounded,
                color: AppTheme.textSecondary, size: 22),
          ),
          const SizedBox(width: 12),
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Ketik pesanmu...',
                        hintStyle: AppTheme.bodySmall,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      child: const Icon(Icons.attach_file_rounded,
                          color: AppTheme.textMuted, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: _consultWithAI
                    ? AppTheme.primaryGradient
                    : AppTheme.cyanGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat Bubble ─────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAI = message.isAI;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAI) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isAI
                    ? null
                    : AppTheme.primaryGradient,
                color: isAI ? AppTheme.surfaceLight : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isAI ? 4 : 20),
                  bottomRight: Radius.circular(isAI ? 20 : 4),
                ),
                border: isAI
                    ? Border.all(color: AppTheme.borderColor)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.time,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isAI) ...[
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppTheme.textSecondary, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Typing Indicator ────────────────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  final Animation<double> animation;
  const _TypingIndicator({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Transform.translate(
                        offset: Offset(0,
                            -4 * ((animation.value + i * 0.33) % 1.0 < 0.5
                                ? (animation.value + i * 0.33) % 1.0
                                : 1.0 - (animation.value + i * 0.33) % 1.0)),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isAI;
  final String time;
  _ChatMessage({required this.text, required this.isAI, required this.time});
}
