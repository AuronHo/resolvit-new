import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../main_navigation/logic/theme_controller.dart'; 
import '../../../constants/app_colors.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

bool _isLoading = false;

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    final Color dynamicTextColor = isDark ? Colors.white : Colors.black;
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
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: isDark
                ? [const Color(0xFF0F2027), const Color(0xFF2C5364)] 
                : [const Color(0xFFFFFFFF), const Color(0xFF9BBAFD), const Color(0xFF3573FA)],
            stops: isDark ? null : [0.0, 0.5, 1.0], 
          ),
        ),
        
        // --- PERBAIKAN DI SINI: Tambahkan SingleChildScrollView ---
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  Center(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: dynamicTextColor),
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // Input New Password
                  _buildLabel('New Password', dynamicTextColor),
                  _buildTextField(
                    controller: _newPassController,
                    hint: '***********',
                    isObscure: _isObscure,
                    toggleObscure: () {
                      setState(() => _isObscure = !_isObscure);
                    },
                    showEye: true,
                  ),

                  const SizedBox(height: 16),

                  // Input Confirm Password
                  _buildLabel('Confirm New Password', dynamicTextColor),
                  _buildTextField(
                    controller: _confirmPassController,
                    hint: '***********',
                    isObscure: true, // Selalu hidden untuk confirm
                    showEye: false,
                  ),

                  const SizedBox(height: 30),

                  // BUTTON FINISH
                  ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      // Ambil arguments dengan lebih aman
                      final Object? arguments = ModalRoute.of(context)!.settings.arguments;
                      
                      if (arguments is! Map) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid data received')),
                        );
                        return;
                      }

                      final String email = arguments['email'] ?? '';
                      final String otp = arguments['otp'] ?? '';

                      // Validasi input
                      if (_newPassController.text.isEmpty || _confirmPassController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
                        );
                        return;
                      }

                      if (_newPassController.text != _confirmPassController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        final response = await http.post(
                          Uri.parse('http://10.0.2.2:8080/api/reset-password'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'email': email,
                            'otp': otp,
                            'new_password': _newPassController.text,
                          }),
                        );

                        if (!mounted) return;
                        setState(() => _isLoading = false);

                        if (response.statusCode == 200) {
                          // Berhasil! Bersihkan stack dan balik ke login
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully! Please login.'), 
                              backgroundColor: Colors.green
                            ),
                          );
                        } else {
                          final errorData = jsonDecode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorData['error'] ?? 'Failed to reset password'), 
                              backgroundColor: Colors.red
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connection error to server'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    // Tambahkan feedback loading di sini
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text('Finish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  
                  // Tambahan padding bawah agar aman saat discroll mentok bawah
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isObscure,
    required bool showEye,
    VoidCallback? toggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        suffixIcon: showEye
            ? IconButton(
                icon: Icon(isObscure ? Icons.visibility_off : Icons.remove_red_eye_outlined),
                color: Colors.black,
                onPressed: toggleObscure,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
      ),
    );
  }
}