import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MoodService {
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

  // Mengambil riwayat mood dari backend
  Future<List<Map<String, dynamic>>> fetchMoodHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$backendUrl/api/moods/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> recordsList = data['mood_records'] ?? [];
          return recordsList.map((item) => item as Map<String, dynamic>).toList();
        }
      }
      throw Exception('Gagal memuat riwayat mood: ${response.body}');
    } catch (e) {
      print('Error fetchMoodHistory: $e');
      return [];
    }
  }

  // Menyimpan hasil deteksi mood ke backend
  Future<Map<String, dynamic>?> recordMood({
    required String mood,
    required String stressLevel,
    required String hrv,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'mood': mood,
        'stress_level': stressLevel,
        'hrv': hrv,
      });

      final response = await http.post(
        Uri.parse('$backendUrl/api/moods/record'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['mood_record'];
        }
      }
      print('Gagal merekam mood: ${response.body}');
      return null;
    } catch (e) {
      print('Error recordMood: $e');
      return null;
    }
  }
}
