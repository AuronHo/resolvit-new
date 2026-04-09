import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String specialty;
  final String price;
  final String rating;
  final bool isOpen;
  final String imageUrl;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.title,
    required this.specialty,
    required this.price,
    required this.rating,
    required this.isOpen,
    required this.imageUrl, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          crossAxisAlignment: CrossAxisAlignment.start, // Ratakan konten ke atas
          children: [
            // 1. GAMBAR (Kotak di Kiri)
            Container(
              width: 100, // Ukuran sedikit diperbesar agar proporsional
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                image: DecorationImage(
                  // Ganti URL ini dengan gambar toko asli jika ada
                  image: NetworkImage(imageUrl), 
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
                      // Judul Toko (Bisa panjang)
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Icon Bookmark Biru
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.bookmark, 
                          color: Color(0xFF4981FB), // Warna Biru Brand
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  // --- BARIS 2: RATING ---
                  Row(
                    children: [
                      Text(
                        rating,
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
                    specialty,
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
                    "Price start from $price", // Format teks sesuai gambar
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // --- BARIS 5: STATUS JAM BUKA (HIJAU) ---
                  Text(
                    isOpen ? "Open (08:00 - 22:00)" : "Closed",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOpen ? Colors.green : Colors.red,
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