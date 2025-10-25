class ApiItem {
  final String name;
  final String url;
  final String category;

  ApiItem({required this.name, required this.url, required this.category});

  factory ApiItem.fromJson(Map<String, dynamic> json) {
    return ApiItem(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? '',
    );
  }
  
  // Add toJson method for persistence
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'category': category,
    };
  }
}