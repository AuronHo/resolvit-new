import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main_navigation/logic/theme_controller.dart';
// import '../../../constants/app_colors.dart'; // Import kPrimaryBlue & kGradientTop

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Durasi splash screen (misal 3 detik)
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ambil status Dark Mode
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    // 2. LOGIKA WARNA
    // Warna Dasar Gradient (Bawah): Hitam jika Dark, Putih jika Light
    final Color dynamicGradientBase = isDark ? Colors.black : Colors.white;

    // Warna Teks Logo:
    // Karena background tengah sekarang Putih (di Light mode),
    // Teks harus Biru agar terlihat. Di Dark mode tetap Putih.
    final Color logoColor = isDark ? Colors.white : Colors.white;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // --- GRADIENT YANG SAMA DENGAN CREATE ACCOUNT ---
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: isDark
                ? [const Color(0xFF0F2027), dynamicGradientBase]
                : [
                    const Color(0xFFFFFFFF), // 0% - Putih
                    const Color(0xFF9BBAFD), // 50% - Biru Muda
                    const Color(0xFF3573FA), // 100% - Biru Utama
                  ], // #3573FA -> Putih
            stops: isDark ? null : [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Text "Resolv IT"
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 48,
                    color: logoColor, // <-- Warna berubah otomatis
                    fontFamily: 'Roboto',
                  ),
                  children: const [
                    TextSpan(
                      text: 'Resolv',
                      style: TextStyle(fontWeight: FontWeight.w300), // Tipis
                    ),
                    TextSpan(text: ' '),
                    TextSpan(
                      text: 'IT',
                      style: TextStyle(fontWeight: FontWeight.bold), // Tebal
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
