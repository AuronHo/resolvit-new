import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main_navigation/logic/navigation_controller.dart';
import '../../main_navigation/view/widgets/custom_bottom_nav_bar.dart';
import '../../../services/api_service.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  String _selectedFilter = 'All';

  Map<String, dynamic> _service = {};
  Map<String, dynamic> _user = {};
  List<dynamic> _reviews = [];
  List<dynamic> _posts = [];
  bool _isLoading = true;

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
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Use business account ID if linked, otherwise fall back to personal
      final userId =
          await ApiService.getBusinessUserId() ?? await ApiService.getCurrentUserId();
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final userResult = await ApiService.getUserProfile(userId: userId);
      final user = userResult['user'] ?? {};

      Map<String, dynamic> service = {};
      List<dynamic> reviews = [];
      List<dynamic> posts = [];
      try {
        final serviceResult = await ApiService.getMyService(userId);
        service = serviceResult['service'] ?? {};
        if (service['JasaID'] != null) {
          final reviewsResult = await ApiService.getReviews(service['JasaID']);
          reviews = reviewsResult['results'] ?? [];
        }
      } catch (_) {}
      try {
        posts = await ApiService.getPosts(userId);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _user = user;
          _service = service;
          _reviews = reviews;
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredReviews {
    if (_selectedFilter == 'All') return _reviews;
    final filterRating = int.tryParse(_selectedFilter) ?? 0;
    return _reviews.where((r) => r['rating'] == filterRating).toList();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);
    final serviceName = (_service['NamaJasa']?.toString() ?? '').isNotEmpty
        ? _service['NamaJasa'].toString()
        : (_user['name']?.toString() ?? 'My Business');
    final rating =
        ((_service['RatingRataRata'] as num?) ?? 0.0).toStringAsFixed(1);
    final kategori = _service['Kategori']?.toString() ?? '';
    final price = _service['HargaMulai'] != null
        ? 'Rp ${_service['HargaMulai']}'
        : 'Contact us';
    final avatarUrl = _user['avatar_url']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: brandBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          serviceName,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit Profile',
            onPressed: () => Navigator.pushNamed(
                    context, '/edit_business_profile')
                .then((_) => _loadData()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brandBlue))
          : RefreshIndicator(
              color: brandBlue,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // --- HEADER CARD ---
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: brandBlue,
                            image: avatarUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(avatarUrl),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                          child: Container(
                              color: Colors.black.withValues(alpha: 0.3)),
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
                                offset: const Offset(0, 5),
                              ),
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
                                    backgroundImage: avatarUrl.isNotEmpty
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child: avatarUrl.isEmpty
                                        ? const Icon(Icons.business, size: 30)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        if (kategori.isNotEmpty)
                                          Text('Speciality in $kategori',
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12)),
                                        Text('Price start from $price',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12)),
                                        const SizedBox(height: 4),
                                        const Text('Open',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _service.isEmpty
                                      ? null
                                      : () => Navigator.pushNamed(
                                            context,
                                            '/business_view_details',
                                            arguments: _service,
                                          ).then((_) => _loadData()),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: brandBlue,
                                    side:
                                        const BorderSide(color: Color(0xFF4981FB)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                  ),
                                  child: Text(_service.isEmpty
                                      ? 'No service yet — go to Profile to add one'
                                      : 'View Details'),
                                ),
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
                          Tab(text: 'Portfolio'),
                          Tab(text: 'Review'),
                        ],
                      ),
                    ),

                    if (_currentIndex == 0)
                      _buildPortfolioTab()
                    else
                      _buildReviewTab(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final posted = await Navigator.pushNamed(context, '/add_post');
          if (posted == true) _loadData();
        },
        backgroundColor: brandBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 3,
        onTap: (index) {
          context.read<NavigationController>().setIndex(index);
          Navigator.pushNamedAndRemoveUntil(
              context, '/home', (route) => false);
        },
      ),
    );
  }

  Widget _buildPortfolioTab() {
    if (_posts.isEmpty) {
      return Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Text(
            'No portfolio posts yet.\nTap + to add your first post.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: _posts.length,
        itemBuilder: (context, index) => _buildPostCard(_posts[index]),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final imageUrl = post['image_url']?.toString() ?? '';
    final caption = post['caption']?.toString() ?? '';
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl,
                    width: double.infinity, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[300],
                    child: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 32)),
                  ),
          ),
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    final displayReviews = _filteredReviews;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
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
              child: Center(child: Text('No reviews yet.')),
            )
          else
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayReviews.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
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
              ? const Color(0xFF4981FB).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isActive ? const Color(0xFF4981FB) : Colors.grey.shade400,
          ),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: isActive
                        ? const Color(0xFF4981FB)
                        : Colors.black,
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
                    style: const TextStyle(fontWeight: FontWeight.bold))),
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
}
