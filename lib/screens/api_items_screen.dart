import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import '../models/api_item.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/timeout_service.dart';

class ApiItemsScreen extends StatefulWidget {
  final Category category;

  const ApiItemsScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<ApiItemsScreen> createState() => _ApiItemsScreenState();
}

class _ApiItemsScreenState extends State<ApiItemsScreen> {
  List<ApiItem> _apiItems = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isTesting = false;
  Map<String, HostStatus> _hostStatuses = {};
  int _timeoutSeconds = 30;

  // Filter and sort options
  bool _hideFailedItems = false;
  SortOption _sortOption = SortOption.name;

  @override
  void initState() {
    super.initState();
    _loadApiItems();
    _loadTimeoutSetting();
  }

  Future<void> _loadApiItems() async {
    try {
      final apiItems = await ApiService().fetchApiItemsByCategory(
        widget.category.name,
      );

      setState(() {
        _apiItems = apiItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load API items: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTimeoutSetting() async {
    final timeout = await TimeoutService.loadTimeout();
    setState(() {
      _timeoutSeconds = timeout;
    });
  }

  Future<void> _testAllHosts() async {
    // Reload timeout setting in case it changed
    await _loadTimeoutSetting();

    setState(() {
      _isTesting = true;
      _hostStatuses.clear();
    });

    for (var item in _apiItems) {
      if (item.url.isNotEmpty) {
        await _testHost(item);
      } else {
        setState(() {
          _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
        });
      }
    }

    setState(() {
      _isTesting = false;
    });
  }

  Future<void> _testHost(ApiItem item) async {
    final uri = Uri.parse(item.url);

    try {
      final stopwatch = Stopwatch()..start();

      // Use a very short timeout (500ms) for immediate failure detection
      final timeout = Duration(milliseconds: 500);

      final response = await http.get(uri).timeout(timeout);
      stopwatch.stop();

      final ping = stopwatch.elapsedMilliseconds;

      setState(() {
        _hostStatuses[item.name] = HostStatus(
          isSuccess: response.statusCode == 200,
          ping: ping,
        );
      });
    } on FormatException {
      // Handle invalid URLs immediately
      setState(() {
        _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
      });
    } on SocketException {
      // Handle network errors immediately (DNS, connection refused, etc.)
      setState(() {
        _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
      });
    } on TimeoutException {
      // For timeout, we assume it's a slow server and try with full timeout
      try {
        final fullTimeout = Duration(seconds: _timeoutSeconds);
        final stopwatch = Stopwatch()..start();
        final response = await http.get(uri).timeout(fullTimeout);
        stopwatch.stop();

        final ping = stopwatch.elapsedMilliseconds;

        setState(() {
          _hostStatuses[item.name] = HostStatus(
            isSuccess: response.statusCode == 200,
            ping: ping,
          );
        });
      } on TimeoutException {
        // Full timeout also failed
        setState(() {
          _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
        });
      } catch (e) {
        // Handle any other errors
        setState(() {
          _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
        });
      }
    } catch (e) {
      // Handle any other errors immediately
      setState(() {
        _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
      });
    }
  }

  void _toggleHideFailedItems() {
    setState(() {
      _hideFailedItems = !_hideFailedItems;
    });
  }

  void _setSortOption(SortOption option) {
    setState(() {
      _sortOption = option;
    });
  }

  List<ApiItem> _getFilteredAndSortedItems() {
    // Apply filter
    List<ApiItem> filteredItems = _apiItems;

    if (_hideFailedItems) {
      filteredItems = filteredItems.where((item) {
        final status = _hostStatuses[item.name];
        return status == null || status.ping != -1;
      }).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case SortOption.name:
        filteredItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.ping:
        filteredItems.sort((a, b) {
          final statusA = _hostStatuses[a.name];
          final statusB = _hostStatuses[b.name];

          // Items without status come last
          if (statusA == null && statusB == null) return 0;
          if (statusA == null) return 1;
          if (statusB == null) return -1;

          // Failed items (-1 ping) come last
          if (statusA.ping == -1 && statusB.ping == -1) return 0;
          if (statusA.ping == -1) return 1;
          if (statusB.ping == -1) return -1;

          // Sort by ping ascending
          return statusA.ping.compareTo(statusB.ping);
        });
        break;
    }

    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: _isTesting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.network_check),
            onPressed: _isTesting ? null : _testAllHosts,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String result) {
              switch (result) {
                case 'hide_failed':
                  _toggleHideFailedItems();
                  break;
                case 'sort_ping':
                  _setSortOption(SortOption.ping);
                  break;
                case 'sort_name':
                  _setSortOption(SortOption.name);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'hide_failed',
                child: Row(
                  children: [
                    Icon(
                      _hideFailedItems
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: _hideFailedItems ? Colors.red : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _hideFailedItems
                          ? 'Show Failed Items'
                          : 'Hide Failed Items',
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'sort_ping',
                child: Row(
                  children: [
                    Icon(
                      _sortOption == SortOption.ping
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: _sortOption == SortOption.ping
                          ? Colors.green
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sort by Ping'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'sort_name',
                child: Row(
                  children: [
                    Icon(
                      _sortOption == SortOption.name
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: _sortOption == SortOption.name
                          ? Colors.green
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sort by Name'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
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
              onPressed: _loadApiItems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredAndSortedItems = _getFilteredAndSortedItems();

    if (filteredAndSortedItems.isEmpty) {
      return const Center(child: Text('No API items found for this category'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredAndSortedItems.length,
      itemBuilder: (context, index) {
        final item = filteredAndSortedItems[index];
        final status = _hostStatuses[item.name];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(item.name),
            subtitle: Row(
              children: [
                Text(item.category),
                if (status != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: status.isSuccess ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status.isSuccess ? 'OK' : 'FAIL',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status.isSuccess ? '${status.ping}ms' : '-1ms',
                    style: TextStyle(
                      color: status.isSuccess ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle item tap - you can implement navigation to detail view here
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Tapped on ${item.name}')));
            },
          ),
        );
      },
    );
  }
}

class HostStatus {
  final bool isSuccess;
  final int ping;

  HostStatus({required this.isSuccess, required this.ping});
}

enum SortOption { name, ping }
