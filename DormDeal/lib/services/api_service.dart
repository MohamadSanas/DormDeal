import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/item.dart';
import '../models/user.dart';
import '../models/bid_item.dart';
import '../models/notification_model.dart';

class ApiService {
  static String? token;
  static User? currentUser;

  static Map<String, String> get authHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  String get baseUrl {
    try {
      final configured = dotenv.env['API_BASE_URL'];
      if (configured != null && configured.isNotEmpty) {
        return configured;
      }
    } catch (_) {}

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://127.0.0.1:8000/api/v1';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000/api/v1';
  }

  // ── Authentication ──────────────────────────────────────────────────────────
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      token = data['access_token'];
      currentUser = User.fromJson(data['user']);
      return currentUser!;
    } else {
      final msg = data is Map<String, dynamic> ? data['detail'] : null;
      throw Exception(msg ?? 'Login failed. Please check credentials.');
    }
  }

  Future<User> signup({
    required String name,
    required String email,
    required String password,
    String? whatsappNumber,
    String? university,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'whatsapp_number': whatsappNumber ?? '',
        'university': university ?? '',
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      token = data['access_token'];
      currentUser = User.fromJson(data['user']);
      return currentUser!;
    } else {
      final msg = data is Map<String, dynamic> ? data['detail'] : null;
      throw Exception(msg ?? 'Sign up failed.');
    }
  }

  void logout() {
    token = null;
    currentUser = null;
  }

  // ── Items ───────────────────────────────────────────────────────────────────
  Future<List<Item>> getItems({int limit = 50, String? category, String? search}) async {
    final params = <String, String>{'limit': limit.toString()};
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all items') {
      params['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final uri = Uri.parse('$baseUrl/items/').replace(queryParameters: params);
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Item.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load items: HTTP ${response.statusCode}');
    }
  }

  Future<Item> getItem(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/items/$id')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return Item.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load item');
  }

  Future<List<Item>> getMyListings() async {
    if (token == null) return [];
    final response = await http
        .get(Uri.parse('$baseUrl/items/mine'), headers: authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Item.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load my listings');
    }
  }

  Future<Item> createItem({
    required String title,
    required double basePrice,
    required int auctionHours,
    required String whatsappNumber,
    String? description,
    String? category,
    XFile? image,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/items/'));

    if (token != null && token!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['title'] = title;
    request.fields['base_price'] = basePrice.toString();
    request.fields['auction_hours'] = auctionHours.toString();
    request.fields['whatsapp_number'] = whatsappNumber;

    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }
    if (category != null && category.isNotEmpty) {
      request.fields['category'] = category;
    }

    if (image != null) {
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: image.name,
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Item.fromJson(json.decode(response.body));
    } else {
      final decoded = json.decode(response.body);
      final msg = decoded is Map<String, dynamic> ? decoded['detail'] : null;
      throw Exception(msg ?? 'Failed to create item');
    }
  }

  Future<void> deleteItem(String itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/items/$itemId'),
      headers: authHeaders,
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete item');
    }
  }

  // ── Bids ────────────────────────────────────────────────────────────────────
  Future<Item> placeBid({
    required String itemId,
    required String bidderName,
    required String bidderWhatsapp,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items/$itemId/bids'),
      headers: authHeaders,
      body: json.encode({
        'bidder_name': bidderName,
        'bidder_whatsapp': bidderWhatsapp,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      return Item.fromJson(json.decode(response.body));
    }
    final decoded = json.decode(response.body);
    final message = decoded is Map<String, dynamic> ? decoded['detail'] : null;
    throw Exception(message ?? 'Failed to place bid');
  }

  Future<List<BidItem>> getMyBids() async {
    if (token == null) return [];
    final response = await http
        .get(Uri.parse('$baseUrl/bids/mine'), headers: authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((b) => BidItem.fromJson(b)).toList();
    } else {
      throw Exception('Failed to load my bids');
    }
  }

  // ── Notifications ───────────────────────────────────────────────────────────
  Future<List<AppNotification>> getNotifications() async {
    if (token == null) return [];
    final response = await http
        .get(Uri.parse('$baseUrl/notifications/'), headers: authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((n) => AppNotification.fromJson(n)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> markNotificationRead(String id) async {
    await http.patch(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: authHeaders,
    );
  }

  Future<void> markAllNotificationsRead() async {
    await http.patch(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: authHeaders,
    );
  }
}
