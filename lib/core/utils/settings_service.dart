import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app settings
class SettingsService {
  static const String _hintsEnabledKey = 'hints_enabled';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _speechSpeedKey = 'speech_speed';

  static SharedPreferences? _prefs;

  /// Initialize the settings service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get hints enabled setting (default: false - hints off)
  static bool get hintsEnabled {
    return _prefs?.getBool(_hintsEnabledKey) ?? false;
  }

  /// Set hints enabled setting
  static Future<void> setHintsEnabled(bool value) async {
    await _prefs?.setBool(_hintsEnabledKey, value);
  }

  /// Get sound enabled setting (default: true)
  static bool get soundEnabled {
    return _prefs?.getBool(_soundEnabledKey) ?? true;
  }

  /// Set sound enabled setting
  static Future<void> setSoundEnabled(bool value) async {
    await _prefs?.setBool(_soundEnabledKey, value);
  }

  /// Get speech speed setting (0 = slow, 1 = normal, 2 = fast)
  /// Default is 0 (slow) for young kids
  static int get speechSpeed {
    return _prefs?.getInt(_speechSpeedKey) ?? 0;
  }

  /// Set speech speed setting
  static Future<void> setSpeechSpeed(int value) async {
    await _prefs?.setInt(_speechSpeedKey, value);
  }

  /// Get speech rate value for TTS based on speed setting
  static double get speechRate {
    switch (speechSpeed) {
      case 0: return 0.45;  // Slow - clear for young kids but not sluggish
      case 1: return 0.52;  // Normal - lively pace
      case 2: return 0.58;  // Fast - energetic
      default: return 0.45;
    }
  }
}
