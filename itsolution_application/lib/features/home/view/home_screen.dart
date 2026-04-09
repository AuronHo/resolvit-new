import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import 'widgets/service_card.dart';
import '../../../services/api_service.dart';
import 'search_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

Future<void> _fetchRecommendations() async {
    try {
      // 1. Panggil API (Sekarang return-nya adalah MAP/Paket)
      final response = await ApiService.searchServices("terbaik"); 
      
      if (!mounted) return;
      
      setState(() {
        // 2. Ambil hanya bagian 'results' dari dalam paket
        _recommendations = response['results']; 
        
        // Catatan: Untuk rekomendasi awal, biasanya kita abaikan 'message' 
        // karena AI suggestion hanya muncul kalau user mengetik pencarian aneh.
        
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // --- HEADER SECTION ---
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SearchPage()),
                          );
                        },
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'find what you need',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                                ),
                              ),
                              const Icon(Icons.search, color: kPrimaryBlue),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton( 
                      icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                      onPressed: () {
                         Navigator.pushNamed(context, '/notification');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 32, color: Colors.white),
                    children: [
                      TextSpan(text: 'Resolv ', style: TextStyle(fontWeight: FontWeight.w300)),
                      TextSpan(text: 'IT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- CONTENT ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),
                
                // --- CATEGORIES ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EFEA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCategoryItem(Icons.phone_android, 'Phone\nService'),
                            _buildCategoryItem(Icons.laptop, 'Laptop/PC\nService'),
                            _buildCategoryItem(Icons.grid_view, 'App Dev'),
                            _buildCategoryItem(Icons.web, 'Web Dev'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCategoryItem(Icons.person, 'IT\nConsultant'),
                            _buildCategoryItem(Icons.cloud_queue, 'Cloud\nService'),
                            _buildCategoryItem(Icons.security, 'Cyber\nConsultant'),
                            _buildCategoryItem(Icons.more_horiz, 'View All'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- RECOMMENDATION TITLE ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Recomendation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                // --- LIST REKOMENDASI (API) ---
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final item = _recommendations[index];
                      return ServiceCard(
                        title: item['NamaJasa'] ?? 'Jasa Tanpa Nama',
                        specialty: item['Kategori'] ?? 'Umum',
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

                const SizedBox(height: 100), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATE DI SINI: NAVIGASI KATEGORI ---
  Widget _buildCategoryItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
         // 1. Bersihkan label (ubah "Phone\nService" jadi "Phone Service")
         final categoryQuery = label.replaceAll('\n', ' ');
         
         // 2. Navigasi ke Category List membawa nama kategorinya
         Navigator.pushNamed(
           context, 
           '/category_list', 
           arguments: categoryQuery
         );
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: Colors.black, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}