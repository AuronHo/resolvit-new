import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';

class AuthController extends ChangeNotifier {

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // --- STATE VARIABLES ---

  // 2. We make the state "private"
  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;

  // 3. We create public "getters" for the UI to read the state
  bool get isPasswordVisible => _isPasswordVisible;
  bool get agreedToTerms => _agreedToTerms;

  // --- LOGIC METHODS ---

  // 4. This method updates the state and "notifies" the UI
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners(); // This tells the UI to rebuild!
  }

  // 5. This method also updates the state and notifies
  void setAgreedToTerms(bool? value) {
    _agreedToTerms = value ?? false;
    notifyListeners(); // This tells the UI to rebuild!
  }

  // 6. This logic was moved from the screen
  Future<void> launchTermsUrl() async {
    final Uri url = Uri.parse('https://resolvit-privacy.netlify.app/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  // 7. This is your main registration logic.
  // We'll make it return a boolean for success/failure
  // so the UI can show the right SnackBar.
  // Returns null on success, error string on failure.
  Future<String?> registerUser() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "role": "customer"
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = body['token'] as String?;
        final userId = body['user_id'];
        if (token != null && userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          await prefs.setInt('currentUserId', (userId as num).toInt());
        }
        return null; // success
      }

      return body['error'] as String? ?? 'Registration failed';
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  // Fungsi Login Dummy
  Future<bool> loginUser(String email, String password) async {
    try {
      debugPrint('LOGIN URL: ${ApiService.baseUrl}/api/login');
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        
        // --- 1. AMBIL TOKEN & ID DENGAN DETEKTOR OTOMATIS ---
        String? token;
        int? userId;

        // Mengecek apakah data dibungkus objek "data" atau tidak
        if (responseBody['data'] != null) {
          token = responseBody['data']['token'];
          userId = responseBody['data']['user_id'] ?? (responseBody['data']['user'] != null ? responseBody['data']['user']['id'] : null);
        } else {
          token = responseBody['token'];
          userId = responseBody['user_id'] ?? (responseBody['user'] != null ? responseBody['user']['id'] : null);
        }

        // --- 2. SIMPAN KEDUANYA KE MEMORI HP ---
        if (token != null && userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          await prefs.setInt('currentUserId', userId);

          // Restore business account link if server sent it
          final linkedId = responseBody['linked_provider_id'] ??
              (responseBody['data'] != null
                  ? responseBody['data']['linked_provider_id']
                  : null);
          if (linkedId != null && linkedId != 0) {
            await prefs.setInt('business_user_id', linkedId as int);
          }

          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> sendForgotPasswordOTP(String email) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/forgot-password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/reset-password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "new_password": newPassword,
      }),
    );
    return jsonDecode(response.body);
  }
}