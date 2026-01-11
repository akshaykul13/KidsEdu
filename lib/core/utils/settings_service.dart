import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app settings
class SettingsService {
  static const String _hintsEnabledKey = 'hints_enabled';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _speechSpeedKey = 'speech_speed';
  static const String _elevenLabsEnabledKey = 'elevenlabs_enabled';
  static const String _elevenLabsApiKeyKey = 'elevenlabs_api_key';

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

  /// Get ElevenLabs enabled setting (default: false)
  static bool get elevenLabsEnabled {
    return _prefs?.getBool(_elevenLabsEnabledKey) ?? false;
  }

  /// Set ElevenLabs enabled setting
  static Future<void> setElevenLabsEnabled(bool value) async {
    await _prefs?.setBool(_elevenLabsEnabledKey, value);
  }

  /// Get ElevenLabs API key
  static String get elevenLabsApiKey {
    return _prefs?.getString(_elevenLabsApiKeyKey) ?? '';
  }

  /// Set ElevenLabs API key
  static Future<void> setElevenLabsApiKey(String value) async {
    await _prefs?.setString(_elevenLabsApiKeyKey, value);
  }

  /// Get speech rate value for TTS based on speed setting
  static double get speechRate {
    switch (speechSpeed) {
      case 0: return 0.5;   // Slow - still lively for kids
      case 1: return 0.55;  // Normal - energetic pace
      case 2: return 0.62;  // Fast - quick and exciting
      default: return 0.5;
    }
  }
}
