import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/navigation_controller.dart';
import '../../../../services/api_service.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF4981FB),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(icon: Icons.home_filled, label: 'Home', index: 0),
            _buildNavItem(
                icon: Icons.chat_bubble_outline, label: 'Chat', index: 1),
            _buildNavItem(
                icon: Icons.bookmark_border, label: 'Saved', index: 2),
            _buildNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              index: 3,
              onLongPress: () => _showAccountSwitcher(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    VoidCallback? onLongPress,
  }) {
    final bool isSelected = selectedIndex == index;
    final Color color =
        isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () => onTap(index),
      onLongPress: onLongPress,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountSwitcher(BuildContext context) async {
    final userId = await ApiService.getCurrentUserId();
    if (userId == null) return;

    Map<String, dynamic> user = {};
    try {
      final data = await ApiService.getUserProfile(userId: userId);
      user = data['user'] ?? {};
    } catch (_) {}

    // Business tile shows if: role==provider (same account upgraded)
    // OR a linked business account was stored after registration
    final String role = user['role']?.toString() ?? 'customer';
    final int? businessUserId = await ApiService.getBusinessUserId();
    final bool isProvider = role == 'provider' || businessUserId != null;

    if (!context.mounted) return;

    final String name = user['name']?.toString() ?? 'User';
    final String avatarUrl = user['avatar_url']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // --- Personal Account Tile ---
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(name,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Personal Account'),
                trailing: context
                        .read<NavigationController>()
                        .isBusinessProfile
                    ? null
                    : const Icon(Icons.check_circle,
                        color: Color(0xFF4981FB)),
                onTap: () {
                  Navigator.pop(ctx);
                  context
                      .read<NavigationController>()
                      .setBusinessProfile(false);
                },
              ),

              if (isProvider) ...[
                const Divider(indent: 24, endIndent: 24),

                // --- Business Account Tile ---
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.business,
                        color: Color(0xFF4981FB)),
                  ),
                  title: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  subtitle: const Text('Business Account'),
                  trailing: context
                          .read<NavigationController>()
                          .isBusinessProfile
                      ? const Icon(Icons.check_circle,
                          color: Color(0xFF4981FB))
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    context
                        .read<NavigationController>()
                        .setBusinessProfile(true);
                  },
                ),
              ] else ...[
                const Divider(indent: 24, endIndent: 24),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  leading: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFE8F0FE),
                    child: Icon(Icons.add_business,
                        color: Color(0xFF4981FB)),
                  ),
                  title: const Text('Become a Service Provider',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      const Text('Register your business account'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(
                        context, '/service_provider_register');
                  },
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
