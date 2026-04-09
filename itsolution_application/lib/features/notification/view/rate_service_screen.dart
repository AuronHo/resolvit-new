import 'package:flutter/material.dart';

class RateServiceScreen extends StatefulWidget {
  const RateServiceScreen({super.key});

  @override
  State<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends State<RateServiceScreen> {
  int _rating = 0; // 0 to 5
  final TextEditingController _commentController = TextEditingController();

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
          toolbarHeight: 80,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Rate',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Buana Phone Service',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // --- SHOP IMAGE ---
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: const DecorationImage(
                      image: NetworkImage('https://loremflickr.com/200/200/mobile,phone,logo?lock=buana'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                const Text(
                  'How helpful was it?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                
                const SizedBox(height: 16),
                
                // --- STAR RATING ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: index < _rating ? Colors.amber : Colors.grey[300],
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                
                const SizedBox(height: 20),

                // --- COMMENT BOX ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 5,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Leave some comments',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- ADD PHOTO OPTION ---
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Add photos",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    )
                  ],
                ),

                const SizedBox(height: 40),

                // --- SUBMIT BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Submit Logic -> Go Back
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thank you for your rating!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4981FB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
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