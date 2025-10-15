import 'package:shared_preferences/shared_preferences.dart';

class TimeoutService {
  static const String _timeoutKey = 'timeout_seconds';
  static const int _defaultTimeout = 30;

  static Future<int> loadTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_timeoutKey) ?? _defaultTimeout;
  }

  static Future<void> saveTimeout(int timeout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeoutKey, timeout);
  }
}
