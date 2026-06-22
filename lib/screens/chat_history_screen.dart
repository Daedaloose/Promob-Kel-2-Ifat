import 'package:flutter/material.dart';
import 'package:peaceful_mind/screens/ai_chat_screen.dart';
import 'package:peaceful_mind/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:peaceful_mind/services/local_chat_state.dart';
import 'package:peaceful_mind/widgets/mochi_face.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    // Refresh if returning
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Sesuai tema
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _showArchived ? 'Arsip Konseling' : 'Riwayat Konseling',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showArchived ? Icons.unarchive_rounded : Icons.archive_outlined,
              color: AppColors.textDark,
            ),
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: (!_showArchived && LocalChatState.chatHistories.where((c) => c['isArchived'] != true).isNotEmpty)
          ? FloatingActionButton.extended(
              onPressed: () => _startNewChat(),
              backgroundColor: AppColors.sageDark,
              icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
              label: const Text(
                'Sesi Baru',
                style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    final displayedChats = LocalChatState.chatHistories.where((c) {
      final isArchived = c['isArchived'] == true;
      return _showArchived ? isArchived : !isArchived;
    }).toList();

    if (displayedChats.isEmpty) {
      return _buildEmptyState();
    }
    return _buildHistoryList(displayedChats);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustrasi Mochi-Brain Comic
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.backgroundGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sageDeep.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Center(
                child: MiniMochiFace(mood: 'Bahagia', baseColor: AppColors.sageDeep, size: 80),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Belum Ada Sesi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _showArchived 
                ? 'Tidak ada sesi yang diarsipkan.' 
                : 'Mulai ceritakan keluh kesahmu pada MindBot. Kami siap mendengarkan kapan pun kamu butuh.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            if (!_showArchived)
              ElevatedButton(
                onPressed: () => _startNewChat(),
                style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageDeep,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Mulai Chat Sekarang',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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

  Widget _buildHalodocBanner() {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(
            'https://www.halodoc.com/tanya-dokter/kategori/psikolog-klinis?srsltid=AfmBOop2XSw29oSvGHKwaVwmt85YzMvuJPuKDmXp_6BtWcgLrmMYn_7V');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE5001C).withOpacity(0.05), // Halodoc red light
          border: Border.all(color: const Color(0xFFE5001C).withOpacity(0.2), width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE5001C),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Butuh Bantuan Profesional?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Konsultasi dengan Psikolog Klinis via Halodoc.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFE5001C), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> displayedChats) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80), // bottom padding for FAB
      itemCount: displayedChats.length + (_showArchived ? 0 : 1), // +1 for Halodoc banner if not archived
      itemBuilder: (context, index) {
        if (!_showArchived && index == 0) {
          return _buildHalodocBanner();
        }
        
        final listIndex = _showArchived ? index : index - 1;
        final chat = displayedChats[listIndex];
        
        return Dismissible(
          key: Key(chat['id']),
          // If archived, we can unarchive (swipe right) or delete (swipe left)
          // If not archived, we can archive (swipe right) or delete (swipe left)
          direction: DismissDirection.horizontal,
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _showArchived ? AppColors.sageDeep : const Color(0xFFF5D77A), // Green/Yellow
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerLeft,
            child: Icon(_showArchived ? Icons.unarchive_rounded : Icons.archive_rounded, color: Colors.white, size: 30),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE85858), // Red color for delete
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 30),
          ),
          onDismissed: (direction) {
            final globalIndex = LocalChatState.chatHistories.indexWhere((c) => c['id'] == chat['id']);
            if (globalIndex == -1) return;

            if (direction == DismissDirection.endToStart) {
              // Delete
              setState(() {
                LocalChatState.chatHistories.removeAt(globalIndex);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sesi obrolan berhasil dihapus'),
                  backgroundColor: AppColors.sageDeep,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (direction == DismissDirection.startToEnd) {
              // Archive / Unarchive
              setState(() {
                LocalChatState.chatHistories[globalIndex]['isArchived'] = !_showArchived;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_showArchived ? 'Sesi dikembalikan dari arsip' : 'Sesi diarsipkan'),
                  backgroundColor: AppColors.sageDeep,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: GestureDetector(
            onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AiChatScreen(chatId: chat['id'])),
            );
            _refresh();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: chat['moodColor'].withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Ilustrasi Comic
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: chat['moodColor'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: MiniMochiFace(mood: chat['mood'], baseColor: chat['moodColor'], size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                // Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            chat['date'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            chat['time'],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Badge Mood
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: chat['moodColor'],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Mood: ${chat['mood']}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"${chat['lastMessage']}"',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
      },
    );
  }

  void _startNewChat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiChatScreen()),
    );
    _refresh();
  }
}
