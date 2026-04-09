import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import 'widgets/service_card.dart';

class CategoryListScreen extends StatelessWidget {
  // Menerima judul kategori yang diklik
  final String categoryTitle;

  const CategoryListScreen({super.key, required this.categoryTitle});

  // --- GUNAKAN DATA DUMMY YANG SAMA ---
  final List<Map<String, dynamic>> _services = const [
    {
      'title': 'Buana Phone Service',
      'specialty': 'Speciality in phone service',
      'price': 'Rp 50.000',
      'rating': '5',
      'isOpen': true,
      'image': 'https://loremflickr.com/320/240/computer?random=10'
    },
    {
      'title': 'Mitra Komputer',
      'specialty': 'Laptop & PC Repair',
      'price': 'Rp 75.000',
      'rating': '4.8',
      'isOpen': true,
      'image': 'https://loremflickr.com/320/240/phone?random=11'
    },
    {
      'title': 'Jasa Web Kilat',
      'specialty': 'Web Development',
      'price': 'Rp 500.000',
      'rating': '4.9',
      'isOpen': false,
      'image': 'https://loremflickr.com/320/240/phone?random=12'
    },
    // ... tambahkan data dummy lainnya jika perlu
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // --- HEADER SECTION (BIRU DENGAN TOMBOL KEMBALI) ---
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
                // Tombol Kembali (Putih)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                // Search Bar
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      // Menggunakan judul kategori sebagai hint text
                      hintText: 'Search in $categoryTitle',
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

          // --- LIST OF SERVICES ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final item = _services[index];
                return ServiceCard(
                  title: item['title'],
                  specialty: item['specialty'],
                  price: item['price'],
                  rating: item['rating'],
                  isOpen: item['isOpen'],
                  imageUrl: 'https://loremflickr.com/320/240/technician?lock=$index',
                  onTap: () => Navigator.pushNamed(context, '/service_detail'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}