import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class JournalService {
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

  // Mengambil daftar jurnal dari backend
  Future<List<Map<String, dynamic>>> fetchJournals() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$backendUrl/api/journals'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> journalsList = data['journals'] ?? [];
          return journalsList.map((item) => item as Map<String, dynamic>).toList();
        }
      }
      throw Exception('Gagal memuat jurnal: ${response.body}');
    } catch (e) {
      print('Error fetchJournals: $e');
      return [];
    }
  }

  // Menyimpan jurnal baru ke backend
  Future<Map<String, dynamic>?> createJournal({
    required String title,
    required String content,
    String? mood,
    String? tag,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'title': title,
        'content': content,
        'mood': mood,
        'tag': tag,
      });

      final response = await http.post(
        Uri.parse('$backendUrl/api/journals'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['journal'];
        }
      }
      print('Gagal membuat jurnal: ${response.body}');
      return null;
    } catch (e) {
      print('Error createJournal: $e');
      return null;
    }
  }
}
