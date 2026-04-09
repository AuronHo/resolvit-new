import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/auth_controller.dart';
import '../../main_navigation/logic/theme_controller.dart'; 
import '../../../constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // Validasi Form
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Panggil fungsi login di controller (Kita akan buat fungsi ini nanti)
      // Untuk sekarang simulasi sukses saja
      final authController = context.read<AuthController>();
      final bool success = await authController.loginUser(
        _emailController.text, 
        _passwordController.text
      ); 

      if (!mounted) return;

      if (success) {
       // Jika berhasil, langsung lempar ke Home
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Berhasil!'), backgroundColor: Colors.green),
        );
      } else {
        // Jika gagal (misal password salah)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email atau Password salah!'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    // Warna elemen
    final Color dynamicTextColor = isDark ? Colors.white : Colors.black;
    final Color dynamicInputFill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    const Color buttonColor = Color(0xFF4981FB); // Warna biru tombol

    return Scaffold(
      extendBodyBehindAppBar: true, // Agar gradient sampai ke atas status bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: dynamicTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Log In',
          style: TextStyle(color: dynamicTextColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        
        // --- GRADIENT BACKGROUND (SAMA SEPERTI CREATE ACCOUNT) ---
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // --- EMAIL / PHONE ---
                  _buildLabel('Email/Phone', dynamicTextColor),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Enter your email or phone',
                    fillColor: dynamicInputFill,
                    textColor: dynamicTextColor,
                  ),

                  const SizedBox(height: 20),

                  // --- PASSWORD ---
                  _buildLabel('Password', dynamicTextColor),
                  _buildTextField(
                    controller: _passwordController,
                    hint: '••••••••',
                    fillColor: dynamicInputFill,
                    textColor: dynamicTextColor,
                    obscureText: !authController.isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => context.read<AuthController>().togglePasswordVisibility(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- FORGOT PASSWORD ---
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/reset_password');
                      },
                      child: const Text(
                        'Forgot your password?',
                        style: TextStyle(
                          color: Color(0xFF3573FA), // Biru Link
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- LOG IN BUTTON ---
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Log In',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Color fillColor,
    required Color textColor,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: textColor),
      validator: (value) {
        if (value == null || value.isEmpty) return 'This field is required';
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none, 
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
    );
  }
}