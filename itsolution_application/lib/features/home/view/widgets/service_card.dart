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

      if (currentUserId == null) {
        setState(() => _isSaved = !_isSaved);
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan login terlebih dahulu'), backgroundColor: Colors.red),
          );
        }
        return; // Hentikan proses di sini
      }

      await ApiService.toggleSaveService(userId: currentUserId, jasaId: widget.jasaId);

      if (mounted) {
        Provider.of<BookmarkProvider>(context, listen: false).loadSavedServices();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Disimpan ke Favorit!' : 'Dihapus dari Favorit'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaved = !_isSaved);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  IconData _categoryIcon(String specialty) {
    final s = specialty.toLowerCase();
    if (s.contains('phone') || s.contains('mobile')) return Icons.phone_android;
    if (s.contains('laptop') || s.contains('pc') || s.contains('computer')) return Icons.laptop;
    if (s.contains('web')) return Icons.web;
    if (s.contains('app') || s.contains('android') || s.contains('ios')) return Icons.grid_view;
    if (s.contains('cloud')) return Icons.cloud_queue;
    if (s.contains('security') || s.contains('cyber')) return Icons.security;
    if (s.contains('consult')) return Icons.business_center;
    if (s.contains('network')) return Icons.hub;
    if (s.contains('data') || s.contains('database')) return Icons.storage;
    return Icons.computer;
  }

  Widget _buildPlaceholder(String specialty) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4981FB), Color(0xFF173DDC)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_categoryIcon(specialty),
              color: Colors.white.withValues(alpha: 0.9), size: 34),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('IT',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ),
        ],
      ),
    );
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GAMBAR (Kotak di Kiri)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildPlaceholder(widget.specialty),
                    )
                  : _buildPlaceholder(widget.specialty),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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

                  const SizedBox(height: 2),

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

                  const SizedBox(height: 4),

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