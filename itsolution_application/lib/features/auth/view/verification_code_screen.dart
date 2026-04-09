import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../../main_navigation/logic/theme_controller.dart'; 


class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  bool _isVerifying = false;
  // Logic Timer Resend
  int _secondsRemaining = 60; 
  Timer? _timer;
  bool _canResend = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Mulai hitung mundur saat layar dibuka
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ambil email dari arguments untuk digunakan saat resend
    _userEmail ??= ModalRoute.of(context)!.settings.arguments as String;
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Pastikan timer dimatikan saat pindah screen
    // ... sisa dispose controller & nodes kamu ...
    super.dispose();
  }

  Future<void> _resendCode() async {
    if (_userEmail == null) return;
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _userEmail}),
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New OTP code sent!'), backgroundColor: Colors.green),
        );
        _startTimer(); // Reset timer ke 60 detik lagi
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to resend code'), backgroundColor: Colors.red),
      );
    }
  }

  // Controller untuk 6 kotak
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  
  // FocusNode untuk mengatur perpindahan fokus keyboard
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  // @override
  // void dispose() {
  //   for (var controller in _controllers) {
  //     controller.dispose();
  //   }
  //   for (var node in _focusNodes) {
  //     node.dispose();
  //   }
  //   super.dispose();
  // }

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
                : [
                    const Color(0xFFFFFFFF), 
                    const Color(0xFF9BBAFD), 
                    const Color(0xFF3573FA), 
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Code',
                      style: TextStyle(fontWeight: FontWeight.bold, color: dynamicTextColor),
                    ),
                    TextButton(
                      onPressed: _canResend ? _resendCode : null,
                      child: Text(
                        _canResend ? 'Resend code' : 'Resend in ${_secondsRemaining}s',
                        style: TextStyle(color: _canResend ? const Color(0xFF3573FA) : Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                
                // --- 5 KOTAK KODE (FIXED) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 45,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index], // Pasang FocusNode
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        // Pastikan warna teks HITAM agar terlihat di kotak putih
                        style: const TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.black
                        ),
                        decoration: const InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          // --- INI PERBAIKANNYA ---
                          // Mengatur padding vertikal agar angka pas di tengah
                          contentPadding: EdgeInsets.symmetric(vertical: 12), 
                        ),
                        onChanged: (value) {
                          // Logic Pindah Fokus Otomatis
                          if (value.isNotEmpty) {
                            // Jika sudah diisi, pindah ke kotak berikutnya
                            if (index < 5) {
                              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                            } else {
                              // Jika kotak terakhir, hilangkan keyboard
                              FocusScope.of(context).unfocus();
                            }
                          } else if (value.isEmpty) {
                            // Jika dihapus, mundur ke kotak sebelumnya
                            if (index > 0) {
                              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                            }
                          }
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),
                Text(
                  'Enter the code that we sent',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isVerifying ? null : () async {
                    // 1. Ambil email yang dioper dari layar sebelumnya
                    final String email = ModalRoute.of(context)!.settings.arguments as String;

                    // 2. Gabungkan 6 angka dari controller
                    String otpCode = _controllers.map((controller) => controller.text).join();

                    if (otpCode.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter the full 6-digit code')),
                      );
                      return;
                    }

                    setState(() => _isVerifying = true);

                    try {
                      // 3. Panggil API Verifikasi ke Golang (Endpoint baru yang kita bahas tadi)
                      final response = await http.post(
                        Uri.parse('http://10.0.2.2:8080/api/verify-otp'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'email': email,
                          'otp': otpCode,
                        }),
                      );

                      if (!mounted) return;
                      setState(() => _isVerifying = false);

                      if (response.statusCode == 200) {
                        // JIKA OTP BENAR -> Pindah ke layar Password Baru
                        Navigator.pushNamed(
                          context, 
                          '/new_password',
                          arguments: {
                            'email': email,
                            'otp': otpCode,
                          },
                        );
                      } else {
                        // JIKA OTP SALAH -> Munculkan SnackBar Merah
                        final errorData = jsonDecode(response.body);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorData['error'] ?? 'Invalid OTP code'), 
                            backgroundColor: Colors.red
                          ),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _isVerifying = false);
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
                  child: _isVerifying 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}