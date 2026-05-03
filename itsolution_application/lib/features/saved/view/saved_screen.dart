import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // DITAMBAHKAN
import '../../home/view/widgets/service_card.dart';
import '../../../../providers/bookmark_provider.dart'; // DITAMBAHKAN (Pastikan path folder benar)

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  
  @override
  void initState() {
    super.initState();
    // Menyuruh Provider menarik data dari API saat layar pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookmarkProvider>(context, listen: false).loadSavedServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // --- HEADER SECTION (TIDAK DIUBAH) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
            decoration: const BoxDecoration(
              color: brandBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Saved Services', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Your favorite workshops', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          // --- LIST DATA MENGGUNAKAN CONSUMER PROVIDER ---
          Expanded(
            child: Consumer<BookmarkProvider>(
              builder: (context, provider, child) {
                // 1. Tampilan Loading
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: brandBlue));
                }

                // 2. Tampilan Kosong (Belum ada yang disave)
                if (provider.savedList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text("No saved services yet", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                // 3. Tampilan Daftar Jasa
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  itemCount: provider.savedList.length,
                  itemBuilder: (context, index) {
                    final item = provider.savedList[index];
                    final randomId = item['JasaID'] ?? index;
                    final bool hasImage = item['ImageUrl'] != null && item['ImageUrl'].toString().isNotEmpty;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: ServiceCard(
                        jasaId: item['JasaID'],
                        initialIsSaved: true, // PENTING: Karena ini di layar Saved, pasti true
                        title: item['NamaJasa'] ?? 'Tanpa Nama',
                        specialty: item['Kategori'] ?? 'Umum',
                        price: item['HargaMulai'] != null ? 'Rp ${item['HargaMulai']}' : 'Hubungi Kami',
                        rating: item['RatingRataRata']?.toString() ?? '0.0',
                        isOpen: item['IsOpen'] ?? true,
                        imageUrl: hasImage ? item['ImageUrl'] : 'https://picsum.photos/seed/$randomId/320/240',
                        onTap: () => Navigator.pushNamed(context, '/service_detail', arguments: item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}