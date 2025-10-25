import 'package:flutter/material.dart';
import '../models/category.dart';
import 'api_items_screen.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final Category category;

  const CategoryDetailsScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCustomCategory = _isCustomCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  category.icon ?? Icons.category,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Category title
            Center(
              child: Text(
                category.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            
            // Category description
            Center(
              child: Text(
                category.description,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            
            // Category type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isCustomCategory 
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCustomCategory ? 'Custom Category' : 'System Category',
                        style: TextStyle(
                          color: isCustomCategory 
                              ? Colors.orange
                              : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApiItemsScreen(category: category),
                    ),
                  );
                },
                child: const Text('View Items'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isCustomCategory(Category category) {
    // Custom categories are those that aren't system categories
    final systemCategories = ['all', 'engine', 'ai', 'social', 'tools', 'developer'];
    return !systemCategories.contains(category.name);
  }
}