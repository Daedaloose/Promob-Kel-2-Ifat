import 'package:flutter/material.dart';

class LocalChatState {
  static List<Map<String, dynamic>> chatHistories = [
    {
      'id': '1',
      'date': 'Senin, 22 Jun 2026',
      'time': '06:24',
      'mood': 'Cemas',
      'moodColor': const Color(0xFFE8834A),
      'lastMessage': 'Aku ngerasa deg-degan banget ngerjain tugas...',
      'messages': [
        {'text': 'Hai! Aku MindBot 🧠, asisten kesehatan mental kamu yang siap menemani kapan saja. Gimana perasaanmu hari ini?', 'isAI': true, 'time': '06:20'},
        {'text': 'Aku ngerasa deg-degan banget ngerjain tugas...', 'isAI': false, 'time': '06:24'},
        {'text': 'Wajar kok ngerasa cemas saat banyak tugas. Tarik napas panjang, kerjain satu-satu pelan-pelan ya. Kamu pasti bisa!', 'isAI': true, 'time': '06:24'},
      ]
    },
    {
      'id': '2',
      'date': 'Minggu, 21 Jun 2026',
      'time': '21:10',
      'mood': 'Lelah',
      'moodColor': const Color(0xFFE85858),
      'lastMessage': 'Hari ini capek banget, pengen langsung tidur aja.',
      'messages': [
        {'text': 'Hai! Aku MindBot 🧠, asisten kesehatan mental kamu yang siap menemani kapan saja. Gimana perasaanmu hari ini?', 'isAI': true, 'time': '21:05'},
        {'text': 'Hari ini capek banget, pengen langsung tidur aja.', 'isAI': false, 'time': '21:10'},
        {'text': 'Kerja kerasmu hari ini luar biasa. Istirahatlah, kamu sangat pantas mendapatkan tidur yang nyenyak malam ini. Selamat beristirahat! 🌙', 'isAI': true, 'time': '21:10'},
      ]
    },
    {
      'id': '3',
      'date': 'Sabtu, 20 Jun 2026',
      'time': '10:05',
      'mood': 'Bahagia',
      'moodColor': const Color(0xFF8FCC8F),
      'lastMessage': 'Tadi aku makan comfort food dan moodku mendingan!',
      'messages': [
        {'text': 'Hai! Aku MindBot 🧠, asisten kesehatan mental kamu yang siap menemani kapan saja. Gimana perasaanmu hari ini?', 'isAI': true, 'time': '10:00'},
        {'text': 'Tadi aku makan comfort food dan moodku mendingan!', 'isAI': false, 'time': '10:05'},
        {'text': 'Wah ikut senang mendengarnya! Makanan enak memang sering jadi pelukan instan buat hati kita. Enjoy the rest of your day! ✨', 'isAI': true, 'time': '10:06'},
      ]
    },
  ];
}
