import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/auth_controller.dart';
import '../../main_navigation/logic/theme_controller.dart'; 
import '../../../constants/app_colors.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleRegistration() async {
    final authController = context.read<AuthController>();

    if (!_formKey.currentState!.validate()) return;
    if (!authController.agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept Terms & Conditions'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    authController.nameController.text = _nameController.text;
    authController.emailController.text = _emailPhoneController.text;
    authController.passwordController.text = _passwordController.text;

    final String? error = await authController.registerUser();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return;
    }

    if (error == 'email_already_registered') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Email already registered'),
          content: const Text('This email is already linked to an account. Would you like to sign in instead?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4981FB)),
              child: const Text('Sign In', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    // Warna untuk mode terang (Light Mode)
    const Color signUpButtonColor = Color(0xFF4981FB);

    // Tentukan warna teks/elemen berdasarkan tema
    // Karena gradient light mode bagian atasnya PUTIH, maka elemen harus HITAM agar terlihat.
    final Color dynamicTextColor = isDark ? Colors.white : Colors.black;
    final Color dynamicInputFill = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Icon Back Hitam (di Light Mode) agar terlihat di background putih
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: dynamicTextColor), 
          onPressed: () => Navigator.pop(context),
        ),
        // Judul Hitam (di Light Mode)
        title: Text(
          'Create Account', 
          style: TextStyle(color: dynamicTextColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        
        // --- UPDATE GRADIENT DI SINI ---
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: isDark
                // Gradient Dark Mode (Tetap gelap agar nyaman di mata)
                ? [const Color(0xFF0F2027), const Color(0xFF2C5364)] 
                // Gradient Light Mode (Sesuai Request)
                : [
                    const Color(0xFFFFFFFF), // 0% - Putih
                    const Color(0xFF9BBAFD), // 50% - Biru Muda
                    const Color(0xFF3573FA), // 100% - Biru Utama
                  ],
            // Stops mengatur posisi warna (0.0 = 0%, 0.5 = 50%, 1.0 = 100%)
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

                  // --- FORM FIELDS ---
                  _buildLabel('Name', dynamicTextColor),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Sule',
                    fillColor: dynamicInputFill,
                    textColor: dynamicTextColor,
                  ),

                  const SizedBox(height: 16),

                  _buildLabel('Email/Phone', dynamicTextColor),
                  _buildTextField(
                    controller: _emailPhoneController,
                    hint: 'sule123@gmail.com',
                    fillColor: dynamicInputFill,
                    textColor: dynamicTextColor,
                  ),

                  const SizedBox(height: 16),

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
                    validator: (value) {
                      if (value == null || value.length < 6) return 'Password must be at least 6 chars';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildLabel('Confirm Password', dynamicTextColor),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: '••••••••',
                    fillColor: dynamicInputFill,
                    textColor: dynamicTextColor,
                    obscureText: true,
                    validator: (val) {
                      if (val != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // --- CHECKBOX ---
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: authController.agreedToTerms,
                          side: BorderSide(color: dynamicTextColor, width: 2), 
                          checkColor: isDark ? Colors.black : Colors.white,
                          // Saat dicentang, kotak jadi Hitam (di light mode) sesuai request sebelumnya
                          // atau Biru jika ingin sesuai tema. Di sini saya pakai Hitam sesuai request label.
                          activeColor: Colors.black, 
                          onChanged: (val) => context.read<AuthController>().setAgreedToTerms(val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Accept ',
                            style: TextStyle(color: dynamicTextColor),
                            children: [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: const TextStyle(
                                  color: kPrimaryBlue, // Link tetap Biru
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => context.read<AuthController>().launchTermsUrl(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- SIGN UP BUTTON ---
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: signUpButtonColor, // #4981FB
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
                            'Sign up',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 40),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: textColor),
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