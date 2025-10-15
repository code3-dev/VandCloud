import 'package:flutter/material.dart';
import 'package:vandcloud/services/theme_service.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../widgets/category_card.dart';
import '../widgets/app_navigation.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/tv_layout.dart';
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
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService().fetchCategories();

      // Add "All" category at the beginning of the list
      final allCategory = Category(
        name: 'all',
        title: 'All',
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 3.5, // Increased aspect ratio for more height
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return CategoryCard(
                  category: _categories[index],
                  onTap: () {
                    // Navigate to API items screen when a category is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ApiItemsScreen(category: _categories[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
