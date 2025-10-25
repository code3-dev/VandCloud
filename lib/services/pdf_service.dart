import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart'; // Add permission handler
import '../models/api_item.dart';
import '../models/category.dart';
import '../screens/api_items_screen.dart'; // Import HostStatus from API items screen

class PdfService {
  /// Generate a PDF report for API test results
  static Future<String> generateApiTestReport({
    required Category category,
    required List<ApiItem> apiItems,
    required Map<String, HostStatus> hostStatuses, // Use HostStatus from API items screen
  }) async {
    // Debug information
    print('Generating PDF report');
    print('Category: ${category.title}');
    print('API Items count: ${apiItems.length}');
    print('Host statuses count: ${hostStatuses.length}');
    
    final pdf = pw.Document();

    // Calculate statistics
    final totalItems = apiItems.length;
    int successCount = 0;
    int failedCount = 0;
    
    for (final item in apiItems) {
      final status = hostStatuses[item.name];
      if (status != null) {
        if (status.isSuccess) {
          successCount++;
        } else {
          failedCount++;
        }
      }
    }
    
    print('Success count: $successCount, Failed count: $failedCount');

    // Create the first page with summary information
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'VandCloud API Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      DateTime.now().toString().split(' ')[0],
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Category information
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      category.title,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      category.description,
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Summary statistics
              pw.Row(
                children: [
                  _buildStatCard('Total Items', totalItems.toString(), PdfColors.blue),
                  pw.SizedBox(width: 20),
                  _buildStatCard('Success', successCount.toString(), PdfColors.green),
                  pw.SizedBox(width: 20),
                  _buildStatCard('Failed', failedCount.toString(), PdfColors.red),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Success rate chart
              pw.Text(
                'Success Rate',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildSuccessRateChart(successCount, failedCount),
              
              pw.SizedBox(height: 20),
              
              // Indicate that detailed results are on the next page
              pw.Text(
                'Detailed results are on the following page(s)',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Create additional pages for detailed results
    if (apiItems.isNotEmpty) {
      _addDetailedResultsPages(pdf, apiItems, hostStatuses);
    }

    // Save the PDF to Downloads folder
    final String filePath = await _getDownloadsPath();
    final file = File(filePath);
    
    // Create directory if it doesn't exist
    await file.parent.create(recursive: true);
    
    await file.writeAsBytes(await pdf.save());
    
    print('PDF saved to: $filePath');
    
    return file.path;
  }

  /// Add detailed results pages to the PDF
  static void _addDetailedResultsPages(
    pw.Document pdf,
    List<ApiItem> apiItems,
    Map<String, HostStatus> hostStatuses,
  ) {
    const itemsPerPage = 20; // Number of items per page
    final totalPages = (apiItems.length / itemsPerPage).ceil();
    
    for (int page = 0; page < totalPages; page++) {
      final start = page * itemsPerPage;
      final end = (start + itemsPerPage < apiItems.length) 
          ? start + itemsPerPage 
          : apiItems.length;
      final pageItems = apiItems.sublist(start, end);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                // Page header
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Detailed Results (Page ${page + 1} of $totalPages)',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('${start + 1}-${end} of ${apiItems.length}'),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 10),
                
                // Detailed results table
                _buildResultsTable(pageItems, hostStatuses),
                
                // Page footer
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Page ${page + 1} of $totalPages',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }
  }

  /// Get the downloads path for different platforms
  static Future<String> _getDownloadsPath() async {
    final fileName = 'vandcloud_api_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    
    try {
      if (Platform.isAndroid) {
        // For Android, use the standard Downloads directory
        final androidDownloadsDir = Directory('/storage/emulated/0/Download');
        if (await androidDownloadsDir.exists()) {
          // Request storage permission
          final status = await Permission.storage.request();
          if (status.isGranted) {
            return path.join(androidDownloadsDir.path, fileName);
          } else {
            // If permission is denied, try to use external storage without permission
            // This might work on some devices
            return path.join(androidDownloadsDir.path, fileName);
          }
        } else {
          // If the standard path doesn't exist, try to create it
          try {
            await androidDownloadsDir.create(recursive: true);
            return path.join(androidDownloadsDir.path, fileName);
          } catch (e) {
            print('Could not create Android Downloads directory: $e');
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, use the documents directory (Downloads is not accessible)
        final docsDir = await getApplicationDocumentsDirectory();
        return path.join(docsDir.path, fileName);
      } else if (Platform.isWindows) {
        // For Windows, try to access the user's Downloads folder
        final homeDir = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
        if (homeDir != null) {
          final windowsDownloadsDir = Directory(path.join(homeDir, 'Downloads'));
          if (await windowsDownloadsDir.exists()) {
            return path.join(windowsDownloadsDir.path, fileName);
          }
        }
      } else if (Platform.isMacOS) {
        // For macOS, try to access the user's Downloads folder
        final homeDir = Platform.environment['HOME'];
        if (homeDir != null) {
          final macDownloadsDir = Directory(path.join(homeDir, 'Downloads'));
          if (await macDownloadsDir.exists()) {
            return path.join(macDownloadsDir.path, fileName);
          }
        }
      } else if (Platform.isLinux) {
        // For Linux, try to access the user's Downloads folder
        final homeDir = Platform.environment['HOME'];
        if (homeDir != null) {
          final linuxDownloadsDir = Directory(path.join(homeDir, 'Downloads'));
          if (await linuxDownloadsDir.exists()) {
            return path.join(linuxDownloadsDir.path, fileName);
          }
        }
      }
      
      // Try to get the downloads directory using path_provider as fallback
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          return path.join(downloadsDir.path, fileName);
        }
      } catch (e) {
        print('Could not access downloads directory via path_provider: $e');
      }
    } catch (e) {
      print('Error accessing platform-specific downloads directory: $e');
    }
    
    // Fallback to documents directory
    final docsDir = await getApplicationDocumentsDirectory();
    return path.join(docsDir.path, fileName);
  }

  /// Build a statistics card
  static pw.Widget _buildStatCard(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        height: 80,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue100, // Use a lighter color instead of withOpacity
          border: pw.Border.all(color: color),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a success rate chart
  static pw.Widget _buildSuccessRateChart(int successCount, int failedCount) {
    final total = successCount + failedCount;
    if (total == 0) {
      return pw.Container();
    }
    
    final successPercentage = (successCount / total) * 100;
    final failedPercentage = (failedCount / total) * 100;
    
    return pw.Container(
      height: 40,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          if (successCount > 0)
            pw.Expanded(
              flex: successCount,
              child: pw.Container(
                color: PdfColors.green,
                child: pw.Center(
                  child: pw.Text(
                    '${successPercentage.toStringAsFixed(1)}%',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          if (failedCount > 0)
            pw.Expanded(
              flex: failedCount,
              child: pw.Container(
                color: PdfColors.red,
                child: pw.Center(
                  child: pw.Text(
                    '${failedPercentage.toStringAsFixed(1)}%',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build a table of results
  static pw.Widget _buildResultsTable(
    List<ApiItem> apiItems,
    Map<String, HostStatus> hostStatuses,
  ) {
    // If there are no items, return a message
    if (apiItems.isEmpty) {
      return pw.Text('No API items found');
    }
    
    // Create table headers
    final headers = [
      pw.Container(
        padding: const pw.EdgeInsets.all(4),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey300,
        ),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                'Name',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                'Status',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                'Ping',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    ];
    
    // Create table rows
    final rows = <pw.Widget>[];
    rows.addAll(headers);
    
    // Add data rows
    for (final item in apiItems) {
      final status = hostStatuses[item.name];
      String statusText = 'Not Tested';
      String pingText = '-';
      PdfColor statusColor = PdfColors.grey;
      
      if (status != null) {
        statusText = status.isSuccess ? 'Success' : 'Failed';
        statusColor = status.isSuccess ? PdfColors.green : PdfColors.red;
        pingText = status.ping >= 0 ? '${status.ping} ms' : 'N/A';
      }
      
      rows.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey200),
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      item.name,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      statusText,
                      style: pw.TextStyle(
                        color: statusColor,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      pingText,
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                item.url,
                style: pw.TextStyle(
                  fontSize: 6,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return pw.Column(
      children: rows,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
    );
  }
}