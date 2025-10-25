import 'package:shared_preferences/shared_preferences.dart';

class BatchSizeService {
  static const String _batchSizeKey = 'batch_size';
  static const int _defaultBatchSize = 10;
  static const int minBatchSize = 5;
  static const int maxBatchSize = 50;

  static Future<int> loadBatchSize() async {
    final prefs = await SharedPreferences.getInstance();
    final batchSize = prefs.getInt(_batchSizeKey) ?? _defaultBatchSize;
    
    // Ensure the loaded value is within bounds
    return batchSize.clamp(minBatchSize, maxBatchSize);
  }

  static Future<void> saveBatchSize(int batchSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_batchSizeKey, batchSize.clamp(minBatchSize, maxBatchSize));
  }
}