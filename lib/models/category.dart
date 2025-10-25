import 'package:flutter/material.dart';

class Category {
  final String name;
  final String title;
  final String description;
  final IconData? icon;
  final String? iconCode; // Add icon code for persistence

  Category({
    required this.name,
    required this.title,
    required this.description,
    this.icon,
    this.iconCode, // Add icon code parameter
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // When creating from JSON, we don't have icon information directly
    // We'll store the icon code and set the icon later
    return Category(
      name: json['name'],
      title: json['title'],
      description: json['description'],
      iconCode: json['iconCode'], // Load icon code if available
    );
  }

  // Add a method to convert to JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'description': description,
      'iconCode': iconCode ?? _getIconCode(icon), // Save icon code
    };
  }

  // Add a copyWith method for easier updates
  Category copyWith({
    String? name,
    String? title,
    String? description,
    IconData? icon,
    String? iconCode,
  }) {
    return Category(
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      iconCode: iconCode ?? this.iconCode,
    );
  }

  // Helper method to get icon code from IconData
  static String? _getIconCode(IconData? icon) {
    if (icon == null) return null;
    return '${icon.codePoint}:${icon.fontFamily ?? 'MaterialIcons'}';
  }

  // Helper method to get IconData from icon code
  static IconData? getIconFromCode(String? iconCode) {
    if (iconCode == null) return null;
    
    try {
      final parts = iconCode.split(':');
      if (parts.length != 2) return null;
      
      final codePoint = int.tryParse(parts[0]);
      if (codePoint == null) return null;
      
      final fontFamily = parts[1];
      
      // Create IconData based on the code point and font family
      return IconData(codePoint, fontFamily: fontFamily);
    } catch (e) {
      return null;
    }
  }
}