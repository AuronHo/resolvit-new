import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Wajib import Provider

// 2. IMPORT CONTROLLER (Naik 2 level: keluar widgets, keluar view, masuk logic)
import '../../logic/navigation_controller.dart';

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
      // Margin dan desain floating (TETAP SAMA)
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 70, // Beri tinggi pasti agar rapi
      decoration: BoxDecoration(
        color: const Color(0xFF4981FB),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Bagi ruang rata
          children: [
            // --- 1. HOME ---
            _buildNavItem(icon: Icons.home_filled, label: 'Home', index: 0),

            // --- 2. CHAT ---
            _buildNavItem(
              icon: Icons.chat_bubble_outline,
              label: 'Chat',
              index: 1,
            ),

            // --- 3. SAVED ---
            _buildNavItem(
              icon: Icons.bookmark_border,
              label: 'Saved',
              index: 2,
            ),

            // --- 4. PROFILE (SPESIAL) ---
            _buildNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              index: 3,
              // INI RAHASIANYA: Tambahkan logika Long Press
              onLongPress: () {
                _showAccountSwitcher(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET ITEM NAVIGASI MANUAL ---
  // Kita buat manual agar bisa pasang 'onLongPress'
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    VoidCallback? onLongPress, // Parameter opsional untuk Long Press
  }) {
    final bool isSelected = selectedIndex == index;
    final Color color = isSelected
        ? Colors.white
        : Colors.white.withOpacity(0.6);

    return GestureDetector(
      // 1. KLIK BIASA: Pindah Halaman
      onTap: () => onTap(index),

      // 2. TAHAN LAMA (Long Press): Khusus Profile
      onLongPress: onLongPress,

      // Tampilan Icon & Teks
      child: Container(
        color: Colors.transparent, // Agar area sentuh luas
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- POP-UP SWITCHER (Sama seperti sebelumnya) ---
  void _showAccountSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?u=sule',
                  ),
                ),
                title: const Text(
                  'Sule',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Personal Account'),
                onTap: () {
                  Navigator.pop(context); // Tutup pop up
                  // Set ke Personal Profile
                  context.read<NavigationController>().setBusinessProfile(
                    false,
                  );
                },
              ),
              const Divider(indent: 24, endIndent: 24),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150',
                  ),
                ),
                title: const Text(
                  'Buana Phone Service',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Business Account'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<NavigationController>().setBusinessProfile(true);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
