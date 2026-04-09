import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart'; // Pastikan path ini benar sesuai struktur project Anda
import 'widgets/service_card.dart';        // Pastikan path ini benar
import '../../../services/api_service.dart'; // Pastikan path ini benar

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  // Variabel untuk menyimpan pesan saran AI
  String? _aiMessage;

  @override
  void initState() {
    super.initState();
    // Otomatis fokus ke keyboard saat halaman dibuka
  }

  void _doSearch(String query) async {
    if (query.isEmpty) return;
    
    // Sembunyikan keyboard setelah enter ditekan (Opsional, agar lebih rapi)
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _aiMessage = null; // Reset pesan lama setiap kali cari baru
      _searchResults = []; // Kosongkan hasil lama
    });
    
    try {
      // 1. Panggil API (Return-nya sekarang adalah Map/Paket)
      final response = await ApiService.searchServices(query);
      
      if (!mounted) return; // Cek apakah widget masih aktif sebelum setState

      setState(() {
        // 2. Ambil List Hasil dari dalam paket 'results'
        _searchResults = response['results'];
        
        // 3. Ambil Pesan AI dari dalam paket 'message' (Bisa null, bisa ada isinya)
        _aiMessage = response['message'];
        
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Tampilkan error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER SEARCH (Putih Bersih) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true, // Langsung muncul keyboard
                      textInputAction: TextInputAction.search,
                      onSubmitted: _doSearch,
                      decoration: InputDecoration(
                        hintText: 'Cari jasa (misal: cuci ac)',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search, color: kPrimaryBlue),
                          onPressed: () => _doSearch(_searchController.text),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- AREA SARAN AI (SMART SUGGESTION) ---
            // Hanya muncul jika _aiMessage TIDAK NULL (ada isinya)
            if (_aiMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.amber.shade50, // Warna kuning muda (khas alert/saran)
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _aiMessage!, // Tampilkan pesan dari Python
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          height: 1.4, // Jarak antar baris agar mudah dibaca
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // --- HASIL PENCARIAN ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryBlue))
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                "Belum ada hasil pencarian", 
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            
                            // MAPPING SESUAI DATABASE PYTHON
                            // Kita pakai operator ?? untuk handle nilai null agar tidak error
                            return ServiceCard(
                              title: item['NamaJasa'] ?? 'Tanpa Nama',
                              specialty: item['Kategori'] ?? 'Umum',
                              // Format harga: Rp 50000 -> Rp 5.000.000 (ideally pakai formatter, ini basic)
                              price: item['HargaMulai'] != null 
                                  ? 'Rp ${item['HargaMulai']}' 
                                  : 'Hubungi Kami',
                              rating: item['RatingRataRata']?.toString() ?? '0.0',
                              isOpen: true,
                              imageUrl: 'https://loremflickr.com/320/240/technician?lock=$index',
                              onTap: () {
                               Navigator.pushNamed(context, '/service_detail');
                              }, 
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}