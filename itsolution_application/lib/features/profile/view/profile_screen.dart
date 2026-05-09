import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../../../providers/bookmark_provider.dart';
import '../../main_navigation/logic/navigation_controller.dart';

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
  String _role = 'customer';
  bool _hasBusinessAccount = false;

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
          if (mounted) {
          setState(() {
            _isLoading = false; // HENTIKAN LOADING-NYA DI SINI
          });
        }
        return;
      }

      final data = await ApiService.getUserProfile(userId: currentUserId);
      final user = data['user'];
      final businessId = await ApiService.getBusinessUserId();

      if (mounted) {
        setState(() {
          _name = user['name'] ?? 'User Name';
          _email = user['email'] ?? 'No Email';
          _phone = user['phone'] ?? '-';
          _avatarUrl = user['avatar_url'] ?? 'https://i.pravatar.cc/300';
          _role = user['role'] ?? 'customer';
          _hasBusinessAccount = _role == 'provider' || businessId != null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // 1. Tampilkan indikator loading (opsional tapi bagus untuk UX)
      setState(() {
        _isLoading = true;
      });

      // 2. Hapus sesi dari memori HP
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUserId');
      await prefs.remove('jwt_token');
      await prefs.remove('business_user_id');

      // 3. Logout dari Google (Jika user pakai Google Sign-In)
      try { await GoogleSignIn.instance.signOut(); } catch (_) {}

      // 4. Bersihkan data 'Saved' dari Provider agar tidak membekas
      if (context.mounted) {
        Provider.of<BookmarkProvider>(context, listen: false).clearData();
      }

      // 5. Reset business mode then navigate to welcome
      if (context.mounted) {
        Provider.of<NavigationController>(context, listen: false)
            .setBusinessProfile(false);
        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Log Out: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showBusinessLoginSheet(BuildContext context) async {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool loading = false;
    String? error;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text('Log In to Business Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Business Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4981FB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: loading
                        ? null
                        : () async {
                            setModalState(() { loading = true; error = null; });
                            try {
                              final userId = await ApiService.getCurrentUserId();
                              if (userId == null) throw Exception('Not logged in');
                              final result = await ApiService.linkBusinessAccount(
                                userId: userId,
                                email: emailCtrl.text.trim(),
                                password: passCtrl.text,
                              );
                              final providerId = result['provider_user_id'] as int?;
                              if (providerId != null) {
                                await ApiService.saveBusinessUserId(providerId);
                              }
                              if (ctx.mounted) Navigator.pop(ctx);
                              _fetchProfileData();
                            } catch (e) {
                              setModalState(() {
                                loading = false;
                                error = e.toString().replaceFirst('Exception: ', '');
                              });
                            }
                          },
                    child: loading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                            Navigator.pushNamed(context, '/edit_profile')
                                .then((_) => _fetchProfileData());
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

                  if (!_hasBusinessAccount) ...[
                    _buildActionRow(
                      title: 'Service Provider Register',
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        Navigator.pushNamed(context, '/service_provider_register')
                            .then((_) => _fetchProfileData());
                      },
                    ),
                    _buildActionRow(
                      title: 'Log In to Business Account',
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () => _showBusinessLoginSheet(context),
                    ),
                  ],

                  if (_hasBusinessAccount)
                    _buildActionRow(
                      title: 'My Business Profile',
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        Navigator.pushNamed(context, '/business_profile');
                      },
                    ),

                  _buildActionRow(
                    title: 'Log Out',
                    trailing: const Icon(Icons.logout, size: 16, color: Colors.redAccent),
                    onTap: () => _logout(context),
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