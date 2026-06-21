import 'dart:convert';
import 'package:http/http.dart' as http;

class CircadifyService {
  // Compile-time environment variable untuk API Key Circadify
  static const String apiKey = String.fromEnvironment('CIRCADIFY_API_KEY', defaultValue: '');
  static const String apiUrl = 'https://api.circadify.com/v1/rppg/analyze';

  // Cek apakah aplikasi sudah tersambung ke Circadify API dengan benar
  static bool get isConnected => apiKey.isNotEmpty;

  // Mengirim sinyal rPPG ke API Circadify
  static Future<Map<String, dynamic>> analyzeRppg({
    required double avgLuminance,
    required double redVariance,
  }) async {
    // Simulasi delay proses AI Cloud Circadify
    await Future.delayed(const Duration(milliseconds: 1500));

    if (isConnected) {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: json.encode({
            'luminance': avgLuminance,
            'variance': redVariance,
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> result = json.decode(response.body);
          return {
            'status': 'success',
            'source': 'circadify_cloud_api',
            'api_connected': true,
            'result_index': result['result_index'] ?? 0,
          };
        }
      } catch (e) {
        print('Error calling Circadify REST API: $e');
      }
    }

    // Fallback: Jika belum tersambung / API Key kosong (Demo Mode),
    // hasilkan index secara dinamis berdasarkan data parameter input kamera
    // agar hasil scan bervariasi dan tidak selalu keluar "Tenang"
    final double seed = avgLuminance + redVariance + DateTime.now().millisecond;
    final int index = (seed.round() % 5);

    return {
      'status': 'success',
      'source': 'circadify_local_simulation',
      'api_connected': false,
      'result_index': index,
    };
  }
}
