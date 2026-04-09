import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _isBusinessProfile = false; // <--- TAMBAHKAN INI

  int get selectedIndex => _selectedIndex;
  bool get isBusinessProfile => _isBusinessProfile; // <--- GETTER

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // --- FUNGSI BARU UNTUK GANTI TIPE AKUN ---
  void setBusinessProfile(bool value) {
    _isBusinessProfile = value;
    // Otomatis pindah ke tab Profile (index 3) saat ganti akun
    _selectedIndex = 3; 
    notifyListeners();
  }
}