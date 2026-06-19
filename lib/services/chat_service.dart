import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Endpoint backend Vercel
  static const String backendUrl = AuthService.backendUrl;

  // Mendapatkan header otentikasi Firebase
  Future<Map<String, String>> _getHeaders() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User tidak terautentikasi.');
    }
    final String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Gagal mendapatkan token autentikasi.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
  }

  // Mengirim pesan curhat ke asisten AI backend
  Future<String> sendChatMessage(String message, {List<Map<String, dynamic>>? history}) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'message': message,
        'history': history,
      });

      final response = await http.post(
        Uri.parse('$backendUrl/api/chat'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['reply'] ?? 'Tidak ada jawaban.';
        }
      }
      return 'Maaf, saya sedang kesulitan memproses pesan Anda. Coba beberapa saat lagi.';
    } catch (e) {
      print('Error sendChatMessage: $e');
      return 'Koneksi ke asisten AI terganggu. Pastikan internet Anda aktif.';
    }
  }
}
