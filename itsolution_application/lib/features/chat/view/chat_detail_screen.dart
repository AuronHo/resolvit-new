import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  
  final List<Map<String, dynamic>> _messages = [
    {'isMe': true, 'text': 'hi bang', 'time': '10:00'},
    {'isMe': false, 'text': 'Hallo sis', 'time': '09:59'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.insert(0, {'isMe': true, 'text': _messageController.text, 'time': 'Now'});
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);
    // Warna background body
    const Color backgroundColor = Color(0xFFF9F9F9); 

    return Scaffold(
      backgroundColor: backgroundColor, 
      appBar: AppBar(
        backgroundColor: brandBlue,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buana Phone Service',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('01/10/2025', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),

          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isMe = msg['isMe'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMe) ...[
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? brandBlue : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // --- INPUT FIELD (FIXED: FULL GRAY CAPSULE) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white, // Background baris paling luar (Putih)
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline, size: 28, color: Colors.grey),
                const SizedBox(width: 8),
                const Icon(Icons.sentiment_satisfied_alt, size: 28, color: Colors.grey),
                const SizedBox(width: 12),
                
                // Kotak Ketik (Kapsul Abu)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // <--- WARNA ABU KAPSUL DISINI
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.black), // Warna teks ketikan
                      decoration: const InputDecoration(
                        hintText: 'Type something...',
                        hintStyle: TextStyle(color: Colors.grey),
                        
                        // --- PENTING: BIKIN TRANSPARAN ---
                        filled: true,
                        fillColor: Colors.transparent, // Agar tidak menimpa warna abu container
                        
                        // Hilangkan semua garis border
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        
                        // Agar teks pas di tengah
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        isDense: true, 
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF4981FB)), // Icon Kirim Biru
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}