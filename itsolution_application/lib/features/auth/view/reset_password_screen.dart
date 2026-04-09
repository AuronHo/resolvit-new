import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../main_navigation/logic/theme_controller.dart'; 
import '../../../constants/app_colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleResetPassword() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil API Golang (Ganti IP jika tidak pakai emulator)
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // Berhasil kirim OTP
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification code sent to $email'), 
            backgroundColor: Colors.green
          ),
        );
        
        // Pindah ke halaman input kode verifikasi & password baru
        // Kita kirim email-nya sebagai argument agar layar berikutnya tahu email siapa yang di-reset
        Navigator.pushNamed(
          context, 
          '/verification_code', 
          arguments: email
        );
      } else {
        // Gagal (Misal: masalah server)
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? 'Failed to send OTP'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error to server'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    // Warna elemen dinamis
    final Color dynamicTextColor = isDark ? Colors.white : Colors.black;
    final Color dynamicInputFill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    const Color buttonColor = Color(0xFF4981FB); 

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: dynamicTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        // Kosongkan title di AppBar agar mirip gambar (Title ada di body)
        // atau bisa taruh di sini jika ingin sticky. 
        // Di gambar, tulisan "Reset Password" agak turun, jadi kita taruh di body.
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        
        // --- GRADIENT BACKGROUND ---
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: isDark
                ? [const Color(0xFF0F2027), const Color(0xFF2C5364)] 
                : [
                    const Color(0xFFFFFFFF), // 0% Putih
                    const Color(0xFF9BBAFD), // 50% Biru Muda
                    const Color(0xFF3573FA), // 100% Biru Utama
                  ],
            stops: isDark ? null : [0.0, 0.5, 1.0], 
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // --- JUDUL HALAMAN ---
                Center(
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: dynamicTextColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),

                // --- INPUT EMAIL ---
                Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dynamicTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: dynamicTextColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: dynamicInputFill,
                    hintText: '', // Kosong sesuai gambar
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none, 
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- HELPER TEXT ---
                Center(
                  child: Text(
                    'We will send you a verification code.',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- BUTTON RESET ---
                ElevatedButton(
                  // Panggil fungsi yang baru kita update
                  onPressed: _isLoading ? null : _handleResetPassword, 
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor, // Warna biru #4981FB
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        )
                      : const Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}