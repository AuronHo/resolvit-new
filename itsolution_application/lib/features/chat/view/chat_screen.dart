import 'package:flutter/material.dart';
import 'chat_detail_screen.dart'; 

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna Biru Chat
    const Color brandBlue = Color(0xFF4981FB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER BIRU DENGAN SEARCH BAR BULAT ---
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: brandBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                
                const SizedBox(width: 8),

                // --- SEARCH BAR (PASTI BULAT) ---
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(30), // Radius di Container
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    // ClipRRect MEMAKSA isinya agar terpotong melengkung
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30), 
                      child: const TextField(
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Search Chat',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          
                          // PENTING: Set background TextField jadi transparan
                          // agar warna Container yang terlihat
                          filled: true,
                          fillColor: Colors.transparent, 
                          
                          // Hapus semua border bawaan TextField
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          suffixIcon: Icon(Icons.search, color: Color(0xFF4981FB), size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          
          // --- JUDUL CONVERSATION ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Conversation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          // --- LIST CHAT ---
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 3, 
              itemBuilder: (context, index) {

                final String randomProfile = 'https://i.pravatar.cc/150?u=${index + 10}';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(randomProfile), 
                  ),
                  title: const Text(
                    'Buana Phone Service',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Hallo sis',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: const Text(
                    '10 min',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatDetailScreen()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}