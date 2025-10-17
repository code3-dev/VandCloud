import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../models/api_item.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/timeout_service.dart';
import '../widgets/results_chart_card.dart';

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
      // Reset loading state and error message when retrying
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final apiItems = await ApiService().fetchApiItemsByCategory(
        widget.category.name,
      );

      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _apiItems = apiItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load API items: $e';
          _isLoading = false;
        });
      }
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

    try {
      // Process items in small batches to prevent overwhelming the device
      // This prevents crashes on Android devices with limited resources
      const batchSize = 5;

      for (var i = 0; i < _apiItems.length; i += batchSize) {
        // Take a batch of items
        final batchEnd = (i + batchSize < _apiItems.length)
            ? i + batchSize
            : _apiItems.length;
        final batch = _apiItems.sublist(i, batchEnd);

        // Create futures for this batch
        final batchFutures = <Future>[];

        for (var item in batch) {
          if (item.url.isNotEmpty) {
            batchFutures.add(_testHost(item));
          } else {
            // Handle items with empty URLs immediately
            if (mounted) {
              setState(() {
                _hostStatuses[item.name] = HostStatus(
                  isSuccess: false,
                  ping: -1,
                );
              });
            }
          }
        }

        // Wait for all items in this batch to complete
        if (batchFutures.isNotEmpty) {
          await Future.wait(batchFutures);
        }

        // Small delay between batches to prevent overwhelming the system
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      // Log error but don't crash the app
      print('Error during host testing: $e');
    } finally {
      // Ensure we always reset the testing state
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  Future<void> _testHost(ApiItem item) async {
    try {
      final uri = Uri.parse(item.url);

      try {
        final stopwatch = Stopwatch()..start();

        // Use a very short timeout (500ms) for immediate failure detection
        final timeout = Duration(milliseconds: 500);

        final response = await http.get(uri).timeout(timeout);
        stopwatch.stop();

        final ping = stopwatch.elapsedMilliseconds;

        // Check if widget is still mounted before updating state
        if (mounted) {
          setState(() {
            _hostStatuses[item.name] = HostStatus(
              isSuccess: response.statusCode == 200,
              ping: ping,
            );
          });
        }
      } on FormatException {
        // Handle invalid URLs immediately
        if (mounted) {
          setState(() {
            _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
          });
        }
      } on SocketException {
        // Handle network errors immediately (DNS, connection refused, etc.)
        if (mounted) {
          setState(() {
            _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
          });
        }
      } on TimeoutException {
        // For timeout, we assume it's a slow server and try with full timeout
        try {
          final fullTimeout = Duration(seconds: _timeoutSeconds);
          final stopwatch = Stopwatch()..start();
          final response = await http.get(uri).timeout(fullTimeout);
          stopwatch.stop();

          final ping = stopwatch.elapsedMilliseconds;

          if (mounted) {
            setState(() {
              _hostStatuses[item.name] = HostStatus(
                isSuccess: response.statusCode == 200,
                ping: ping,
              );
            });
          }
        } on TimeoutException {
          // Full timeout also failed
          if (mounted) {
            setState(() {
              _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
            });
          }
        } catch (e) {
          // Handle any other errors
          if (mounted) {
            setState(() {
              _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
            });
          }
        }
      } catch (e) {
        // Handle any other errors immediately
        if (mounted) {
          setState(() {
            _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
          });
        }
      }
    } catch (e) {
      // Handle any errors in the overall process
      if (mounted) {
        setState(() {
          _hostStatuses[item.name] = HostStatus(isSuccess: false, ping: -1);
        });
      }
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

  // Helper method to calculate success and failed counts
  ({int success, int failed}) _calculateResults() {
    int successCount = 0;
    int failedCount = 0;

    for (final item in _apiItems) {
      final status = _hostStatuses[item.name];
      if (status != null) {
        if (status.isSuccess) {
          successCount++;
        } else {
          failedCount++;
        }
      }
    }

    return (success: successCount, failed: failedCount);
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
                      // Use theme-appropriate color
                      color: _hideFailedItems
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).iconTheme.color,
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
                      // Use theme-appropriate color
                      color: _sortOption == SortOption.ping
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).iconTheme.color,
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
                      // Use theme-appropriate color
                      color: _sortOption == SortOption.name
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).iconTheme.color,
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
    final results = _calculateResults();

    if (filteredAndSortedItems.isEmpty) {
      return const Center(child: Text('No API items found for this category'));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Results chart card - only show when we have test results
        if (results.success + results.failed > 0)
          ResultsChartCard(
            successCount: results.success,
            failedCount: results.failed,
            isTesting: _isTesting,
          ),
        // List of API items
        ...filteredAndSortedItems.map((item) {
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
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  _showItemOptionsModal(context, item);
                },
              ),
              onTap: () {
                _showItemOptionsModal(context, item);
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  // Show modal with options for an API item
  void _showItemOptionsModal(BuildContext context, ApiItem item) {
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
              // Item name
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Options
              ListTile(
                leading: const Icon(Icons.open_in_browser, color: Colors.blue),
                title: const Text('Open in Browser'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  _openInBrowser(item.url);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.green),
                title: const Text('Copy Link'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  _copyLink(item.url);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
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

  // Open URL in browser
  Future<void> _openInBrowser(String url) async {
    if (url.isEmpty) return;

    try {
      // Ensure URL has a proper scheme
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        // Check if it looks like a domain name before adding https
        if (url.contains('.') && !url.contains(' ')) {
          formattedUrl = 'https://$url';
        } else {
          // If it doesn't look like a valid URL, show an error
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Invalid URL format')));
          }
          return;
        }
      }

      final uri = Uri.parse(formattedUrl);
      print('Attempting to launch URL: $formattedUrl'); // Debug log

      if (await canLaunchUrl(uri)) {
        print('canLaunchUrl returned true for: $formattedUrl'); // Debug log
        await launchUrl(uri);
      } else {
        print('canLaunchUrl returned false for: $formattedUrl'); // Debug log

        // Try launching anyway, as canLaunchUrl can sometimes return false incorrectly
        try {
          await launchUrl(uri);
          print('launchUrl succeeded despite canLaunchUrl returning false');
        } catch (launchError) {
          print('launchUrl failed with error: $launchError');

          // Show error to user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open URL: $formattedUrl')),
            );
          }
        }
      }
    } catch (e) {
      print('Exception while launching URL: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening URL: $e')));
      }
    }
  }

  // Copy URL to clipboard
  Future<void> _copyLink(String url) async {
    if (url.isEmpty) return;

    try {
      // Ensure URL has a proper scheme for copying
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        // Check if it looks like a domain name before adding https
        if (url.contains('.') && !url.contains(' ')) {
          formattedUrl = 'https://$url';
        } else {
          // If it doesn't look like a valid URL, show an error
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Invalid URL format')));
          }
          return;
        }
      }

      await Clipboard.setData(ClipboardData(text: formattedUrl));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error copying link: $e')));
      }
    }
  }
}

class HostStatus {
  final bool isSuccess;
  final int ping;

  HostStatus({required this.isSuccess, required this.ping});
}

enum SortOption { name, ping }
