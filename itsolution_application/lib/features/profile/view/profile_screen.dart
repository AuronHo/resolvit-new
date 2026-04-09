import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna Biru Branding
    const Color brandBlue = Color(0xFF4981FB);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Background putih abu
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER BIRU ---
            Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                color: brandBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  // Tombol Back (Kotak Biru Muda/Transparan sesuai gambar)
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withOpacity(0.2),
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   // child: IconButton(
                  //   //   icon: const Icon(Icons.arrow_back, color: Colors.white),
                  //   //   onPressed: () {
                  //       // Kembali ke Home atau tab sebelumnya
                  //       // Jika ini root tab, mungkin tidak perlu aksi atau pindah ke Home tab
                  //     },
                  //   ),
                  // ),
                  const SizedBox(width: 16),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 2. PROFIL INFO (AVATAR & NAMA) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: const DecorationImage(
                        // Ganti dengan foto profil asli
                        image: NetworkImage('https://i.pravatar.cc/300?img=12'), 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Nama
                  const Text(
                    'Sule',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  // Tombol Edit
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit_profile');
                    },
                    child: const Text(
                      'edit',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: Colors.grey), // Garis Pembatas

            // --- 3. INFO EMAIL & PHONE ---
            _buildInfoRow('Email', 'sule123@gmail.com'),
            _buildInfoRow('Phone Number', '0895712544455'),

            const SizedBox(height: 20),

            // --- 4. SETTINGS HEADER ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Colors.grey),

            // --- 5. MENU SETTINGS ---
            
            // b. Reset Password (Navigasi ke screen yang sudah kita buat)
            _buildActionRow(
              title: 'Reset Password',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.pushNamed(context, '/reset_password');
              },
            ),

            // c. Service Provider Register
            _buildActionRow(
              title: 'Service Provider Register',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.pushNamed(context, '/service_provider_register');
              },
            ),
            
            // Tambahan padding bawah agar tidak tertutup nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER 1: Baris Info (Kiri Label, Kanan Value) ---
  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14)),
        ],
      ),
    );
  }

  // --- WIDGET HELPER 2: Baris Aksi (Settings) ---
  Widget _buildActionRow({
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}