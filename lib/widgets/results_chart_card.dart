import 'package:flutter/material.dart';

class ResultsChartCard extends StatelessWidget {
  final int successCount;
  final int failedCount;
  final bool isTesting;

  const ResultsChartCard({
    Key? key,
    required this.successCount,
    required this.failedCount,
    required this.isTesting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalCount = successCount + failedCount;
    final successPercentage = totalCount > 0 ? successCount / totalCount : 0.0;
    final failedPercentage = totalCount > 0 ? failedCount / totalCount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Test Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isTesting)
                  const Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Testing...',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar visualization
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  if (successCount > 0)
                    Expanded(
                      flex: (successPercentage * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  if (failedCount > 0)
                    Expanded(
                      flex: (failedPercentage * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(successCount == 0 ? 4 : 0),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Statistics row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  count: successCount,
                  label: 'Success',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                _buildStatItem(
                  count: failedCount,
                  label: 'Failed',
                  color: Colors.red,
                  icon: Icons.error,
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                _buildStatItem(
                  count: totalCount,
                  label: 'Total',
                  color: Colors.blue,
                  icon: Icons.list,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
