import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback? onLongPress; // Add long press callback

  const CategoryCard({Key? key, required this.category, required this.onTap, this.onLongPress})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode
        ? Color(0xFF2D2D3A) // Dark card background
        : Colors.white;
    final iconBgColor = isDarkMode
        ? Color(0xFF3D3D4A) // Darker icon background for dark mode
        : Theme.of(context).primaryColor.withOpacity(0.1);
    final titleColor = isDarkMode
        ? Colors.white
        : Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress, // Add long press handler
          borderRadius: BorderRadius.circular(16),
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category), // Update to use the category object
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(Category category) {
    // Use the category's icon if it has one
    if (category.icon != null) {
      return category.icon!;
    }
    
    // Fall back to the original logic for system categories
    switch (category.name) {
      case 'engine':
        return Icons.search_rounded;
      case 'ai':
        return Icons.auto_awesome_rounded;
      case 'social':
        return Icons.people_alt_rounded;
      case 'tools':
        return Icons.build_rounded;
      case 'developer':
        return Icons.code_rounded;
      case 'all':
        return Icons.apps;
      default:
        return Icons.category_rounded;
    }
  }
}