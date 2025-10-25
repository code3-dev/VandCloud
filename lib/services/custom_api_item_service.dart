import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_item.dart';

class CustomApiItemService {
  static const String _customApiItemsKey = 'custom_api_items';

  /// Load custom API items from shared preferences
  static Future<List<ApiItem>> loadCustomApiItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_customApiItemsKey);

    if (itemsJson == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(itemsJson);
      return jsonList
          .map((json) => ApiItem.fromJson(json))
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  /// Save custom API items to shared preferences
  static Future<void> saveCustomApiItems(List<ApiItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = json.encode(
      items.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_customApiItemsKey, itemsJson);
  }

  /// Get custom API items for a specific category
  static Future<List<ApiItem>> getCustomApiItemsForCategory(String categoryName) async {
    final allItems = await loadCustomApiItems();
    return allItems.where((item) => item.category == categoryName).toList();
  }

  /// Add a new custom API item
  static Future<void> addCustomApiItem(ApiItem item) async {
    final items = await loadCustomApiItems();
    items.add(item);
    await saveCustomApiItems(items);
  }

  /// Update an existing custom API item
  static Future<void> updateCustomApiItem(String originalName, ApiItem updatedItem) async {
    final items = await loadCustomApiItems();
    final index = items.indexWhere((item) => item.name == originalName);
    if (index != -1) {
      items[index] = updatedItem;
      await saveCustomApiItems(items);
    }
  }

  /// Delete a custom API item
  static Future<void> deleteCustomApiItem(String itemName) async {
    final items = await loadCustomApiItems();
    items.removeWhere((item) => item.name == itemName);
    await saveCustomApiItems(items);
  }
}