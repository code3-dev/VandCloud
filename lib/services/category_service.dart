import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';

class CategoryService {
  static const String _baseUrl =
      'https://raw.githubusercontent.com/code3-dev/code3-dev/refs/heads/main/vandcloud';

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories.json'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
