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
      final response = await ApiService.getSavedServices(userId: 1);
      _savedList = response['results'] ?? [];
    } catch (e) {
      print("Provider Error: $e");
    }
    _isLoading = false;
    notifyListeners(); // Beritahu semua layar untuk update tampilan
  }
}