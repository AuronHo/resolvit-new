import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/app_colors.dart';

class BusinessViewDetailsScreen extends StatelessWidget {
  const BusinessViewDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        {};

    final serviceName = service['NamaJasa']?.toString() ?? 'My Business';
    final kategori = service['Kategori']?.toString() ?? '-';
    final price = service['HargaMulai'] != null
        ? 'Start from Rp ${service['HargaMulai']}'
        : 'Contact us';
    final desc = service['DeskripsiJasa']?.toString() ?? '-';
    final avatarUrl = service['image_url']?.toString() ?? '';
    final location = service['location']?.toString() ?? '';
    final hoursJson = service['operational_hours']?.toString() ?? '';

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
          'My Business Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              final nav = Navigator.of(context);
              nav
                  .pushNamed('/edit_business_details', arguments: service)
                  .then((_) => nav.pop());
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? const Icon(Icons.business, size: 40, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    serviceName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildInfoRow('Speciality', kategori),
            _buildInfoRow('Price Range', price),
            _buildInfoRow('Description', desc),
            _buildHoursRow(hoursJson),
            if (location.isNotEmpty) _buildLocationRow(location),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.black87, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursRow(String hoursJson) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];

    Map<String, dynamic> parsed = {};
    if (hoursJson.isNotEmpty) {
      try {
        parsed = jsonDecode(hoursJson) as Map<String, dynamic>;
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text('Operational Hours',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: parsed.isEmpty
                ? Text('Not set',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: days.map((day) {
                      final d = parsed[day] as Map<String, dynamic>?;
                      if (d == null) return const SizedBox.shrink();
                      final isOpen = d['open'] == true;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(day,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            Text(
                              isOpen
                                  ? '${d['from']} - ${d['to']}'
                                  : 'Closed',
                              style: TextStyle(
                                fontSize: 12,
                                color: isOpen ? Colors.black87 : Colors.red,
                                fontWeight: isOpen
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String location) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text('Location',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location,
                    style:
                        const TextStyle(color: Colors.black87, fontSize: 13)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final query = Uri.encodeComponent(location);
                    final uri =
                        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined,
                          size: 16, color: Color(0xFF4981FB)),
                      const SizedBox(width: 4),
                      Text(
                        'Open in Google Maps',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
