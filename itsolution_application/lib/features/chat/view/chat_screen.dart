import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _rooms = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final userId = await ApiService.getCurrentUserId();
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      _currentUserId = userId;
      final data = await ApiService.getChatRooms(userId);
      if (mounted) {
        setState(() {
          _rooms = data['results'] ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
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
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: const TextField(
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Search Chat',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 20),
                          suffixIcon: Icon(Icons.search,
                              color: Color(0xFF4981FB), size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Conversation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: brandBlue))
                : RefreshIndicator(
                    color: brandBlue,
                    onRefresh: _loadRooms,
                    child: _rooms.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height: 300,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_bubble_outline,
                                          size: 64, color: Colors.grey[300]),
                                      const SizedBox(height: 16),
                                      Text('No conversations yet',
                                          style: TextStyle(
                                              color: Colors.grey[400])),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _rooms.length,
                            itemBuilder: (context, index) {
                              final room = _rooms[index];
                              final rawName =
                                  room['partner_name']?.toString() ?? '';
                              final partnerName = rawName.isNotEmpty
                                  ? rawName
                                  : (room['jasa_name']?.toString() ?? 'User');
                              final partnerAvatar =
                                  room['partner_avatar']?.toString() ?? '';
                              final lastMessage =
                                  room['last_message']?.toString() ?? '';

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: partnerAvatar.isNotEmpty
                                      ? NetworkImage(partnerAvatar)
                                      : null,
                                  child: partnerAvatar.isEmpty
                                      ? Text(
                                          partnerName.isNotEmpty
                                              ? partnerName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  partnerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                subtitle: Text(
                                  lastMessage.isNotEmpty
                                      ? lastMessage
                                      : 'Tap to chat',
                                  style: const TextStyle(color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  if (_currentUserId == null) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatDetailScreen(
                                        roomId: room['id'],
                                        partnerName: partnerName,
                                        currentUserId: _currentUserId!,
                                      ),
                                    ),
                                  ).then((_) => _loadRooms());
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
