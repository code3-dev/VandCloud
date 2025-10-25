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
      // Use a constant constructor when possible to enable tree shaking
      if (fontFamily == 'MaterialIcons') {
        // For Material Icons, we can use the Icons class which provides constant IconData
        // This is a simplified approach - in a real app, you might want to map more icons
        return _getMaterialIcon(codePoint);
      } else {
        // For other font families, we have to create dynamic IconData
        // This will still cause issues with tree shaking, but we've added --no-tree-shake-icons flag
        return IconData(codePoint, fontFamily: fontFamily);
      }
    } catch (e) {
      return null;
    }
  }
  
  // Helper method to get Material Icons as constants when possible
  static IconData? _getMaterialIcon(int codePoint) {
    // This is a simplified mapping - in a production app you might want to map more icons
    // The key is to use constant IconData from the Icons class when possible
    switch (codePoint) {
      case 0xe000: return Icons.add;
      case 0xe001: return Icons.apps;
      case 0xe002: return Icons.api;
      case 0xe003: return Icons.storage;
      case 0xe004: return Icons.cloud;
      case 0xe005: return Icons.network_check;
      case 0xe006: return Icons.security;
      case 0xe007: return Icons.build;
      case 0xe008: return Icons.monitor;
      case 0xe009: return Icons.code;
      case 0xe00a: return Icons.people;
      case 0xe00b: return Icons.search;
      case 0xe00c: return Icons.settings;
      case 0xe00d: return Icons.favorite;
      case 0xe00e: return Icons.home;
      case 0xe00f: return Icons.business;
      case 0xe010: return Icons.shopping_cart;
      case 0xe011: return Icons.school;
      case 0xe012: return Icons.directions_car;
      case 0xe013: return Icons.local_hospital;
      case 0xe014: return Icons.restaurant;
      case 0xe015: return Icons.music_note;
      case 0xe016: return Icons.videogame_asset;
      case 0xe017: return Icons.camera;
      case 0xe018: return Icons.phone;
      case 0xe019: return Icons.email;
      case 0xe01a: return Icons.web;
      case 0xe01b: return Icons.category;
      // Add more mappings as needed
      default: 
        // For unmapped icons, create dynamic IconData
        // This will still cause issues with tree shaking, but we've added --no-tree-shake-icons flag
        return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
  }
}