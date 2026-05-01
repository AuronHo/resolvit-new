import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Sesuaikan path-nya

class BookmarkProvider extends ChangeNotifier {
  List<dynamic> _savedList = [];
  bool _isLoading = true;

  List<dynamic> get savedList => _savedList;
  bool get isLoading => _isLoading;

  // Fungsi untuk menarik data Saved dari database
  Future<void> loadSavedServices() async {
    try {
      // 1. Ambil ID asli dari SharedPreferences
      final currentUserId = await ApiService.getCurrentUserId();
      
      if (currentUserId == null) {
        print("User belum login, kosongkan saved list");
        _savedList = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Gunakan ID asli untuk menarik data
      final response = await ApiService.getSavedServices(userId: currentUserId);
      _savedList = response['data'] ?? response['results'] ?? [];
    } catch (e) {
      print("Provider Error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}