import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

  static Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final currentUserId = await getCurrentUserId();
      final userIdParam = currentUserId != null ? currentUserId.toString() : '0';
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/services/recommendations?user_id=$userIdParam'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mengambil rekomendasi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  static Future<Map<String, dynamic>> getServicesByCategory(String categoryName, {int page = 1}) async {
    try {
      // --- 1. AMBIL ID USER AKTIF ---
      // (Fungsi ini sudah kita buat sebelumnya di file yang sama)
      final currentUserId = await getCurrentUserId();
      final userIdParam = currentUserId != null ? currentUserId.toString() : '0';
      // ------------------------------

      final String encodedCategory = Uri.encodeComponent(categoryName);
      
      // --- 2. TAMBAHKAN user_id KE URL ---
      final Uri url = Uri.parse('http://10.0.2.2:8080/api/services/category?name=$encodedCategory&page=$page&user_id=$userIdParam');
      
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  static Future<Map<String, dynamic>> getSavedServices({required int userId}) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/services/saved?user_id=$userId');
      print("Mencoba GET ke URL: $url"); // CCTV 1

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print("Status Code dari Server: ${response.statusCode}"); // CCTV 2
      print("Body dari Server: ${response.body}"); // CCTV 3

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Sekarang error-nya akan mencetak alasan dari Golang!
        throw Exception('Server menolak dengan status ${response.statusCode}. Alasan: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  static Future<void> toggleSaveService({required int userId, required int jasaId}) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/services/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'jasa_id': jasaId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal toggle bookmark');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile({required int userId}) async {
    try {
      // Ingat: Saat ini kita masih pakai userId=1. Nanti diganti dengan token JWT.
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/users/$userId'), 
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mengambil data profil');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  static Future<void> syncGoogleLogin({
    required String name,
    required String email,
    required String avatarUrl,
  }) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/auth/sync'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final realUserId = data['user']['id']; // Ini ID asli dari database!

      // Simpan ID ini ke memori HP secara permanen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentUserId', realUserId);
    } else {
      throw Exception('Gagal sinkronisasi login');
    }
  }

  // Fungsi untuk mengambil ID yang sedang aktif
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('currentUserId');
  }
}