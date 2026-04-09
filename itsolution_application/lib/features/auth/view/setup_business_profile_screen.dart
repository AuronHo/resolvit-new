import 'package:flutter/material.dart';


class SetupBusinessProfileScreen extends StatefulWidget {
  const SetupBusinessProfileScreen({super.key});

  @override
  State<SetupBusinessProfileScreen> createState() => _SetupBusinessProfileScreenState();
}

class _SetupBusinessProfileScreenState extends State<SetupBusinessProfileScreen> {
  // Map for Operational Hours
  final Map<String, bool> _operationalDays = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': true,
    'Sunday': false,
  };

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: brandBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Service Provider Register',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            const Text(
              "Set up your business profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 20),

            // --- IMAGE UPLOAD ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[600],
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Select Picture*", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                )
              ],
            ),

            const SizedBox(height: 30),

            // --- FORM FIELDS ---
            _buildFormRow('Speciality*', _buildGreyInput()),
            _buildFormRow('Price Range*', Row(
              children: [
                const Text("Start from Rp ", style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(child: _buildGreyInput()),
              ],
            )),
            _buildFormRow('Description*', _buildGreyInput(lines: 4)),

            // --- OPERATIONAL HOURS ---
            _buildFormRow(
              'Operational hours*',
              Column(
                children: _operationalDays.keys.map((day) {
                  return _buildDayRow(day);
                }).toList(),
              ),
            ),

            // --- SET LOCATION (FIXED LAYOUT) ---
            _buildFormRow(
              'Set Location*',
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map Placeholder (Left)
                  Container(
                    width: 100, // Adjusted width
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/100x80?text=Map'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Adding a marker icon to simulate the map look
                    child: const Center(child: Icon(Icons.location_on, color: Colors.red, size: 30)),
                  ),
                  const SizedBox(width: 12),
                  // Location Details Input (Right)
                  Expanded(
                    child: _buildGreyInput(lines: 3, hint: 'Location details'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- FINISH BUTTON ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/business_profile', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Finish", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildFormRow(String label, Widget content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  // --- FIXED GREY INPUT ---
  Widget _buildGreyInput({int lines = 1, String hint = ''}) {
    return Container(
      height: lines * 35.0,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200], // This gives the grey background
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        maxLines: lines,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          // Important: Make background transparent so Container color shows
          filled: true,
          fillColor: Colors.transparent, 
          
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          contentPadding: const EdgeInsets.only(bottom: 12), // Vertical alignment
        ),
      ),
    );
  }

  // --- FIXED DAY ROW TOGGLE ---
  Widget _buildDayRow(String day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          // Switch
          SizedBox(
            width: 30,
            height: 20,
            child: Transform.scale(
              scale: 0.6,
              child: Switch(
                value: _operationalDays[day]!,
                activeColor: Colors.green,
                inactiveTrackColor: Colors.grey[300], // Visible when off
                onChanged: (val) {
                  setState(() {
                    _operationalDays[day] = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Day Name (Always visible)
          SizedBox(
            width: 70, 
            child: Text(day, style: const TextStyle(fontSize: 11)),
          ),
          
          // Time Inputs or Closed Text
          if (_operationalDays[day]!) ...[
            Expanded(child: _buildGreyInput(lines: 1)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text("-", style: TextStyle(fontSize: 10)),
            ),
            Expanded(child: _buildGreyInput(lines: 1)),
          ] else 
            // When toggle is off, show empty grey boxes or "Closed" text
            const Expanded(
              child: Text("Closed", style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
        ],
      ),
    );
  }
}