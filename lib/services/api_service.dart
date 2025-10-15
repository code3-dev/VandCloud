import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_item.dart';

class ApiService {
  static const String _baseUrl =
      'https://raw.githubusercontent.com/code3-dev/code3-dev/refs/heads/main/vandcloud';

  Future<List<ApiItem>> fetchApiItems() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api.json'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ApiItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load API items');
      }
    } catch (e) {
      throw Exception('Error fetching API items: $e');
    }
  }

  Future<List<ApiItem>> fetchApiItemsByCategory(String category) async {
    try {
      final allItems = await fetchApiItems();

      if (category == 'all') {
        return allItems;
      }

      return allItems.where((item) => item.category == category).toList();
    } catch (e) {
      throw Exception('Error filtering API items: $e');
    }
  }
}
