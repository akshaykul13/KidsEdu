# Kids Educational App - Architecture

Technical architecture and code structure documentation.

---

## 1. Project Overview

### Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | Flutter | 3.10+ |
| Language | Dart | 3.0+ |
| Platform | iOS (iPad) | 14.0+ |
| State Management | Provider | 6.1.2 |
| Local Storage | SharedPreferences, Hive | Latest |
| Text-to-Speech | flutter_tts | 4.2.0 |
| Audio | audioplayers | 6.1.0 |
| Animations | confetti, lottie | Latest |
| SVG Rendering | flutter_svg | 2.0.10 |
| Typography | google_fonts | 6.1.0 |

---

## 2. Directory Structure

```
lib/
├── main.dart                         # App entry, initialization
├── core/                             # Core functionality
│   ├── constants/
│   │   └── game_data.dart            # Game metadata definitions
│   ├── theme/
│   │   └── app_theme.dart            # Colors, typography, theming
│   └── utils/
│       ├── audio_helper.dart         # TTS and sound management
│       ├── haptic_helper.dart        # iOS haptic feedback
│       ├── settings_service.dart     # Persistent settings
│       ├── flag_widget.dart          # SVG flag renderer
│       └── illustrated_icons.dart    # Custom vector icons
├── screens/                          # Full-screen views
│   ├── home_screen.dart              # Category navigation
│   └── games/                        # All game implementations
│       ├── identify_letter_game.dart
│       ├── phonics_game.dart
│       ├── words_game.dart
│       ├── identify_numbers_game.dart
│       ├── math_game.dart
│       ├── write_letters_game.dart
│       ├── write_words_game.dart
│       ├── write_numbers_game.dart
│       ├── higher_lower_game.dart
│       ├── before_after_game.dart
│       ├── memory_match_game.dart
│       ├── maze_game.dart
│       ├── find_hidden_game.dart
│       ├── odd_one_out_game.dart
│       ├── spot_the_difference_game.dart
│       ├── color_sort_game.dart
│       ├── big_to_small_game.dart
│       ├── music_notes_game.dart
│       ├── flags_game.dart
│       ├── calendar_game.dart
│       └── chore_tracker_game.dart
├── widgets/                          # Reusable UI components
│   ├── navigation_buttons.dart       # Back/Home buttons
│   ├── game_app_bar.dart             # Standard game header
│   ├── answer_tile.dart              # Answer button with 3D effect
│   ├── duo_button.dart               # Duolingo-style button
│   ├── duo_progress_bar.dart         # Progress bar with shine
│   ├── celebration_overlay.dart      # Confetti overlay
│   ├── success_drawer.dart           # Success animations
│   └── path_node.dart                # Home screen nodes
└── services/                         # Future services (cloud, etc.)

assets/
├── images/                           # Static images
├── lottie/                           # Animation files
└── flags/                            # Flag assets (if needed)
```

---

## 3. Core Components

### 3.1 App Entry (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings before app starts
  await SettingsService.init();

  // Lock to landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const KidsEduApp());
}
```

### 3.2 Settings Service

**File:** `lib/core/utils/settings_service.dart`

Singleton service for app-wide settings using SharedPreferences.

```dart
class SettingsService {
  static SharedPreferences? _prefs;

  // Initialize (call in main.dart)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Settings
  static bool get hintsEnabled => _prefs?.getBool('hints_enabled') ?? false;
  static bool get soundEnabled => _prefs?.getBool('sound_enabled') ?? true;
  static int get speechSpeed => _prefs?.getInt('speech_speed') ?? 0;

  // Computed values
  static double get speechRate {
    switch (speechSpeed) {
      case 0: return 0.3;  // Slow
      case 1: return 0.4;  // Normal
      case 2: return 0.5;  // Fast
      default: return 0.3;
    }
  }
}
```

**Settings:**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `hints_enabled` | bool | false | Show hint animations |
| `sound_enabled` | bool | true | Enable TTS |
| `speech_speed` | int | 0 | 0=slow, 1=normal, 2=fast |

### 3.3 Audio Helper

**File:** `lib/core/utils/audio_helper.dart`

Wrapper for flutter_tts with kid-friendly configuration.

```dart
class AudioHelper {
  static FlutterTts? _tts;

  static Future<void> init() async {
    _tts = FlutterTts();

    // iOS-specific settings
    await _tts!.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );

    await _tts!.setSpeechRate(SettingsService.speechRate);
    await _tts!.setPitch(1.0);
    await _tts!.setVolume(1.0);
    await _tts!.setLanguage('en-US');

    // Set clearer voice
    await _setPreferredVoice();
  }

  static Future<void> speak(String text) async {
    if (!SettingsService.soundEnabled) return;
    await _tts?.speak(text);
  }

  static Future<void> speakSuccess() async {
    await speak("Great job!");
  }

  static Future<void> speakTryAgain() async {
    await speak("Try again!");
  }

  static Future<void> speakGameComplete() async {
    await speak("You did it! Amazing!");
  }
}
```

### 3.4 Haptic Helper

**File:** `lib/core/utils/haptic_helper.dart`

iOS Taptic Engine feedback wrapper.

```dart
class HapticHelper {
  // Correct answer - double light tap
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  // Wrong answer - single heavy
  static void error() {
    HapticFeedback.heavyImpact();
  }

  // Button press
  static void lightTap() {
    HapticFeedback.lightImpact();
  }

  // Game complete
  static void celebration() {
    HapticFeedback.mediumImpact();
  }
}
```

---

## 4. Theme System

### 4.1 Colors (`AppColors`)

**File:** `lib/core/theme/app_theme.dart`

3D color palette with base and shade pairs:

```dart
class AppColors {
  // Primary colors (base + shade for 3D effect)
  static const Color primary = Color(0xFF1CB0F6);
  static const Color primaryShade = Color(0xFF1899D6);

  static const Color success = Color(0xFF58CC02);
  static const Color successShade = Color(0xFF46A302);

  static const Color attention = Color(0xFFFFC800);
  static const Color attentionShade = Color(0xFFE5A400);

  static const Color energy = Color(0xFFFF9600);
  static const Color energyShade = Color(0xFFE58700);

  static const Color error = Color(0xFFFF4B4B);
  static const Color errorShade = Color(0xFFD33131);

  static const Color neutral = Color(0xFFE5E5E5);
  static const Color neutralShade = Color(0xFFAFB4BD);

  // Text colors
  static const Color textPrimary = Color(0xFF4B4B4B);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textMuted = Color(0xFFAFAFAF);

  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
}
```

### 4.2 Typography (`AppTypography`)

Nunito font family from Google Fonts:

```dart
class AppTypography {
  static TextStyle headingL = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle gameTitle = GoogleFonts.nunito(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle button = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
}
```

---

## 5. Custom Graphics

### 5.1 Illustrated Icons

**File:** `lib/core/utils/illustrated_icons.dart`

Custom vector icons using `CustomPaint`.

**Architecture:**
```
IllustratedIcon (StatelessWidget)
    │
    ├── Container (background)
    │
    └── CustomPaint
            │
            └── _IconPainter (CustomPainter)
                    │
                    └── switch(iconData['type'])
                            ├── _drawCat()
                            ├── _drawDog()
                            ├── _drawStar()
                            └── ... (20 icon types)
```

**Usage:**
```dart
IllustratedIcon(
  iconId: 'cat',       // String identifier
  size: 60,            // Width and height
  backgroundColor: Colors.orange.withOpacity(0.1),
)
```

**Available Icons:**
```dart
static List<String> get availableIcons => [
  'cat', 'dog', 'rabbit', 'bear', 'fox', 'owl',
  'elephant', 'lion', 'monkey', 'penguin', 'fish',
  'bird', 'turtle', 'butterfly', 'star', 'heart',
  'flower', 'sun', 'moon', 'cloud'
];
```

### 5.2 Flag Widget

**File:** `lib/core/utils/flag_widget.dart`

SVG-based country flags with emoji fallback.

**Architecture:**
```
FlagWidget (StatelessWidget)
    │
    ├── Check if SVG data exists for countryCode
    │       │
    │       ├── Yes: SvgPicture.string(svgData)
    │       │
    │       └── No: Text(flagEmoji)
    │
    └── Fallback: Text('🏳️')
```

**Usage:**
```dart
FlagWidget(
  countryCode: 'JP',   // ISO 3166-1 alpha-2
  size: 80,            // Height (width = 1.5x)
)
```

**CountryData class:**
```dart
class CountryData {
  final String name;   // "Japan"
  final String code;   // "JP"

  static const List<CountryData> all = [
    CountryData('United States', 'US'),
    CountryData('Japan', 'JP'),
    // ... 39 countries total
  ];
}
```

---

## 6. Navigation

### 6.1 Home Screen Structure

```
HomeScreen
    │
    ├── _buildTopBar()           # Stars, settings
    │
    ├── _buildHeroArea()         # Mascot, greeting
    │
    └── Category Selection
            │
            ├── Letters & Words (Blue)
            │       └── 5 games
            │
            ├── Numbers (Green)
            │       └── 5 games
            │
            ├── Games (Orange)
            │       └── 7 games
            │
            └── General Knowledge (Purple)
                    └── 4 games
```

### 6.2 Game Navigation

```dart
// Navigate to game
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const IdentifyLetterGame()),
);

// Return from game
Navigator.pop(context);
```

---

## 7. Game Architecture

### 7.1 Standard Game Pattern

All games follow this structure:

```dart
class ExampleGame extends StatefulWidget {
  const ExampleGame({super.key});

  @override
  State<ExampleGame> createState() => _ExampleGameState();
}

class _ExampleGameState extends State<ExampleGame> {
  // Confetti controller
  late ConfettiController _confettiController;

  // Game state
  int _round = 0;
  final int _totalRounds = 10;
  int _score = 0;
  bool _isWaiting = false;

  // Hint timer (if applicable)
  Timer? _hintTimer;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    AudioHelper.init();
    _startNewRound();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _hintTimer?.cancel();
    super.dispose();
  }

  void _startNewRound() {
    if (_round >= _totalRounds) {
      _showGameComplete();
      return;
    }

    setState(() {
      _round++;
      _showHint = false;
      _isWaiting = false;
    });

    // Setup game content...

    // Start hint timer if enabled
    if (SettingsService.hintsEnabled) {
      _startHintTimer();
    }

    // Speak prompt
    _speakPrompt();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) setState(() => _showHint = true);
    });
  }

  void _onCorrectAnswer() {
    _hintTimer?.cancel();
    HapticHelper.success();
    _confettiController.play();
    AudioHelper.speakSuccess();

    setState(() {
      _score++;
      _isWaiting = true;
    });

    Future.delayed(
      const Duration(milliseconds: 1500),
      _startNewRound,
    );
  }

  void _onWrongAnswer() {
    HapticHelper.error();
    AudioHelper.speakTryAgain();
    // Show error state...
  }

  void _showGameComplete() {
    HapticHelper.celebration();
    AudioHelper.speakGameComplete();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameCompleteDialog(
        score: _score,
        totalRounds: _totalRounds,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() { _score = 0; _round = 0; });
          _startNewRound();
        },
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(child: Column(...)),
          CelebrationOverlay(controller: _confettiController),
        ],
      ),
    );
  }
}
```

### 7.2 Game Components

| Component | Widget | Purpose |
|-----------|--------|---------|
| Back Button | `GameBackButton` | Navigation |
| App Bar | Custom Row | Title, round, score |
| Content | Game-specific | Main gameplay |
| Celebration | `CelebrationOverlay` | Confetti layer |
| Complete Dialog | `GameCompleteDialog` | End screen |

---

## 8. Widget Library

### 8.1 Navigation Buttons

**File:** `lib/widgets/navigation_buttons.dart`

```dart
class GameBackButton extends StatelessWidget {
  // 88pt touch target back button
  // Returns to previous screen
}
```

### 8.2 Celebration Overlay

**File:** `lib/widgets/celebration_overlay.dart`

```dart
class CelebrationOverlay extends StatelessWidget {
  final ConfettiController controller;
  // Positioned overlay with confetti widget
}

class GameCompleteDialog extends StatelessWidget {
  final int score;
  final int totalRounds;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  // Shows score and action buttons
}
```

### 8.3 Answer Tile

**File:** `lib/widgets/answer_tile.dart`

```dart
class AnswerTile extends StatefulWidget {
  final Widget child;
  final Color color;
  final bool isCorrect;
  final bool isWrong;
  final bool showHint;
  final VoidCallback onTap;
  // 3D button with hint pulse animation
}
```

---

## 9. State Management

### Current Approach

- **Widget State:** Each game manages its own state with `StatefulWidget`
- **Settings:** Singleton service with SharedPreferences
- **Navigation:** Standard Flutter Navigator

### Future Considerations

For progress tracking and more complex state:

```dart
// Potential Provider structure
class GameProgress extends ChangeNotifier {
  Map<String, int> _scores = {};
  Map<String, bool> _completed = {};
  int _totalStars = 0;

  void recordScore(String gameId, int score) {
    _scores[gameId] = max(_scores[gameId] ?? 0, score);
    notifyListeners();
  }
}
```

---

## 10. Testing Strategy

### Recommended Tests

| Type | Coverage |
|------|----------|
| Unit | Settings service, audio helper |
| Widget | Individual game screens |
| Integration | Full game flow |

### Test Example

```dart
void main() {
  group('SettingsService', () {
    test('defaults hintsEnabled to false', () async {
      await SettingsService.init();
      expect(SettingsService.hintsEnabled, false);
    });

    test('returns correct speech rate for speed setting', () {
      expect(SettingsService.speechRate, 0.3); // Default slow
    });
  });
}
```

---

## 11. Build & Deployment

### Development

```bash
# Run on iOS Simulator
flutter run

# Run with specific device
flutter run -d "iPad"
```

### Production Build

```bash
# iOS build
flutter build ios --release

# Open in Xcode for deployment
open ios/Runner.xcworkspace
```

### Configuration

**pubspec.yaml:**
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/lottie/
    - assets/flags/
```

**iOS Info.plist:**
- Landscape orientation only
- iPad deployment target
- Audio session configuration

---

## 12. Performance Considerations

### Optimizations

1. **Inline SVG:** Flags stored as inline SVG strings, no network requests
2. **CustomPaint:** Illustrated icons drawn programmatically, no assets
3. **Lazy Loading:** Games loaded only when navigated to
4. **Dispose:** All controllers and timers properly disposed

### Memory Management

```dart
@override
void dispose() {
  _confettiController.dispose();
  _hintTimer?.cancel();
  _animationController?.dispose();
  super.dispose();
}
```
