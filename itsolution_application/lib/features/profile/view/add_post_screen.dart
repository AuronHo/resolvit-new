import 'package:flutter/material.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
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
        
        // --- HEADER ---
        appBar: AppBar(
          backgroundColor: brandBlue,
          elevation: 0,
          toolbarHeight: 70,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(""), // Empty title
          
          // --- FIX: SAFE POST BUTTON ---
          // Replaced complex layout with safe TextButton
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: () {
                  // Post Logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post uploaded successfully!')),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: brandBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  // Ensure button is visible
                  minimumSize: const Size(60, 32), 
                ),
                child: const Text("Post", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
          
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),

        // --- BODY ---
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add picture or video",
                  style: TextStyle(
                    fontSize: 14, 
                    color: Colors.black87,
                    fontWeight: FontWeight.w500
                  ),
                ),
                
                const SizedBox(height: 12),

                // --- IMAGE UPLOAD PLACEHOLDER ---
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 24),

                // --- CAPTION BOX ---
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _captionController,
                    maxLines: null, // Allow multiline
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: "Add caption",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}