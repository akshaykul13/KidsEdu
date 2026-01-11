import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:audioplayers/audioplayers.dart';
import 'settings_service.dart';

/// ElevenLabs TTS Service with local caching
class ElevenLabsService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static String? _cacheDir;
  static bool _initialized = false;

  // Default voice ID - "Rachel" is friendly and clear
  // You can find more voices at https://elevenlabs.io/voice-library
  static const String _defaultVoiceId = '21m00Tcm4TlvDq8ikWAM'; // Rachel

  // Kid-friendly voices (can be changed)
  static const Map<String, String> availableVoices = {
    'Rachel': '21m00Tcm4TlvDq8ikWAM',
    'Domi': 'AZnzlk1XvdvUeBnXmlld',
    'Bella': 'EXAVITQu4vr4xnSDxMaL',
    'Elli': 'MF3mGyEYCl7XYWbV9V6O',
    'Josh': 'TxGEqnHWrfWFTfGW9XjX',
    'Charlotte': 'XB0fDUnXU5powFXDhCwa',
  };

  /// Initialize the service
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _cacheDir = '${dir.path}/elevenlabs_cache';
      await Directory(_cacheDir!).create(recursive: true);
      _initialized = true;
    } catch (e) {
      _initialized = false;
    }
  }

  /// Check if ElevenLabs is available and configured
  static bool get isAvailable {
    return SettingsService.elevenLabsEnabled &&
        SettingsService.elevenLabsApiKey.isNotEmpty;
  }

  /// Speak text using ElevenLabs
  /// Returns true if successful, false if should fallback to device TTS
  static Future<bool> speak(String text, {String? voiceId}) async {
    if (!isAvailable) return false;

    await init();
    if (!_initialized) return false;

    try {
      // Check cache first
      final cacheFile = await _getCachedAudio(text);
      if (cacheFile != null) {
        await _playAudio(cacheFile);
        return true;
      }

      // Fetch from API
      final audioData = await _fetchAudio(text, voiceId ?? _defaultVoiceId);
      if (audioData == null) return false;

      // Cache it
      final file = await _cacheAudio(text, audioData);

      // Play it
      await _playAudio(file);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch audio from ElevenLabs API
  static Future<List<int>?> _fetchAudio(String text, String voiceId) async {
    final apiKey = SettingsService.elevenLabsApiKey;
    if (apiKey.isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'),
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': apiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
            'style': 0.5,
            'use_speaker_boost': true,
          },
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cached audio file if exists
  static Future<File?> _getCachedAudio(String text) async {
    if (_cacheDir == null) return null;

    final hash = _hashText(text);
    final file = File('$_cacheDir/$hash.mp3');

    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Cache audio data
  static Future<File> _cacheAudio(String text, List<int> audioData) async {
    final hash = _hashText(text);
    final file = File('$_cacheDir/$hash.mp3');
    await file.writeAsBytes(audioData);
    return file;
  }

  /// Generate hash for cache key
  static String _hashText(String text) {
    return md5.convert(utf8.encode(text.toLowerCase().trim())).toString();
  }

  /// Play audio file
  static Future<void> _playAudio(File file) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(file.path));
  }

  /// Stop playback
  static Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Clear cache (useful for freeing space)
  static Future<void> clearCache() async {
    if (_cacheDir == null) return;

    final dir = Directory(_cacheDir!);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create(recursive: true);
    }
  }

  /// Get cache size in bytes
  static Future<int> getCacheSize() async {
    if (_cacheDir == null) return 0;

    final dir = Directory(_cacheDir!);
    if (!await dir.exists()) return 0;

    int size = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }

  /// Pre-cache common phrases for offline use
  static Future<void> precacheCommonPhrases() async {
    if (!isAvailable) return;

    final phrases = [
      'Yay!',
      'Woohoo!',
      'Yes!',
      'Awesome!',
      'Perfect!',
      'Amazing!',
      'Great!',
      'Super!',
      'Wow!',
      'Nice!',
      'Oops! Try again!',
      'Almost! Try again!',
      'Not quite!',
      'Try once more!',
      'One more try!',
      'Amazing! You did it!',
    ];

    for (final phrase in phrases) {
      // Check if already cached
      final cached = await _getCachedAudio(phrase);
      if (cached == null) {
        // Fetch and cache
        final audioData = await _fetchAudio(phrase, _defaultVoiceId);
        if (audioData != null) {
          await _cacheAudio(phrase, audioData);
        }
        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }
}
