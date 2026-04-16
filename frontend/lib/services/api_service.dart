import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  String get baseUrl {
    try {
      final configured = dotenv.env['API_BASE_URL'];
      if (configured != null && configured.isNotEmpty) {
        return configured;
      }
    } catch (_) {
      // Dotenv is optional in dev; use a sensible platform default.
    }

    return kIsWeb
        ? 'http://127.0.0.1:8000/api/v1'
        : 'http://127.0.0.1:8000/api/v1';
  }

  Future<List<Item>> getItems({int limit = 50}) async {
    final response = await http.get(Uri.parse('$baseUrl/items/?limit=$limit'));
    
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Item.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<Item> createItem({
    required String title,
    required double basePrice,
    required int auctionHours,
    required String whatsappNumber,
    String? description,
    XFile? image,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/items/'));
    
    request.fields['title'] = title;
    request.fields['base_price'] = basePrice.toString();
    request.fields['auction_hours'] = auctionHours.toString();
    request.fields['whatsapp_number'] = whatsappNumber;
    
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Item.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create item');
    }
  }

  Future<Item> placeBid({
    required String itemId,
    required String bidderName,
    required String bidderWhatsapp,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items/$itemId/bids'),
      headers: {'Content-Type': 'application/json'},
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
}
