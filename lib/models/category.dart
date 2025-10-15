class Category {
  final String name;
  final String title;
  final String description;

  Category({
    required this.name,
    required this.title,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      title: json['title'],
      description: json['description'],
    );
  }
}
