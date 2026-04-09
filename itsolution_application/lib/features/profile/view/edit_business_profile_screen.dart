import 'package:flutter/material.dart';

class EditBusinessProfileScreen extends StatefulWidget {
  const EditBusinessProfileScreen({super.key});

  @override
  State<EditBusinessProfileScreen> createState() => _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState extends State<EditBusinessProfileScreen> {
  // --- CONTROLLERS ---
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    _nameController = TextEditingController(text: "Cepatlulus Web Service");
    _emailController = TextEditingController(text: "sule123@gmail.com");
    _phoneController = TextEditingController(text: "0895712544455");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
          centerTitle: true,
          
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 18
          ),
          
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
          ),
          
          title: const Text('Edit Profile'),
          
          // --- FIX: SAFE SAVE BUTTON ---
          // Replaced complex SizedBox/Center/ElevatedButton with a simple TextButton
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
                  // Ensure button has a reasonable hit area
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
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              _buildProfileImage(),

              const SizedBox(height: 30),
              const Divider(height: 1, thickness: 1, color: Colors.grey),

              // Inputs
              _buildInputRow("Business Name*", _nameController),
              _buildInputRow("Email*", _emailController),
              _buildInputRow("Phone Number*", _phoneController),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Change",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          const Text(
            "Put your best picture!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Container(
      // Keep fixed height to prevent layout crash
      height: 60, 
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140, 
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54, 
              ),
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                border: InputBorder.none, 
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}