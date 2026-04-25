import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import 'widgets/service_card.dart';
import '../../../services/api_service.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String? _categoryTitle;
  
  // State untuk Pagination
  final List<dynamic> _services = [];
  int _currentPage = 1;
  bool _isLoading = true; // Loading awal
  bool _isFetchingMore = false; // Loading saat scroll ke bawah
  bool _hasMoreData = true; // Cek apakah data sudah habis

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Dengarkan saat user scroll ke bawah
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _fetchMoreServices();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_categoryTitle == null) {
      _categoryTitle = ModalRoute.of(context)!.settings.arguments as String;
      _fetchInitialServices();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Tarik data halaman pertama (10 data)
  Future<void> _fetchInitialServices() async {
    try {
      final response = await ApiService.getServicesByCategory(_categoryTitle!, page: 1);
      if (!mounted) return;

      final newItems = response['results'] ?? [];
      setState(() {
        _services.addAll(newItems);
        _isLoading = false;
        _hasMoreData = newItems.length == 10; // Jika < 10, berarti data sudah habis
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Tarik data selanjutnya saat di-scroll
  Future<void> _fetchMoreServices() async {
    if (_isFetchingMore || !_hasMoreData) return;

    setState(() => _isFetchingMore = true);
    _currentPage++;

    try {
      final response = await ApiService.getServicesByCategory(_categoryTitle!, page: _currentPage);
      if (!mounted) return;

      final newItems = response['results'] ?? [];
      setState(() {
        _services.addAll(newItems);
        _isFetchingMore = false;
        _hasMoreData = newItems.length == 10;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFetchingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // --- HEADER SECTION (TIDAK BERUBAH) ---
          Container(
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8AA8F8), kPrimaryBlue],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search in ${_categoryTitle ?? 'Category'}',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      suffixIcon: const Icon(Icons.search, color: kPrimaryBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- LIST OF SERVICES DENGAN INFINITE SCROLL ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimaryBlue))
                : _services.isEmpty
                    ? const Center(child: Text('Belum ada jasa di kategori ini.'))
                    : ListView.builder(
                        controller: _scrollController, // Pasang Controller di sini
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        itemCount: _services.length + (_hasMoreData ? 1 : 0), // Tambah 1 untuk loading spinner di bawah
                        itemBuilder: (context, index) {
                          
                          // Jika sampai di index terakhir dan masih ada data, tampilkan loading kecil
                          if (index == _services.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: CircularProgressIndicator(color: kPrimaryBlue)),
                            );
                          }

                          final item = _services[index];
                          
                          // RANDOM FOTO CERDAS: Gunakan ID agar gambarnya konsisten
                          final randomId = item['JasaID'] ?? index;
                          final String randomImageUrl = 'https://loremflickr.com/320/240/technician,computer?random=$randomId';

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            child: ServiceCard(
                              jasaId: item['JasaID'],
                              initialIsSaved: item['IsBookmarked'] == true,
                              title: item['NamaJasa'] ?? 'Jasa Tanpa Nama',
                              specialty: item['Kategori'] ?? 'Umum',
                              price: item['HargaMulai'] != null ? 'Rp ${item['HargaMulai']}' : 'Hubungi Kami',
                              rating: item['RatingRataRata']?.toString() ?? '0.0',
                              isOpen: item['IsOpen'] ?? true,
                              imageUrl: item['ImageUrl'] ?? randomImageUrl,
                              onTap: () => Navigator.pushNamed(context, '/service_detail'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}