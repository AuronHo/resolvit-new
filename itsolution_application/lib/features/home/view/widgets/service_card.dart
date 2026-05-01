import 'package:flutter/material.dart';
import '../../../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../../../providers/bookmark_provider.dart';

class ServiceCard extends StatefulWidget {
  final int jasaId; // DITAMBAHKAN: ID Jasa untuk dikirim ke Backend
  final String title;
  final String specialty;
  final String price;
  final String rating;
  final bool isOpen;
  final String imageUrl;
  final VoidCallback onTap;
  final bool initialIsSaved;

  const ServiceCard({
    super.key,
    required this.jasaId, // DITAMBAHKAN
    required this.title,
    required this.specialty,
    required this.price,
    required this.rating,
    required this.isOpen,
    required this.imageUrl, 
    required this.onTap,
    this.initialIsSaved = false,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  // Dihilangkan kata 'late' dan langsung diberi nilai awal untuk mencegah error layar merah
  bool _isSaved = false; 

  // --- 1. INISIALISASI AWAL SAAT KARTU DIGAMBAR ---
  @override
  void initState() {
    super.initState();
    _isSaved = widget.initialIsSaved; 
  }

  // --- 2. UPDATE KARTU JIKA DATA DARI SERVER BERUBAH ---
  @override
  void didUpdateWidget(covariant ServiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsSaved != oldWidget.initialIsSaved) {
      setState(() {
        _isSaved = widget.initialIsSaved;
      });
    }
  }

  Future<void> _toggleSave() async {
    // 1. Ubah UI sementara biar terasa cepat (Optimistic Update)
    setState(() {
      _isSaved = !_isSaved; 
    });

    try {
      final currentUserId = await ApiService.getCurrentUserId();

      print("===== DEBUG SAVE =====");
      print("Mencoba save JasaID: ${widget.jasaId} untuk UserID: $currentUserId"); // Print dinamis!

      // Jika ID kosong (belum login/belum tersimpan)
      if (currentUserId == null) {
        print("GAGAL: User ID null. Mengembalikan warna icon.");
        setState(() => _isSaved = !_isSaved); // Kembalikan warna
        
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan login terlebih dahulu'), backgroundColor: Colors.red),
          );
        }
        return; // Hentikan proses di sini
      }

      await ApiService.toggleSaveService(userId: currentUserId, jasaId: widget.jasaId);
      
      print("API Save Berhasil direspon Golang!");
      print("======================");

      // 3. Suruh Provider mengupdate daftar Saved di latar belakang
      if (mounted) {
        Provider.of<BookmarkProvider>(context, listen: false).loadSavedServices();
      }

      // 4. Tampilkan SnackBar kalau sukses
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Disimpan ke Favorit!' : 'Dihapus dari Favorit'),
            backgroundColor: Colors.green, // Hijau kalau sukses
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // CCTV 2: TANGKAP ERROR JIKA GAGAL
      print("!!! ERROR API SAVE !!!");
      print(e.toString());
      print("======================");

      // 4. KEMBALIKAN WARNA ICON SEPERTI SEMULA KARENA GAGAL
      setState(() {
        _isSaved = !_isSaved; 
      });

      // Tampilkan error merah
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GAMBAR (Kotak di Kiri)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl), // Berubah jadi widget.imageUrl
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(width: 12), // Jarak

            // 2. KONTEN TEKS (Kanan)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BARIS 1: JUDUL & ICON BOOKMARK ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Judul Toko
                      Expanded(
                        child: Text(
                          widget.title, // Berubah jadi widget.title
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      
                      // --- DITAMBAHKAN: ICON BOOKMARK YANG BISA DIKLIK ---
                      GestureDetector(
                        onTap: _toggleSave,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                          child: Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: _isSaved ? const Color(0xFF4981FB) : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // --- BARIS 2: RATING ---
                  Row(
                    children: [
                      Text(
                        widget.rating, // Berubah jadi widget.rating
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // --- BARIS 3: SPESIALISASI ---
                  Text(
                    widget.specialty, // Berubah jadi widget.specialty
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // --- BARIS 4: HARGA ---
                  Text(
                    "Price start from ${widget.price}", // Berubah jadi widget.price
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // --- BARIS 5: STATUS JAM BUKA ---
                  Text(
                    widget.isOpen ? "Open (08:00 - 22:00)" : "Closed", // Berubah jadi widget.isOpen
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.isOpen ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}