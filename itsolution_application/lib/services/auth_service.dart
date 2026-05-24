import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  String get baseUrl => '${ApiService.baseUrl}/api';

  // Fungsi untuk Register (Sign Up)
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": "customer", // Default role
      }),
    );
    return jsonDecode(response.body);
  }

  // Fungsi untuk Login manual
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // Langsung simpan token jika berhasil
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']);
    }
    return data;
  }
}
