import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // PILIH SALAH SATU BASE URL DI BAWAH INI:
  
  // OPSI A: Jika pakai Emulator Android Studio
  // static const String _baseUrl = "http://10.0.2.2:8000";

  // OPSI B: Jika pakai HP Fisik & WiFi Sama (Ganti angka sesuai ipconfig laptop)
  // static const String _baseUrl = "http://192.168.1.8:8000";

  // OPSI C: Jika pakai Ngrok (Harus ganti link setiap restart ngrok)
  static const String _baseUrl = "https://permissively-photoperiodic-angelic.ngrok-free.dev"; 

  // =======================================================================

  // Kita ubah return type jadi Map agar bisa bawa 'results' DAN 'message'
  static Future<Map<String, dynamic>> searchServices(String query) async {
    final Uri apiUrl =
        Uri.parse('$_baseUrl/search?query=${Uri.encodeComponent(query)}');

    print("Mencoba request ke: $apiUrl"); 

    try {
      final response = await http.get(apiUrl).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Cek struktur data baru dari Python
        // Python return: {"results": [...], "message": "..."}
        
        List<dynamic> results = [];
        String? message = data['message']; // Ambil pesan saran AI

        if (data['results'] is List) {
          results = data['results'];
        }

        // Kembalikan paket lengkap
        return {
          'results': results,
          'message': message, 
        };

      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      print("Error detail: $e");
      throw Exception('Gagal terhubung. Cek Server Python / Ngrok / IP.');
    }
  }
}