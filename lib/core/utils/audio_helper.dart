import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'settings_service.dart';

/// Audio helper for text-to-speech using Apple's Premium Voices
class AudioHelper {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;
  static String? _currentVoice;

  // Preferred voices for kids app (in order of preference)
  // These are Apple's premium/enhanced on-device voices - cheerful and clear
  static const List<String> _preferredVoices = [
    'Samantha',      // Enhanced - warm, clear, friendly (best for kids)
    'Nicky',         // Premium - warm, upbeat voice
    'Allison',       // Neural - very natural sounding
    'Ava',           // Neural - clear and friendly
    'Zoe',           // Premium - clear and friendly
    'Tom',           // Premium - friendly male option
    'Alex',          // Premium - natural
    'Fiona',         // Premium - clear British
    'Karen',         // Premium - Australian
  ];

  /// Initialize TTS with kid-friendly settings and premium voice
  static Future<void> init() async {
    if (_initialized) return;

    await _tts.setLanguage('en-US');

    // iOS-specific settings for better quality
    if (Platform.isIOS) {
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }

    // Try to set a premium voice
    await _selectBestVoice();

    // Kid-friendly speech settings - use settings service rate
    await _tts.setSpeechRate(SettingsService.speechRate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.25);       // Higher pitch for animated, cheerful tone

    _initialized = true;
  }

  /// Update speech rate (call after settings change)
  static Future<void> updateSpeechRate() async {
    await _tts.setSpeechRate(SettingsService.speechRate);
  }

  /// Select the best available premium voice
  static Future<void> _selectBestVoice() async {
    try {
      final voices = await _tts.getVoices;
      if (voices == null) return;

      final voiceList = List<Map<dynamic, dynamic>>.from(voices);

      // Filter for en-US voices
      final enUSVoices = voiceList.where((voice) {
        final locale = voice['locale']?.toString() ?? '';
        return locale.startsWith('en-US') || locale.startsWith('en_US');
      }).toList();

      // Try to find a preferred voice
      for (final preferredName in _preferredVoices) {
        for (final voice in enUSVoices) {
          final voiceName = voice['name']?.toString() ?? '';
          final voiceId = voice['identifier']?.toString() ?? '';

          // Check if this voice matches our preferred list
          // Prioritize "Enhanced" or "Premium" versions
          if (voiceName.contains(preferredName) || voiceId.contains(preferredName)) {
            // Prefer enhanced/premium versions
            final isEnhanced = voiceName.contains('Enhanced') ||
                               voiceName.contains('Premium') ||
                               voiceId.contains('enhanced') ||
                               voiceId.contains('premium');

            await _tts.setVoice({
              'name': voice['name'],
              'locale': voice['locale'],
            });
            _currentVoice = voiceName;

            // If it's enhanced, we found our best option
            if (isEnhanced) {
              return;
            }
            // Otherwise keep looking for an enhanced version
          }
        }
      }

      // If no preferred voice found, try to find any enhanced voice
      for (final voice in enUSVoices) {
        final voiceName = voice['name']?.toString() ?? '';
        final voiceId = voice['identifier']?.toString() ?? '';

        if (voiceName.contains('Enhanced') ||
            voiceId.contains('enhanced') ||
            voiceId.contains('premium')) {
          await _tts.setVoice({
            'name': voice['name'],
            'locale': voice['locale'],
          });
          _currentVoice = voiceName;
          return;
        }
      }

      // Fallback: use first available en-US voice
      if (enUSVoices.isNotEmpty) {
        final fallback = enUSVoices.first;
        await _tts.setVoice({
          'name': fallback['name'],
          'locale': fallback['locale'],
        });
        _currentVoice = fallback['name']?.toString();
      }
    } catch (e) {
      // If voice selection fails, continue with default
      _currentVoice = 'default';
    }
  }

  /// Get current voice name (for debugging/settings)
  static String? get currentVoice => _currentVoice;

  /// Speak text
  static Future<void> speak(String text) async {
    await init();
    await _tts.speak(text);
  }

  /// Stop speaking
  static Future<void> stop() async {
    await _tts.stop();
  }

  /// Speak game instructions
  static Future<void> speakInstruction(String instruction) async {
    await speak(instruction);
  }

  /// Speak success message (randomized, short and punchy for kids)
  static Future<void> speakSuccess() async {
    final messages = [
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
    ];
    final message = messages[DateTime.now().millisecond % messages.length];
    await speak(message);
  }

  /// Speak try again message (short, encouraging)
  static Future<void> speakTryAgain() async {
    final messages = [
      'Oops! Try again!',
      'Almost! Try again!',
      'Not quite!',
      'Try once more!',
      'One more try!',
    ];
    final message = messages[DateTime.now().millisecond % messages.length];
    await speak(message);
  }

  /// Speak game complete
  static Future<void> speakGameComplete() async {
    await speak('Amazing! You did it!');
  }

  /// Speak a letter name (with phonetic clarity)
  static Future<void> speakLetter(String letter) async {
    await init();
    // Speak the letter name clearly
    await _tts.speak(letter.toUpperCase());
  }

  /// Speak a number
  static Future<void> speakNumber(int number) async {
    await speak(number.toString());
  }

  /// List all available voices (for debugging/settings)
  static Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      final voices = await _tts.getVoices;
      if (voices == null) return [];

      final voiceList = List<Map<dynamic, dynamic>>.from(voices);

      return voiceList
          .where((voice) {
            final locale = voice['locale']?.toString() ?? '';
            return locale.startsWith('en');
          })
          .map((voice) => {
                'name': voice['name']?.toString() ?? 'Unknown',
                'locale': voice['locale']?.toString() ?? 'Unknown',
                'identifier': voice['identifier']?.toString() ?? '',
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Set a specific voice by name
  static Future<bool> setVoiceByName(String voiceName) async {
    try {
      final voices = await _tts.getVoices;
      if (voices == null) return false;

      final voiceList = List<Map<dynamic, dynamic>>.from(voices);

      for (final voice in voiceList) {
        final name = voice['name']?.toString() ?? '';
        if (name.contains(voiceName)) {
          await _tts.setVoice({
            'name': voice['name'],
            'locale': voice['locale'],
          });
          _currentVoice = name;
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
