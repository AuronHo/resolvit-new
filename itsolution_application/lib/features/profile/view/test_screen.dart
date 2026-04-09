import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use your Brand Blue
    const Color brandBlue = Color(0xFF4981FB);

    return Scaffold(
      backgroundColor: Colors.white,
      
      // 1. Standard AppBar (Like we want)
      appBar: AppBar(
        backgroundColor: brandBlue,
        elevation: 0,
        centerTitle: true,
        
        // Force White Back Button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            print("TEST: Back Button Pressed");
            Navigator.pop(context);
          },
        ),
        
        // Force White Title
        title: const Text(
          'Test Screen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        
        // Rounded Bottom
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      
      // 2. Simple Body (No complex inputs to crash it)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "If you can see this,\nthe navigation works!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("TEST: Big Button Pressed");
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}