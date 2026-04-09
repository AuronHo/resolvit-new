import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/auth_controller.dart';
// import '../../main_navigation/logic/theme_controller.dart'; // Not needed for white background

class ServiceProviderRegisterScreen extends StatefulWidget {
  const ServiceProviderRegisterScreen({super.key});

  @override
  State<ServiceProviderRegisterScreen> createState() =>
      _ServiceProviderRegisterScreenState();
}

class _ServiceProviderRegisterScreenState
    extends State<ServiceProviderRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _businessNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleRegistration() async {
    final authController = context.read<AuthController>();

    // Simple Validation
    if (_formKey.currentState!.validate() && authController.agreedToTerms) {
      setState(() => _isLoading = true);

      // --- DUMMY LOADING (No Backend) ---
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      setState(() => _isLoading = false);

      // --- NAVIGATE TO SETUP PROFILE ---
      Navigator.pushNamed(context, '/setup_business_profile');
    } else if (!authController.agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept Terms & Conditions'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    // final themeController = context.watch<ThemeController>(); // Not needed
    // final isDark = themeController.isDarkMode; // Not needed

    // Colors for white background style
    const Color brandBlue = Color(0xFF4981FB);
    const Color textColor = Colors.black;
    final Color inputFill = Colors.grey[200]!; // Light grey for inputs

    return Scaffold(
      backgroundColor: Colors.white, // --- SOLID WHITE BACKGROUND ---
      appBar: AppBar(
        backgroundColor: brandBlue, // --- SOLID BLUE HEADER ---
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Service Provider Register',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        // --- ROUNDED BOTTOM CORNERS ---
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Title is now black
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 40),

                // --- FORM FIELDS (Labels are black, Inputs are grey) ---
                _buildLabel('Business Name', textColor),
                _buildTextField(
                  controller: _businessNameController,
                  hint: '',
                  fillColor: inputFill,
                  textColor: textColor,
                ),

                const SizedBox(height: 16),

                _buildLabel('Business Email/Phone', textColor),
                _buildTextField(
                  controller: _businessEmailController,
                  hint: '',
                  fillColor: inputFill,
                  textColor: textColor,
                ),

                const SizedBox(height: 16),

                _buildLabel('Password', textColor),
                _buildTextField(
                  controller: _passwordController,
                  hint: '',
                  fillColor: inputFill,
                  textColor: textColor,
                  obscureText: !authController.isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      authController.isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => context
                        .read<AuthController>()
                        .togglePasswordVisibility(),
                  ),
                ),

                const SizedBox(height: 16),

                _buildLabel('Confirm Password', textColor),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: '',
                  fillColor: inputFill,
                  textColor: textColor,
                  obscureText: true,
                ),

                const SizedBox(height: 24),

                // --- CHECKBOX ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: authController.agreedToTerms,
                        side: const BorderSide(color: textColor, width: 2),
                        checkColor: Colors.white,
                        activeColor: brandBlue,
                        onChanged: (val) => context
                            .read<AuthController>()
                            .setAgreedToTerms(val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: RichText(
                        text: const TextSpan(
                          // Added const for performance
                          text: 'Accept ',
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: Color(0xFF4981FB),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              // Note: You can re-add the recognizer here if needed
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- BUTTON ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
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
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
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
      validator: (value) => value!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        // Blue border when focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF4981FB), width: 2),
        ),
      ),
    );
  }
}
