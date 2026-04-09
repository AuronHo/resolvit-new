import 'package:flutter/material.dart';

class AccountSwitcherScreen extends StatelessWidget {
  const AccountSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: brandBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Switch Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 10),
        children: [
          // Akun 1: Personal (Sule)
          _buildAccountTile(
            context,
            name: 'Sule',
            type: 'Personal Account',
            imageUrl: 'https://i.pravatar.cc/150?u=sule', // Ganti dengan URL Sule
            onTap: () {
              // Navigasi ke Halaman Profile Pribadi (ProfileScreen)
              Navigator.pop(context); // Tutup switcher
              Navigator.pushNamed(context, '/profile');
            },
          ),
          
          // Akun 2: Business (Buana Phone Service)
          _buildAccountTile(
            context,
            name: 'Buana Phone Service',
            type: 'Business Account',
            imageUrl: 'https://via.placeholder.com/150', // Ganti dengan URL Buana
            onTap: () {
              // Navigasi ke Halaman Profile Bisnis (BusinessProfileScreen)
              Navigator.pop(context); // Tutup switcher
              Navigator.pushNamed(context, '/business_profile'); 
            },
          ),

          // Tambahkan opsi "Add Account" atau "Logout" jika perlu
        ],
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context, {
    required String name,
    required String type,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  type,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}