import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_colors.dart';
import '../../main_navigation/logic/theme_controller.dart';
import '../../../services/api_service.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  static final _googleSignIn = GoogleSignIn(
    serverClientId: '182895082816-40v8uokf08824576b5gh409m07kenoev.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/auth/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': googleUser.displayName ?? googleUser.email,
          'email': googleUser.email,
          'avatar_url': googleUser.photoUrl ?? '',
        }),
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final String? jwtToken = responseBody['token'];
        final userId = responseBody['user'] != null
            ? responseBody['user']['id']
            : responseBody['user_id'];

        if (jwtToken == null || userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Server error. Try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', jwtToken);
        await prefs.setInt(
          'currentUserId',
          userId is int ? userId : (userId as num).toInt(),
        );

        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selamat Datang di Resolv IT!')),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed. Try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                          _handleGoogleSignIn(context); // Google Sign In Logic
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Sign Up'),
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
