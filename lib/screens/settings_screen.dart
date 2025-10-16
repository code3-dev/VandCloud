import 'package:flutter/material.dart';
import 'package:vandcloud/services/theme_service.dart';
import '../services/timeout_service.dart'; // Add this import
import '../widgets/responsive_layout.dart';
import '../widgets/app_navigation.dart';
import '../widgets/tv_layout.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(AppTheme)? onThemeChanged;

  const SettingsScreen({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 1;
  AppTheme _selectedTheme = AppTheme.system;
  int _timeoutSeconds = 30; // Add timeout setting

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _loadTimeoutSetting(); // Load timeout setting
  }

  // Load the saved theme preference
  Future<void> _loadThemePreference() async {
    final theme = await ThemeService.loadThemePreference();
    setState(() {
      _selectedTheme = theme;
    });
  }

  // Save theme preference and notify the app
  Future<void> _saveThemePreference(AppTheme theme) async {
    await ThemeService.saveThemePreference(theme);
    setState(() {
      _selectedTheme = theme;
    });

    // Notify the app about theme change
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(theme);
    }
  }

  // Load timeout setting
  Future<void> _loadTimeoutSetting() async {
    final timeout = await TimeoutService.loadTimeout();
    setState(() {
      _timeoutSeconds = timeout;
    });
  }

  // Save timeout setting
  Future<void> _saveTimeoutSetting(int timeout) async {
    await TimeoutService.saveTimeout(timeout);
    setState(() {
      _timeoutSeconds = timeout;
    });
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;
      // Navigate to the appropriate screen
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(onThemeChanged: widget.onThemeChanged),
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
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildSettingsContent(),
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
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          AppNavigation(
            currentIndex: _selectedIndex,
            onDestinationSelected: _onNavigationChanged,
          ),
          Expanded(child: _buildSettingsContent()),
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
                  title: const Text('Settings'),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                Expanded(child: _buildSettingsContent()),
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
      child: _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('System Default'),
                      leading: Radio<AppTheme>(
                        value: AppTheme.system,
                        groupValue: _selectedTheme,
                        onChanged: (AppTheme? value) {
                          if (value != null) {
                            _saveThemePreference(value);
                          }
                        },
                      ),
                      onTap: () {
                        _saveThemePreference(AppTheme.system);
                      },
                    ),
                    ListTile(
                      title: const Text('Light'),
                      leading: Radio<AppTheme>(
                        value: AppTheme.light,
                        groupValue: _selectedTheme,
                        onChanged: (AppTheme? value) {
                          if (value != null) {
                            _saveThemePreference(value);
                          }
                        },
                      ),
                      onTap: () {
                        _saveThemePreference(AppTheme.light);
                      },
                    ),
                    ListTile(
                      title: const Text('Dark'),
                      leading: Radio<AppTheme>(
                        value: AppTheme.dark,
                        groupValue: _selectedTheme,
                        onChanged: (AppTheme? value) {
                          if (value != null) {
                            _saveThemePreference(value);
                          }
                        },
                      ),
                      onTap: () {
                        _saveThemePreference(AppTheme.dark);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Network',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Timeout',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Timeout Duration'),
                      subtitle: Text('$_timeoutSeconds seconds'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showTimeoutDialog();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'About',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.code,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Developed by Hossein Pira',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '2025 IRCF',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeoutDialog() {
    TextEditingController controller = TextEditingController(
      text: _timeoutSeconds.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Timeout'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Timeout in seconds',
              hintText: 'Enter timeout duration',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final input = controller.text;
                if (input.isNotEmpty) {
                  final timeout = int.tryParse(input) ?? 30;
                  // Ensure timeout is between 5 and 300 seconds
                  final validTimeout = timeout.clamp(5, 300);
                  _saveTimeoutSetting(validTimeout);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
