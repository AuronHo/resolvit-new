import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main_navigation/logic/navigation_controller.dart';
import '../../main_navigation/view/widgets/custom_bottom_nav_bar.dart';
import 'business_view_details_screen.dart'; // Ensure this file exists

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  String _selectedFilter = 'All';

  // --- DUMMY DATA ---
  final List<Map<String, dynamic>> _allReviews = [
    {'name': 'Sule', 'time': '1d', 'rating': 5, 'comment': 'Layanannya bgs, murah.', 'hasImage': true},
    {'name': 'Andi', 'time': '2d', 'rating': 5, 'comment': 'Sangat puas!', 'hasImage': false},
    {'name': 'Budi', 'time': '3d', 'rating': 4, 'comment': 'Pelayanan ramah.', 'hasImage': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listener to update UI when tab changes
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

  // Logic to filter reviews
  List<Map<String, dynamic>> get _filteredReviews {
    if (_selectedFilter == 'All') return _allReviews;
    int filterRating = int.parse(_selectedFilter);
    return _allReviews.where((review) => review['rating'] == filterRating).toList();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      
      // --- 1. HEADER (APP BAR) ---
      appBar: AppBar(
        backgroundColor: brandBlue,
        elevation: 0,
        automaticallyImplyLeading: false, // Owner view doesn't usually need back button here
        title: const Text(
          'Cepatlulus Web Service',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Settings Icon (Gear)
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 2. HEADER CARD STACK ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: brandBlue,
                    image: DecorationImage(
                      image: NetworkImage('https://loremflickr.com/640/360/office,technology?lock=banner'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 0.3,
                        child: Container(color: Colors.black), // Placeholder for banner image
                      ),
                    ],
                  ),
                ),
                
                // Floating Info Card
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
                            // Owner's Avatar
                            backgroundImage: const NetworkImage('https://loremflickr.com/200/200/logo,website?lock=profile'), 
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cepatlulus Web Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Text('5', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Icon(Icons.star, color: Colors.amber, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Speciality in Website', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                Text('Price start from Rp 100.000!', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                const SizedBox(height: 4),
                                const Text('Open (08:00 - 22:00)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // --- VIEW DETAILS BUTTON (Full Width) ---
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigate to the "Business View Details" screen we made earlier
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const BusinessViewDetailsScreen())
                            );
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
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- 3. TAB BAR ---
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

            // --- 4. CONTENT SWITCHER ---
            if (_currentIndex == 0) 
              _buildPortfolioContent() 
            else 
              _buildReviewContent(),

            const SizedBox(height: 100), // Padding for bottom bar
          ],
        ),
      ),

      // --- 5. FLOATING ACTION BUTTON (Add Post) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_post');
        },
        backgroundColor: const Color(0xFF4981FB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      // --- 6. BOTTOM BAR ---
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 3, // Profile Tab
        onTap: (index) {
          context.read<NavigationController>().setIndex(index);
          // Go back to main home shell if switching tabs
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        },
      ),
    );
  }

  // ===========================================================================
  // --- HELPER WIDGETS (Defined INSIDE the class to avoid lookup errors) ---
  // ===========================================================================

  // 1. Portfolio Content Helper
  Widget _buildPortfolioContent() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        final String portfolioImage = 'https://loremflickr.com/400/200/website,coding?lock=$index';
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
                    // Owner Avatar
                    backgroundImage: NetworkImage('https://loremflickr.com/200/200/logo,website?lock=profile'),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cepatlulus Web Service', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('1d', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Website for Kantin UIB'),
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

  // 2. Review Content Helper
  Widget _buildReviewContent() {
    final displayReviews = _filteredReviews;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sort by", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("All"), const SizedBox(width: 8),
                _buildFilterChip("5", icon: Icons.star), const SizedBox(width: 8),
                _buildFilterChip("4", icon: Icons.star),
              ],
            ),
          ),
          const Divider(height: 30),
          if (displayReviews.isEmpty)
            const Center(child: Text("No reviews."))
          else
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayReviews.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: _buildReviewItem(displayReviews[index]),
              ),
            ),
        ],
      ),
    );
  }

  // 3. Filter Chip Helper
  Widget _buildFilterChip(String label, {IconData? icon}) {
    final bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3573FA).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? const Color(0xFF3573FA) : Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: isActive ? const Color(0xFF3573FA) : Colors.black, fontWeight: FontWeight.bold)),
            if (icon != null) ...[const SizedBox(width: 4), Icon(icon, size: 16, color: Colors.amber)],
          ],
        ),
      ),
    );
  }

  // 4. Review Item Helper
  Widget _buildReviewItem(Map<String, dynamic> review) {
    final String cleanName = review['name'].toString().replaceAll(' ', '');
    final String profileImage = 'https://i.pravatar.cc/150?u=$cleanName';
    final String reviewImage = 'https://loremflickr.com/300/400/website,screen?random=$cleanName';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 20, backgroundColor: Colors.grey , backgroundImage: NetworkImage(profileImage),),
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
          ],
        ),
        const SizedBox(height: 8),
        Row(children: List.generate(5, (index) => Icon(Icons.star, color: index < review['rating'] ? Colors.amber : Colors.grey.shade300, size: 20))),
        const SizedBox(height: 8),
        Text(review['comment'], style: const TextStyle(fontSize: 14)),
        if (review['hasImage'] == true) ...[
          const SizedBox(height: 12),
          Container(
            height: 180,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: DecorationImage(
                image: NetworkImage(reviewImage), // Pakai URL di atas
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    );
  }
}