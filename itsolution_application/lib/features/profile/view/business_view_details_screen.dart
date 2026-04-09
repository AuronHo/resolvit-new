import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class BusinessViewDetailsScreen extends StatelessWidget {
  const BusinessViewDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Business Details', // Changed title for owner
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Add an Edit button for the owner
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/edit_business_details');
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- HEADER ---
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    image: const DecorationImage(
                      image: NetworkImage('https://loremflickr.com/200/200/logo,website?lock=profile'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Text(
                    'Cepatlulus Web Service',
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

            // --- INFO ROWS ---
            _buildInfoRow('Speciality', 'Website'),
            _buildInfoRow('Price Range', 'Start from Rp 100.000'),
            _buildInfoRow(
              'Description',
              'Buat Website disini aja bro. Murah dan Bagus',
            ),

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

            _buildCustomRow(
              'Location',
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=600&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Lucky plaza, Jl. Imam Bonjol, Lubuk Baja Kota, Kec. Lubuk Baja, Kota Batam',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              showBorder: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return _buildCustomRow(
      label,
      Text(value, style: const TextStyle(color: Colors.black87, fontSize: 13)),
    );
  }

  Widget _buildCustomRow(
    String label,
    Widget valueWidget, {
    bool showBorder = true,
  }) {
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
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

Widget _buildTimeRow(String day, String time, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Jaga agar teks rata atas jika nge-wrap
        children: [
          // 1. Nama Hari (Diberi lebar fix secukupnya agar rapi)
          SizedBox(
            width: 75, 
            child: Text(
              day,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          
          // 2. Jam (Diberi Expanded agar mengisi sisa ruang dan tidak overflow)
          Expanded(
            child: Text(
              time,
              textAlign: TextAlign.right, // Rata kanan agar rapi
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
