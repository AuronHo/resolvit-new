import 'package:flutter/material.dart';
import '../../../services/api_service.dart'; // Sesuaikan path ini

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State Variables
  bool _isLoading = true;
  String _name = '';
  String _email = '';
  String _phone = '';
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      // 1. Ambil ID asli yang tersimpan di HP
      final currentUserId = await ApiService.getCurrentUserId();

      if (currentUserId == null) {
        // Jika null, berarti belum login, arahkan ke layar login
        print("User belum login!");
        return;
      }

      print("Sedang mengambil data untuk User ID: $currentUserId");

      // 2. Gunakan ID asli tersebut untuk memanggil Golang
      final data = await ApiService.getUserProfile(userId: currentUserId);
      final user = data['user']; 

      if (mounted) {
        setState(() {
          _name = user['name'] ?? 'User Name';
          _email = user['email'] ?? 'No Email';
          _phone = user['phone'] ?? '-';
          _avatarUrl = user['avatar_url'] ?? 'https://i.pravatar.cc/300';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: brandBlue))
          : SingleChildScrollView(
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
                      children: const [
                        SizedBox(width: 16),
                        Text(
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
                            image: DecorationImage(
                              image: NetworkImage(_avatarUrl), // Data dari DB
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Nama
                        Expanded( // Gunakan Expanded agar nama panjang tidak error
                          child: Text(
                            _name, // Data dari DB
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                  const Divider(height: 1, thickness: 1, color: Colors.grey),

                  // --- 3. INFO EMAIL & PHONE ---
                  _buildInfoRow('Email', _email), // Data dari DB
                  _buildInfoRow('Phone Number', _phone), // Data dari DB

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
                  _buildActionRow(
                    title: 'Reset Password',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.pushNamed(context, '/reset_password');
                    },
                  ),

                  _buildActionRow(
                    title: 'Service Provider Register',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.pushNamed(context, '/service_provider_register');
                    },
                  ),
                  
                  // Tombol Logout (Optional tapi penting)
                  _buildActionRow(
                    title: 'Log Out',
                    trailing: const Icon(Icons.logout, size: 16, color: Colors.redAccent),
                    onTap: () {
                      // TODO: Hapus token dan kembali ke layar login
                      print("User Logged Out");
                    },
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  // --- WIDGET HELPER 1 ---
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

  // --- WIDGET HELPER 2 ---
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
              style: TextStyle(
                color: title == 'Log Out' ? Colors.redAccent : Colors.black, // Beri warna merah untuk logout
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