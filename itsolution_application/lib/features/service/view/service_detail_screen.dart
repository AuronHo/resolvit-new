import 'package:flutter/material.dart';
import 'view_details_screen.dart';
import '../../main_navigation/view/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart'; 
import '../../main_navigation/logic/navigation_controller.dart';
import '../../chat/view/chat_detail_screen.dart'; 

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  
  // --- 1. STATE UNTUK FILTER ---
  String _selectedFilter = 'All'; // Default pilih 'All'

  // --- 2. DATA DUMMY REVIEW YANG BANYAK ---
  final List<Map<String, dynamic>> _allReviews = [
    {
      'name': 'Sule',
      'time': '1d',
      'rating': 5,
      'comment': 'Layanannya bgs, murah tp bukan kaleng. Pengerjaan cpt',
      'hasImage': true,
    },
    {
      'name': 'Andi Gaming',
      'time': '2d',
      'rating': 5,
      'comment': 'Sangat puas! HP saya kembali seperti baru. Recommended banget.',
      'hasImage': false,
    },
    {
      'name': 'Budi Santoso',
      'time': '3d',
      'rating': 4,
      'comment': 'Pelayanan ramah, cuma antrian agak panjang kemarin.',
      'hasImage': false,
    },
    {
      'name': 'Citra Lestari',
      'time': '1w',
      'rating': 3,
      'comment': 'Hasil perbaikan oke, tapi harganya sedikit lebih mahal dari toko sebelah.',
      'hasImage': true,
    },
    {
      'name': 'Dodi Kurnia',
      'time': '1w',
      'rating': 5,
      'comment': 'Teknisinya jago, masalah LCD pecah kelar dalam 2 jam.',
      'hasImage': false,
    },
    {
      'name': 'Eko Purnomo',
      'time': '2w',
      'rating': 2,
      'comment': 'Kurang puas, casingnya jadi agak renggang setelah diservis.',
      'hasImage': false,
    },
    {
      'name': 'Fani Rose',
      'time': '3w',
      'rating': 1,
      'comment': 'Lama banget pengerjaannya, janji 1 hari jadi 3 hari.',
      'hasImage': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- LOGIKA FILTER ---
  List<Map<String, dynamic>> get _filteredReviews {
    if (_selectedFilter == 'All') {
      return _allReviews;
    } else {
      // Filter berdasarkan angka rating (misal: rating == 5)
      int filterRating = int.parse(_selectedFilter);
      return _allReviews.where((review) => review['rating'] == filterRating).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF3573FA); 

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: brandBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buana Phone Service',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/saved');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER (BANNER + CARD) ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3573FA), // Warna cadangan saat loading
                    image: DecorationImage(
                      // Ganti URL ini dengan foto toko/sampul yang diinginkan
                      image: NetworkImage('https://loremflickr.com/640/360/store,shop?lock=cover'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 0.3, 
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black, 
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 100, 20, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: const NetworkImage('https://loremflickr.com/200/200/mobile,phone,logo?lock=buana'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Buana Phone Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Text('5', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Icon(Icons.star, color: Colors.amber, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Speciality in phone service', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                Text('Price start from Rp 50.000', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                const SizedBox(height: 4),
                                const Text('Open (08:00 - 22:00)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ChatDetailScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4981FB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('Chat Now'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewDetailsScreen()));
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4981FB),
                                side: const BorderSide(color: Color(0xFF4981FB)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('View Details'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- TAB BAR ---
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: brandBlue,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Portofolio'),
                  Tab(text: 'Review'),
                ],
              ),
            ),

            // --- ISI KONTEN ---
            if (_currentIndex == 0) _buildPortfolioContent() else _buildReviewContent(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      
      // --- BOTTOM BAR ---
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 0,
        onTap: (index) {
         context.read<NavigationController>().setIndex(index);

         Navigator.pop(context);
        },
      )
    );
  }

  // ===========================================================================
  // --- KONTEN REVIEW (DENGAN LOGIKA FILTER) ---
  // ===========================================================================
  Widget _buildReviewContent() {
    final displayReviews = _filteredReviews; // Ambil hasil filter

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sort by", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),

          // --- FILTER CHIPS YANG BISA DIKLIK ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("All"),
                const SizedBox(width: 8),
                _buildFilterChip("5", icon: Icons.star),
                const SizedBox(width: 8),
                _buildFilterChip("4", icon: Icons.star),
                const SizedBox(width: 8),
                _buildFilterChip("3", icon: Icons.star),
                const SizedBox(width: 8),
                _buildFilterChip("2", icon: Icons.star),
                const SizedBox(width: 8),
                _buildFilterChip("1", icon: Icons.star),
              ],
            ),
          ),
          
          const Divider(height: 30),

          // --- LIST REVIEW DINAMIS ---
          if (displayReviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("Belum ada review untuk rating ini.")),
            )
          else
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayReviews.length,
              itemBuilder: (context, index) {
                final review = displayReviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildReviewItem(review), // Kirim data review ke widget
                );
              },
            ),
        ],
      ),
    );
  }

  // Widget Chip yang Interaktif
  Widget _buildFilterChip(String label, {IconData? icon}) {
    final bool isActive = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label; // Ubah state saat diklik
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3573FA).withOpacity(0.1) : Colors.white, // Biru muda jika aktif
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF3573FA) : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF3573FA) : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: Colors.amber),
            ]
          ],
        ),
      ),
    );
  }

  // Widget Item Review Dinamis
  Widget _buildReviewItem(Map<String, dynamic> review) {

    final String cleanName = review['name'].toString().replaceAll(' ', '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              // Placeholder gambar user acak
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${review['name']}'), 
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(text: "${review['name']} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: review['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const Icon(Icons.more_vert, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),

        // Bintang Rating Dinamis
        Row(
          children: List.generate(5, (index) {
            return Icon(
              Icons.star, 
              // Warna kuning jika index kurang dari rating, abu jika lebih
              color: index < review['rating'] ? Colors.amber : Colors.grey.shade300, 
              size: 20
            );
          }),
        ),
        const SizedBox(height: 8),

        // Komentar
        Text(
          review['comment'],
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),

        // Gambar Bukti (Jika ada)
        if (review['hasImage'] == true)
          Container(
            height: 180,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: DecorationImage(
                image: NetworkImage('https://loremflickr.com/300/400/broken,phone?random=$cleanName'),
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  // --- KONTEN PORTOFOLIO (TETAP) ---
  Widget _buildPortfolioContent() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        final String time = index == 0 ? '1d' : '2d';
        final String caption = index == 0 ? 'Professional work' : 'HP rusak? Konsul disini aja duluh';
        final String portfolioImage = 'https://loremflickr.com/400/200/technician,repair?lock=$index';
        return Container(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage: const NetworkImage('https://loremflickr.com/200/200/mobile,phone,logo?lock=buana'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Buana Phone Service', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              Text(caption),
              const SizedBox(height: 10),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(portfolioImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}