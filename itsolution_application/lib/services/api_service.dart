import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Central base URL — swap this for production when deployed
  static const String _base = 'http://10.0.2.2:8080';

  // ===========================================================================
  // AUTH HELPERS
  // ===========================================================================

  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('currentUserId');
  }

  static Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ===========================================================================
  // SEARCH (Go backend — replaces Python/ngrok)
  // ===========================================================================

  static Future<Map<String, dynamic>> searchServices(String query) async {
    final currentUserId = await getCurrentUserId();
    final userIdParam = currentUserId?.toString() ?? '0';
    final uri = Uri.parse(
        '$_base/api/search?query=${Uri.encodeComponent(query)}&user_id=$userIdParam');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'results': data['results'] ?? [],
          'message': data['message'],
        };
      }
      throw Exception('Server error (${response.statusCode})');
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // ===========================================================================
  // SERVICES
  // ===========================================================================

  static Future<Map<String, dynamic>> getRecommendations() async {
    final currentUserId = await getCurrentUserId();
    final userIdParam = currentUserId?.toString() ?? '0';
    final response = await http.get(
      Uri.parse('$_base/api/services/recommendations?user_id=$userIdParam'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load recommendations');
  }

  static Future<Map<String, dynamic>> getServicesByCategory(
      String categoryName,
      {int page = 1}) async {
    final currentUserId = await getCurrentUserId();
    final userIdParam = currentUserId?.toString() ?? '0';
    final uri = Uri.parse(
        '$_base/api/services/category?name=${Uri.encodeComponent(categoryName)}&page=$page&user_id=$userIdParam');
    final response = await http.get(uri);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load category');
  }

  static Future<Map<String, dynamic>> getSavedServices(
      {required int userId}) async {
    final response =
        await http.get(Uri.parse('$_base/api/services/saved?user_id=$userId'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load saved services: ${response.body}');
  }

  static Future<void> toggleSaveService(
      {required int userId, required int jasaId}) async {
    final response = await http.post(
      Uri.parse('$_base/api/services/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'jasa_id': jasaId}),
    );
    if (response.statusCode != 200) throw Exception('Failed to toggle bookmark');
  }

  // ===========================================================================
  // REVIEWS
  // ===========================================================================

  static Future<Map<String, dynamic>> getReviews(int jasaId) async {
    final response =
        await http.get(Uri.parse('$_base/api/services/$jasaId/reviews'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load reviews');
  }

  static Future<void> postReview({
    required int jasaId,
    required int userId,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/api/services/$jasaId/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      }),
    );
    if (response.statusCode != 201) throw Exception('Failed to post review');
  }

  // ===========================================================================
  // USERS / PROFILE
  // ===========================================================================

  static Future<Map<String, dynamic>> getUserProfile(
      {required int userId}) async {
    final response =
        await http.get(Uri.parse('$_base/api/users/$userId'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load profile');
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (avatarUrl != null && avatarUrl.isNotEmpty) body['avatar_url'] = avatarUrl;

    final response = await http.put(
      Uri.parse('$_base/api/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to update profile');
  }

  static Future<String> uploadAvatar(File imageFile) async {
    final uri = Uri.parse('$_base/api/upload/avatar');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('avatar', imageFile.path));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'] as String;
    }
    throw Exception('Failed to upload avatar');
  }

  // ===========================================================================
  // GOOGLE SYNC
  // ===========================================================================

  static Future<void> syncGoogleLogin({
    required String name,
    required String email,
    required String avatarUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/api/auth/sync'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'avatar_url': avatarUrl}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final realUserId = data['user']['id'] as int;
      final token = data['token'] as String?;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentUserId', realUserId);
      if (token != null) await prefs.setString('jwt_token', token);
    } else {
      throw Exception('Failed to sync Google login');
    }
  }

  // ===========================================================================
  // PROVIDER REGISTRATION
  // ===========================================================================

  static Future<Map<String, dynamic>> registerAsProvider({
    required String businessName,
    required String businessEmail,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/api/register/provider'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'business_name': businessName,
        'business_email': businessEmail,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) return data;
    throw Exception(data['error'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> createService({
    required int providerId,
    required String namaJasa,
    required String kategori,
    required String deskripsi,
    required int hargaMulai,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/api/services'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provider_id': providerId,
        'NamaJasa': namaJasa,
        'Kategori': kategori,
        'DeskripsiJasa': deskripsi,
        'HargaMulai': hargaMulai,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) return data;
    throw Exception(data['error'] ?? 'Failed to create service');
  }

  // ===========================================================================
  // CHAT
  // ===========================================================================

  static Future<Map<String, dynamic>> getOrCreateChatRoom({
    required int customerId,
    required int providerId,
    required int jasaId,
    required String jasaName,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/api/chats'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customer_id': customerId,
        'provider_id': providerId,
        'jasa_id': jasaId,
        'jasa_name': jasaName,
      }),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to create chat room');
  }

  static Future<Map<String, dynamic>> getChatRooms(int userId) async {
    final response =
        await http.get(Uri.parse('$_base/api/chats?user_id=$userId'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load chats');
  }

  static Future<Map<String, dynamic>> getChatMessages(int roomId) async {
    final response =
        await http.get(Uri.parse('$_base/api/chats/$roomId/messages'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load messages');
  }

  static String chatWebSocketUrl(int roomId, int userId) {
    // ws:// for emulator; change host when deployed
    return 'ws://10.0.2.2:8080/ws/chat/$roomId?user_id=$userId';
  }

  // ===========================================================================
  // NOTIFICATIONS
  // ===========================================================================

  static Future<Map<String, dynamic>> getNotifications(int userId) async {
    final response = await http
        .get(Uri.parse('$_base/api/notifications?user_id=$userId'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load notifications');
  }

  static Future<void> markNotificationRead(int notificationId) async {
    await http.put(Uri.parse('$_base/api/notifications/$notificationId/read'));
  }
}
