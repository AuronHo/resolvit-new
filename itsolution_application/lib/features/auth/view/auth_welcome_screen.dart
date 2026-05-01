import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_colors.dart';
import '../../main_navigation/logic/theme_controller.dart'; 

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});
  
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      // 1. Inisialisasi Kunci (Perubahan Wajib di Versi 7+)
      await GoogleSignIn.instance.initialize(
        serverClientId: '331772422234-7v78imkrihg9fgajvk9hf5qasneu3vdg.apps.googleusercontent.com',
      );

      // 2. Fungsi signIn() diganti menjadi authenticate() di Versi 7+
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) return; // Batal login (tutup popup)

      // 3. Ambil ID Token
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        // Tembak ke Golang (Pakai 10.0.2.2 karena ini Emulator Android)
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8080/api/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id_token': idToken}),
        );

        // Mencegah crash jika user menutup halaman sebelum loading selesai
        if (!context.mounted) return; 

        if (response.statusCode == 200) {
          print("🔍 RAW RESPONSE: ${response.body}"); // CCTV kita
          
          final responseBody = jsonDecode(response.body);
          
          String? jwtToken;
          int? userId;

          // --- DETEKTOR BENTUK JSON OTOMATIS ---
          // SKENARIO 1: Kalau JSON dibungkus "data" (Seperti Postman tadi)
          if (responseBody['data'] != null) {
            jwtToken = responseBody['data']['token'];
            // Cari ID, entah namanya 'user_id' atau ada di dalam 'user'
            userId = responseBody['data']['user_id'] ?? (responseBody['data']['user'] != null ? responseBody['data']['user']['id'] : null);
          } 
          // SKENARIO 2: Kalau JSON tidak dibungkus (Langsung di luar)
          else {
            jwtToken = responseBody['token'];
            // Cari ID langsung
            userId = responseBody['user_id'] ?? (responseBody['user'] != null ? responseBody['user']['id'] : null);
          }
          // ------------------------------------

          // Cegah crash kalau ternyata Golang emang gak ngirim token/ID
          if (jwtToken == null || userId == null) {
            print("❌ STRUKTUR JSON GOLANG TIDAK LENGKAP: ${response.body}");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terjadi kesalahan data dari server.'), backgroundColor: Colors.red),
            );
            return; 
          }
          
          print("🎉 LOGIN GOOGLE SUKSES! Token: $jwtToken | UserID: $userId");
          
          // --- STEP A: SIMPAN TOKEN & ID KE MEMORI HP ---
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', jwtToken.toString());
          await prefs.setInt('currentUserId', userId);

          // --- STEP B: CEK APAKAH LAYAR MASIH ADA ---
          if (!context.mounted) return;

          // --- STEP C: PINDAH KE HALAMAN HOME ---
          // Gunakan pushReplacementNamed supaya user tidak bisa "Back" ke Login lagi
          Navigator.pushReplacementNamed(context, '/home'); 

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selamat Datang di Resolv IT!')),
          );
        } else {
          print("❌ Gagal di Golang: ${response.body}");
        }
      }
    } catch (error) {
      print("❌ Error Google Sign In: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F2027), const Color(0xFF2C5364)] 
                : [kGradientTop, kGradientBottom], 
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                // 1. ADJUST TOP MARGIN (Moves "Resolv IT" up or down)
                const SizedBox(height: 60), 

                // --- TITLE ---
                Center(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 40, 
                        color: Colors.white, 
                        fontFamily: 'Roboto', 
                        height: 1.0,
                      ),
                      children: [
                        TextSpan(
                          text: 'Resolv', 
                          style: TextStyle(fontWeight: FontWeight.w300), 
                        ),
                        TextSpan(text: ' '),
                        TextSpan(
                          text: 'IT', 
                          style: TextStyle(fontWeight: FontWeight.bold), 
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. ADJUST GAP (Distance between Title and Logo)
                const SizedBox(height: 100), 

                // --- LOGO ---
                Center(
                  child: Image.asset(
                    'assets/images/resolvit_logo.png', 
                    // 3. ADJUST LOGO HEIGHT (Make it taller/shorter here)
                    height: 300, 
                    fit: BoxFit.contain,
                  ),
                ),

                // This spacer takes up all remaining space to push buttons to bottom
                const Spacer(), 

                // --- BUTTONS ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _handleGoogleSignIn(context);// Google Sign In Logic
                        },
                        icon: Image.asset(
                          'assets/images/google_logo.png', 
                          height: 24,
                        ),
                        label: const Text('Continue with Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 3,
                          minimumSize: const Size(double.infinity, 50), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/create_account');
                        },
                        child: const Text('Sign Up'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryBlue, 
                          foregroundColor: Colors.white,
                          elevation: 3,
                          minimumSize: const Size(double.infinity, 50), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- FOOTER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey[600]), 
                    ),
                    GestureDetector(
                      onTap: () {
                        // Login Logic
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          color: kPrimaryBlue, 
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: kPrimaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}