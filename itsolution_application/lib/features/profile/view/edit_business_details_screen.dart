import 'package:flutter/material.dart';

class EditBusinessDetailsScreen extends StatefulWidget {
  const EditBusinessDetailsScreen({super.key});

  @override
  State<EditBusinessDetailsScreen> createState() => _EditBusinessDetailsScreenState();
}

class _EditBusinessDetailsScreenState extends State<EditBusinessDetailsScreen> {
  // --- CONTROLLERS ---
  late TextEditingController _specialityController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _locationController;

  // --- TOGGLES ---
  final Map<String, bool> _operationalDays = {
    'Monday': true, 'Tuesday': true, 'Wednesday': true,
    'Thursday': true, 'Friday': true, 'Saturday': true, 'Sunday': false,
  };

  @override
  void initState() {
    super.initState();
    _specialityController = TextEditingController(text: "website service");
    _priceController = TextEditingController(text: "100.000");
    _descController = TextEditingController(text: "Buat Website di sini aja");
    _locationController = TextEditingController(text: "Lucky plaza, Jl. Imam Bonjol, Lubuk Baja Kota...");
  }

  @override
  void dispose() {
    _specialityController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        
        appBar: AppBar(
          backgroundColor: brandBlue,
          elevation: 0,
          centerTitle: false,
          // Force White Theme
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18
          ),
          
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
          ),
          
          title: const Text('Edit details'),
          
          // --- FIX: SAFE SAVE BUTTON ---
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: brandBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  minimumSize: const Size(60, 32),
                ),
                child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.only(
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 50, 
            ),
            children: [
              // 1. Speciality
              _buildFormRow('Speciality*', _buildGreyInput(controller: _specialityController)),
              
              // 2. Price
              _buildFormRow('Price Range*', Row(
                children: [
                  const Text("Start from Rp ", style: TextStyle(fontSize: 12, color: Colors.black87)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildGreyInput(controller: _priceController)),
                ],
              )),
              
              // 3. Description
              _buildFormRow('Description*', _buildGreyInput(controller: _descController, lines: 4)),

              // 4. Hours
              _buildFormRow(
                'Operational hours*',
                Column(
                  children: _operationalDays.keys.map((day) {
                    return _buildDayRow(day);
                  }).toList(),
                ),
              ),

              // 5. Location
              _buildFormRow(
                'Set Location*',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: const Center(child: Icon(Icons.location_on, color: Colors.red, size: 30)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGreyInput(controller: _locationController, lines: 3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildFormRow(String label, Widget content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
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

  Widget _buildGreyInput({int lines = 1, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      maxLines: lines,
      style: const TextStyle(fontSize: 12, color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        isDense: true, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  // Helper for Time Inputs
  Widget _buildTimeInput(String initialValue) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 12, color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  Widget _buildDayRow(String day) {
    bool isOpen = _operationalDays[day]!;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Toggle
          SizedBox(
            width: 40,
            height: 24,
            child: Transform.scale(
              scale: 0.6,
              child: Switch(
                value: isOpen, 
                activeColor: const Color(0xFF4CAF50),
                inactiveThumbColor: const Color(0xFFFF3B30),
                inactiveTrackColor: const Color(0xFFFF3B30).withOpacity(0.3),
                trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                onChanged: (val) {
                  setState(() {
                    _operationalDays[day] = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          
          // Day Name
          Expanded(
            flex: 3, // Give day name a bit more weight
            child: Text(day,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
                overflow: TextOverflow.ellipsis), // Prevent text overflow
          ),
          
          // Inputs
          if (isOpen) ...[
            Expanded(flex: 3, child: _buildTimeInput("08:00")),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text("-", style: TextStyle(fontSize: 10))),
            Expanded(flex: 3, child: _buildTimeInput("22:00")),
          ] else
            const Expanded(
                flex: 7, // Takes up the space of both inputs + dash
                child: Text("Closed",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}