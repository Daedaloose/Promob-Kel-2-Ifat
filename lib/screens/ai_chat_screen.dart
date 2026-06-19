import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../services/chat_service.dart';
import 'comfort_food_screen.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  late AnimationController _dotController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
      'Hai! Aku MindBot 🧠, asisten kesehatan mental kamu yang siap menemani kapan saja. Gimana perasaanmu hari ini?',
      isAI: true,
      time: '09:00',
    ),
  ];

  final List<String> _quickReplies = [
    '😔 Lagi sedih',
    '😰 Stres banget',
    '😴 Capek & burnout',
    '😤 Frustrasi',
    '💬 Mau cerita',
  ];

  // AI responses based on keywords (heuristic RAG simulation)
  final Map<String, String> _aiResponses = {
    'sedih': 'Aku dengar kamu sedang sedih 💙 Itu wajar banget, kamu tidak harus selalu baik-baik saja. Mau ceritain apa yang bikin kamu sedih? Aku di sini untuk mendengarkan, tanpa menghakimi.',
    'stres': 'Stres memang berat ya, apalagi kalau kamu tanggung sendirian 🌿 Dari skala 1–10, seberapa berat rasanya sekarang? Kita coba cari cara yang bisa bantu meringankan sedikit demi sedikit.',
    'capek': 'Capek bukan tanda kelemahan, tapi tanda kamu sudah bekerja keras 💚 Sudah berapa lama kamu merasakan kelelahan ini? Mungkin tubuh dan pikiranmu sedang minta istirahat.',
    'burnout': 'Burnout itu nyata dan serius 🌱 Tubuh dan pikiranmu sudah memberi sinyal untuk berhenti sejenak. Coba ceritakan, kapan terakhir kali kamu benar-benar istirahat tanpa rasa bersalah?',
    'frustrasi': 'Frustrasi itu tanda kamu peduli pada sesuatu yang penting 🍃 Situasi apa yang bikin kamu frustrasi? Cerita pelan-pelan, aku akan menyimak dengan baik.',
    'kesepian': 'Rasa kesepian bisa sangat menyiksa, bahkan di tengah keramaian 🌿 Kamu tidak sendirian, aku di sini. Sudah lama kamu merasakan ini?',
    'anxious': 'Kecemasan itu kadang datang tiba-tiba tanpa permisi ya 💚 Tarik napas perlahan dulu bersamaku. Masuk 4 detik... tahan 4 detik... keluar 4 detik. Lebih baik sedikit?',
    'takut': 'Rasa takut itu manusiawi banget 🌱 Mau ceritakan apa yang kamu takutkan? Kita bisa hadapi bersama, satu langkah kecil setiap harinya.',
    'default': 'Terima kasih sudah berbagi denganku 💙 Aku dengar kamu. Bisa ceritakan lebih lanjut? Aku ingin benar-benar memahami apa yang kamu rasakan sekarang.',
  };

  @override
  void initState() {
    super.initState();
    _focusNode.onKeyEvent = (node, event) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
        if (!isShiftPressed) {
          if (event is KeyDownEvent) {
            _sendMessage(_inputController.text);
          }
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _dotController.dispose();
    _fadeController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  final ChatService _chatService = ChatService();

  final List<String> _detectableFoods = [
    'Martabak Manis',
    'Es Krim Coklat',
    'Pisang Goreng Keju',
    'Mie Ayam Bakso',
    'Soto Ayam',
    'Indomie Telur',
    'Nasi Goreng Kampung',
    'Ayam Geprek',
    'Gorengan Mix',
    'Es Teh Manis',
    'Wedang Jahe',
    'Boba Brown Sugar',
  ];

  void _sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    // Ambil riwayat percakapan saat ini sebelum ditambahkan pesan baru
    final List<Map<String, dynamic>> historyList = _messages.map((m) => {
      'text': m.text,
      'is_ai': m.isAI,
    }).toList();

    setState(() {
      _messages.add(_ChatMessage(
        text: trimmedText,
        isAI: false,
        time: _nowTime(),
      ));
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    // Kirim pesan curhat ke backend API (Gemini) dengan riwayat
    final reply = await _chatService.sendChatMessage(trimmedText, history: historyList);

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(
        text: reply,
        isAI: true,
        time: _nowTime(),
      ));
    });
    _scrollToBottom();
  }

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
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
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // AI avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.sageDark,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Center(
                              child: Text('🧠', style: TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MindBot AI',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Aktif • Konselor AI 24/7',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
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
                                Icon(Icons.lock_outline_rounded,
                                    size: 11, color: AppColors.sageMedium),
                                SizedBox(width: 4),
                                Text(
                                  'Privat',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.sageMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Disclaimer banner
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: const [
                          Text('💡', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'MindBot bukan pengganti psikolog profesional. Untuk krisis, hubungi Into The Light: 119 ext 8.',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGrey,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chat area
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
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildBubble(_messages[index]);
                  },
                ),
              ),
            ),

            // Quick replies
            if (_messages.length <= 2)
              Container(
                color: const Color(0xFFF5F5F0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: _quickReplies.map((reply) {
                      return GestureDetector(
                        onTap: () => _sendMessage(reply),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.sageMedium.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            reply,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Input bar
            Container(
              color: const Color(0xFFF5F5F0),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.sageMedium.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              focusNode: _focusNode,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Ceritakan perasaanmu...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  color: AppColors.textLight,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: _sendMessage,
                              maxLines: null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Mic icon
                          Icon(Icons.mic_none_rounded,
                              color: AppColors.textLight, size: 20),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(_inputController.text),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.darkButton,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    final isAI = msg.isAI;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
        isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAI) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.sageDark,
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('🧠', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
              isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAI ? Colors.white : AppColors.darkButton,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isAI ? 4 : 20),
                      bottomRight: Radius.circular(isAI ? 20 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isAI ? AppColors.textDark : Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                if (isAI) ...[
                  (() {
                    final List<String> foundFoods = [];
                    for (final food in _detectableFoods) {
                      if (msg.text.toLowerCase().contains(food.toLowerCase())) {
                        foundFoods.add(food);
                      }
                    }
                    if (foundFoods.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: foundFoods.map((foodName) {
                          return ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ComfortFoodScreen(searchFood: foodName),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.backgroundGreen,
                              foregroundColor: AppColors.sageDeep,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Text('🛵', style: TextStyle(fontSize: 12)),
                            label: Text(
                              'Cari $foodName Terdekat',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }()),
                ],
                const SizedBox(height: 4),
                Text(
                  msg.time,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (!isAI) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.backgroundGreen,
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('👩', style: TextStyle(fontSize: 16))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.sageDark,
              shape: BoxShape.circle,
            ),
            child:
            const Center(child: Text('🧠', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _dotController,
              builder: (context, child) {
                return Row(
                  children: List.generate(3, (i) {
                    final delay = i * 0.33;
                    final progress =
                    (_dotController.value - delay).clamp(0.0, 1.0);
                    final opacity =
                    (math.sin(progress * math.pi * 2) * 0.5 + 0.5)
                        .clamp(0.3, 1.0);
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.sageDark.withValues(alpha: opacity),
                        shape: BoxShape.circle,
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
