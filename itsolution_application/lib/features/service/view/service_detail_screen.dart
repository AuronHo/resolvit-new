import 'package:flutter/material.dart';
import 'view_details_screen.dart';
import '../../main_navigation/view/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../main_navigation/logic/navigation_controller.dart';
import '../../chat/view/chat_detail_screen.dart';
import '../../../services/api_service.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  String _selectedFilter = 'All';

  Map<String, dynamic> _service = {};
  List<dynamic> _reviews = [];
  bool _reviewsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _currentIndex) {
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_service.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _service = args;
        _loadReviews();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    final jasaId = _service['JasaID'];
    if (jasaId == null) {
      setState(() => _reviewsLoading = false);
      return;
    }
    try {
      final data = await ApiService.getReviews(jasaId);
      if (mounted) {
        setState(() {
          _reviews = data['results'] ?? [];
          _reviewsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _reviewsLoading = false);
    }
  }

  Future<void> _openChat() async {
    final currentUserId = await ApiService.getCurrentUserId();
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please login first'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final providerId = _service['ProviderID'] ?? 0;
    if (providerId == 0) return;

    try {
      final data = await ApiService.getOrCreateChatRoom(
        customerId: currentUserId,
        providerId: providerId,
        jasaId: _service['JasaID'] ?? 0,
        jasaName: _service['NamaJasa'] ?? '',
      );
      final room = data['room'];
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              roomId: room['id'],
              partnerName: _service['NamaJasa'] ?? 'Provider',
              currentUserId: currentUserId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open chat: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<dynamic> get _filteredReviews {
    if (_selectedFilter == 'All') return _reviews;
    final filterRating = int.tryParse(_selectedFilter) ?? 0;
    return _reviews.where((r) => r['rating'] == filterRating).toList();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF3573FA);
    final serviceName = _service['NamaJasa'] ?? 'Service Detail';
    final rating = _service['RatingRataRata']?.toString() ?? '0.0';
    final price = _service['HargaMulai'] != null
        ? 'Rp ${_service['HargaMulai']}'
        : 'Hubungi Kami';
    final kategori = _service['Kategori'] ?? '';
    final imageUrl = _service['ImageUrl'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: brandBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          serviceName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/saved'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER BANNER + CARD ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: brandBlue,
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 100, 20, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5)),
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
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl.isEmpty
                                ? const Icon(Icons.business, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(serviceName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Text(rating,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                ]),
                                const SizedBox(height: 4),
                                Text(kategori,
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                Text('Price start from $price',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  _service['IsOpen'] == true
                                      ? 'Open (08:00 - 22:00)'
                                      : 'Closed',
                                  style: TextStyle(
                                    color: _service['IsOpen'] == true
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
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
                              onPressed: _openChat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4981FB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('Chat Now'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ViewDetailsScreen()),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4981FB),
                                side: const BorderSide(
                                    color: Color(0xFF4981FB)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
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
                tabs: const [Tab(text: 'Portofolio'), Tab(text: 'Review')],
              ),
            ),

            if (_currentIndex == 0)
              _buildPortfolioContent()
            else
              _buildReviewContent(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 0,
        onTap: (index) {
          context.read<NavigationController>().setIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ===========================================================================
  Widget _buildReviewContent() {
    if (_reviewsLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final displayReviews = _filteredReviews;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sort by',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('5', icon: Icons.star),
                const SizedBox(width: 8),
                _buildFilterChip('4', icon: Icons.star),
                const SizedBox(width: 8),
                _buildFilterChip('3', icon: Icons.star),
                const SizedBox(width: 8),
                _buildFilterChip('2', icon: Icons.star),
                const SizedBox(width: 8),
                _buildFilterChip('1', icon: Icons.star),
              ],
            ),
          ),
          const Divider(height: 30),
          if (displayReviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Belum ada review.')),
            )
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

  Widget _buildFilterChip(String label, {IconData? icon}) {
    final bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF3573FA).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF3573FA) : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: isActive ? const Color(0xFF3573FA) : Colors.black,
                    fontWeight: FontWeight.bold)),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: Colors.amber),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final name = review['user_name']?.toString() ?? 'User';
    final avatar = review['user_avatar']?.toString() ?? '';
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = review['comment']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty
                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Icon(Icons.more_vert, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
            (i) => Icon(Icons.star,
                color: i < rating ? Colors.amber : Colors.grey.shade300,
                size: 20),
          ),
        ),
        const SizedBox(height: 8),
        Text(comment, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildPortfolioContent() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        final serviceName = _service['NamaJasa'] ?? 'Service';
        return Container(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        _service['ImageUrl']?.isNotEmpty == true
                            ? NetworkImage(_service['ImageUrl'])
                            : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(serviceName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        Text(index == 0 ? '1d' : '2d',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              Text(index == 0
                  ? 'Professional work'
                  : 'Hubungi kami untuk konsultasi'),
              const SizedBox(height: 10),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://loremflickr.com/400/200/technician,repair?lock=$index'),
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
