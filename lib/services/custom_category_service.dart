import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CustomCategoryService {
  static const String _customCategoriesKey = 'custom_categories';

  // Default icons for categories
  static final Map<String, IconData> _defaultIcons = {
    'all': Icons.apps,
    'web': Icons.web,
    'api': Icons.api,
    'database': Icons.storage,
    'cloud': Icons.cloud,
    'network': Icons.network_check,
    'security': Icons.security,
    'tools': Icons.build,
    'monitoring': Icons.monitor,
    'development': Icons.code,
  };

  /// Load custom categories from shared preferences
  static Future<List<Category>> loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString(_customCategoriesKey);

    if (categoriesJson == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(categoriesJson);
      return jsonList
          .map((json) {
            final category = Category.fromJson(json);
            // If we have an icon code, use it to set the icon
            if (category.iconCode != null) {
              final icon = Category.getIconFromCode(category.iconCode);
              return category.copyWith(icon: icon);
            }
            // Otherwise, use default icon based on category name
            return category.copyWith(
              icon: getIconForCategory(category.name),
            );
          })
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  /// Save custom categories to shared preferences
  static Future<void> saveCustomCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = json.encode(
      categories.map((category) => category.toJson()).toList(),
    );
    await prefs.setString(_customCategoriesKey, categoriesJson);
  }

  /// Get icon for a category
  static IconData getIconForCategory(String categoryName) {
    // Check if we have a default icon for this category
    if (_defaultIcons.containsKey(categoryName)) {
      return _defaultIcons[categoryName]!;
    }
    
    // Return a default icon if no specific icon is found
    return Icons.category;
  }
  
  /// Get all available icons for selection
  static List<IconData> getAllAvailableIcons() {
    return [
      Icons.apps,
      Icons.web,
      Icons.api,
      Icons.storage,
      Icons.cloud,
      Icons.network_check,
      Icons.security,
      Icons.build,
      Icons.monitor,
      Icons.code,
      Icons.people,
      Icons.search,
      Icons.settings,
      Icons.favorite,
      Icons.home,
      Icons.business,
      Icons.shopping_cart,
      Icons.school,
      Icons.directions_car,
      Icons.local_hospital,
      Icons.restaurant,
      Icons.music_note,
      Icons.videogame_asset,
      Icons.camera,
      Icons.phone,
      Icons.email,
    ];
  }
}