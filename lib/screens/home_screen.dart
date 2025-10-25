import 'package:flutter/material.dart';
import 'package:vandcloud/services/theme_service.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/custom_category_service.dart';
import '../widgets/category_card.dart';
import '../widgets/app_navigation.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/tv_layout.dart';
import '../screens/category_details_screen.dart';
import 'settings_screen.dart';
import 'api_items_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(AppTheme)? onThemeChanged;

  const HomeScreen({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Category> _categories = [];
  List<Category> _customCategories = []; // Add custom categories list
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCustomCategories(); // Load custom categories
  }

  Future<void> _loadCategories() async {
    try {
      // Reset loading state and error message when retrying
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final categories = await CategoryService().fetchCategories();

      // Add "All" category at the beginning of the list
      final allCategory = Category(
        name: 'all',
        title: 'All Categories',
        description: 'View all categories',
      );

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _categories = [allCategory, ...categories];
          _isLoading = false;
        });
      }
    } catch (e) {
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load categories: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Load custom categories
  Future<void> _loadCustomCategories() async {
    try {
      final customCategories = await CustomCategoryService.loadCustomCategories();
      
      // Add icons to custom categories (they should already have icons from the service)
      if (mounted) {
        setState(() {
          _customCategories = customCategories;
        });
      }
    } catch (e) {
      // Handle error silently
      print('Error loading custom categories: $e');
    }
  }

  /// Save custom categories
  Future<void> _saveCustomCategories() async {
    try {
      await CustomCategoryService.saveCustomCategories(_customCategories);
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving categories: $e')),
        );
      }
    }
  }

  /// Add a new custom category
  Future<void> _addCustomCategory() async {
    final newCategory = await _showCategoryDialog();
    if (newCategory != null) {
      // The icon is already set in the dialog, so we just need to add it to our list
      setState(() {
        _customCategories = [..._customCategories, newCategory];
      });
      
      await _saveCustomCategories();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
      }
    }
  }

  /// Edit a custom category
  Future<void> _editCustomCategory(int index) async {
    final categoryToEdit = _customCategories[index];
    final updatedCategory = await _showCategoryDialog(categoryToEdit);
    
    if (updatedCategory != null) {
      setState(() {
        _customCategories = List.from(_customCategories)
          ..[index] = updatedCategory;
      });
      
      await _saveCustomCategories();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      }
    }
  }

  /// Delete a custom category
  Future<void> _deleteCustomCategory(int index) async {
    setState(() {
      _customCategories = List.from(_customCategories)..removeAt(index);
    });
    
    await _saveCustomCategories();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully')),
      );
    }
  }

  /// Show category dialog for add/edit
  Future<Category?> _showCategoryDialog([Category? category]) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final titleController = TextEditingController(text: category?.title ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');

    IconData? selectedIcon = category?.icon;

    return showDialog<Category>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(category == null ? 'Add Category' : 'Edit Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter category name',
                      ),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter category title',
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter category description',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Select Icon'),
                      subtitle: Text(selectedIcon != null 
                          ? 'Selected: ${selectedIcon!.codePoint}' 
                          : 'No icon selected'),
                      trailing: selectedIcon != null 
                          ? Icon(selectedIcon) 
                          : const Icon(Icons.image_not_supported),
                      onTap: () async {
                        // Use a simple icon selection instead of the icon picker
                        final selected = await _showIconSelectionDialog(context);
                        if (selected != null) {
                          setState(() {
                            selectedIcon = selected;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isEmpty || titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name and title are required')),
                      );
                      return;
                    }
                    
                    final category = Category(
                      name: nameController.text,
                      title: titleController.text,
                      description: descriptionController.text,
                      icon: selectedIcon,
                      // iconCode will be automatically set in the toJson method
                    );
                    
                    Navigator.of(context).pop(category);
                  },
                  child: Text(category == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;

      // Navigate to the appropriate screen
      if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SettingsScreen(onThemeChanged: widget.onThemeChanged),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      tabletBody: _buildTabletLayout(),
      desktopBody: _buildDesktopLayout(),
      tvBody: _buildTvLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VandCloud'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addCustomCategory,
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: _buildBodyContent(1), // 1 column for mobile
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigationChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VandCloud'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addCustomCategory,
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: Row(
        children: [
          AppNavigation(
            currentIndex: _selectedIndex,
            onDestinationSelected: _onNavigationChanged,
          ),
          Expanded(
            child: _buildBodyContent(2), // 2 columns for tablet
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          AppNavigation(
            currentIndex: _selectedIndex,
            onDestinationSelected: _onNavigationChanged,
          ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: const Text('VandCloud'),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _addCustomCategory,
                      tooltip: 'Add Category',
                    ),
                  ],
                ),
                Expanded(
                  child: _buildBodyContent(4), // 4 columns for desktop
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTvLayout() {
    return TvLayout(
      currentIndex: _selectedIndex,
      onDestinationSelected: _onNavigationChanged,
      child: _buildBodyContent(5), // 5 columns for TV
    );
  }

  Widget _buildBodyContent(int crossAxisCount) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Combine system categories and custom categories
    final allCategories = [..._categories, ..._customCategories];

    // Add minimal padding at top and bottom
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Minimal vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 3.5, // Increased aspect ratio for more height
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final category = allCategories[index];
                final isCustomCategory = index >= _categories.length;
                final customIndex = index - _categories.length;

                return CategoryCard(
                  category: category,
                  onTap: () {
                    // Navigate to category details screen when a category is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailsScreen(category: category),
                      ),
                    );
                  },
                  onLongPress: isCustomCategory 
                    ? () => _showCategoryOptions(customIndex) 
                    : null, // Only custom categories can be edited/deleted
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Show options for a custom category (edit/delete)
  void _showCategoryOptions(int index) {
    final category = _customCategories[index];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Category name
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Options
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Category'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  _editCustomCategory(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Category'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  _deleteCustomCategory(index);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show a simple icon selection dialog
  Future<IconData?> _showIconSelectionDialog(BuildContext context) async {
    final List<IconData> icons = CustomCategoryService.getAllAvailableIcons();

    return showDialog<IconData>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select an Icon'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                return IconButton(
                  icon: Icon(icons[index]),
                  onPressed: () {
                    Navigator.of(context).pop(icons[index]);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}