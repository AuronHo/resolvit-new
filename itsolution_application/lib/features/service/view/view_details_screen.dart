import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart'; // Pastikan import ini ada

class ViewDetailsScreen extends StatelessWidget {
  const ViewDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Header Biru dengan sudut melengkung di bawah
        backgroundColor: kPrimaryBlue, // Warna 3573FA
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- HEADER: FOTO & NAMA TOKO ---
            Row(
              children: [
                // Avatar Toko
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    image: DecorationImage(
                      // Ganti dengan asset gambar toko Anda
                      // image: AssetImage('assets/images/toko_avatar.png'),
                      image: NetworkImage('https://loremflickr.com/200/200/mobile,phone,logo?lock=buana'), 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Nama Toko
                const Expanded(
                  child: Text(
                    'Buana Phone Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),

            // --- TABEL INFORMASI ---
            // Kita bungkus dalam container border atas/bawah jika perlu, 
            // tapi di desain hanya divider per baris.
            
            _buildInfoRow('Speciality', 'phone service'),
            _buildInfoRow('Ratings', '5 out of 5'),
            _buildInfoRow('Price Range', 'Start from Rp 50.000'),
            _buildInfoRow('Description', 'perbaiki hp di sini ajah'),
            
            // Row Khusus untuk Jam Operasional (Isinya List)
            _buildCustomRow(
              'Operational hours',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeRow('Monday', '08:00 AM - 10:00 PM'),
                  _buildTimeRow('Tuesday', '08:00 AM - 10:00 PM'),
                  _buildTimeRow('Wednesday', '08:00 AM - 10:00 PM'),
                  _buildTimeRow('Thursday', '08:00 AM - 10:00 PM'),
                  _buildTimeRow('Friday', '08:00 AM - 10:00 PM'),
                  _buildTimeRow('Saturday', '08:00 AM - 02:00 PM'),
                  _buildTimeRow('Sunday', 'CLOSE', isRed: true),
                ],
              ),
            ),

            // Row Khusus untuk Lokasi (Isinya Gambar Peta + Teks)
            _buildCustomRow(
              'Location',
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder Gambar Peta Kecil
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                      image: DecorationImage(
                        // Ganti dengan asset map placeholder
                         image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=600&q=80'),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Lucky plaza, Jl. Imam Bonjol, Lubuk Baja Kota, Kec. Lubuk Baja, Kota Batam, Kepulauan Riau 29444',
                      style: TextStyle(fontSize: 12, height: 1.5, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              showBorder: false, // Hilangkan border di item terakhir agar rapi
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER 1: Row Biasa (Teks kiri, Teks Kanan) ---
  Widget _buildInfoRow(String label, String value) {
    return _buildCustomRow(
      label, 
      Text(
        value, 
        style: const TextStyle(color: Colors.black87, fontSize: 13),
      )
    );
  }

  // --- HELPER 2: Row Kustom (Teks kiri, Widget Kanan Bebas) ---
  Widget _buildCustomRow(String label, Widget valueWidget, {bool showBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: showBorder 
            ? Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)) 
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom Label (Kiri) - Lebar fix atau flex
          SizedBox(
            width: 130, 
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600], 
                fontSize: 13,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          // Kolom Isi (Kanan)
          Expanded(
            child: valueWidget,
          ),
        ],
      ),
    );
  }

  // --- HELPER 3: Baris Jam (Hari ... Jam) ---
  Widget _buildTimeRow(String day, String time, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Pastikan rata atas
        children: [
          // 1. Nama Hari (Fix Width secukupnya)
          SizedBox(
            width: 75,
            child: Text(
              day,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          
          // 2. Jam (Expanded agar mengisi sisa ruang & wrap jika perlu)
          Expanded(
            child: Text(
              time,
              textAlign: TextAlign.right, // Rata kanan
              style: TextStyle(
                fontSize: 12,
                color: isRed ? Colors.red : Colors.black87,
                fontWeight: isRed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}