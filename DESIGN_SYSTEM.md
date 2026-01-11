# Kids Educational App - Design System

## Overview
This design guide provides the exact technical specifications for building a "Duolingo-style" educational game on iOS. We focus on the **"Chunky Tactile"** aesthetic—where every element feels like a physical toy.

**Target Audience:** Children ages 4-6
**Platform:** iOS (iPad)
**Core Aesthetic:** Chunky, 3D buttons that feel like real toys

---

## 1. Typography & Hierarchy

For kids, readability is about weight and character. Use **Nunito** (available on Google Fonts) as it is the closest free equivalent to Duolingo's custom "DIN Round."

| Element | Font Weight | Size (pt) | Color | Use Case |
|---------|-------------|-----------|-------|----------|
| Heading L | Black (900) | 28pt | `#4B4B4B` | Unit Titles, Success Screen |
| Game Title | Black (900) | 32pt | `#4B4B4B` | Game headers |
| Game Prompt | Bold (700) | 24pt | `#4B4B4B` | Instructions |
| Body M | Bold (700) | 18pt | `#777777` | Instructions, Dialogues |
| Button Text | ExtraBold (800) | 16pt | `#FFFFFF` | "CONTINUE", "START" |
| Answer Option | ExtraBold (800) | 28pt | `#FFFFFF` | Game answer buttons |
| Game Letter | Black (900) | 48pt | `#4B4B4B` | Large letter display |
| Micro Text | Bold (700) | 14pt | `#AFAFAF` | Progress labels, tooltips |

### Font Implementation
```dart
// pubspec.yaml - Add Nunito from Google Fonts
dependencies:
  google_fonts: ^6.1.0

// Usage in code
Text(
  'CONTINUE',
  style: GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  ),
)
```

---

## 2. The Color System (The "3D Palette")

Each color must have a **Base** and a **Shade** (the shadow underneath). This creates the characteristic Duolingo "chunky button" look.

### Primary Colors
| Category | Base Color | Shade Color | Visual Purpose |
|----------|------------|-------------|----------------|
| Primary | `#1CB0F6` (Blue) | `#1899D6` | Brand, Path Nodes, Info |
| Success | `#58CC02` (Green) | `#46A302` | Correct, Continue, Progress |
| Attention | `#FFC800` (Yellow) | `#E5A400` | Review, Gold Levels, Stars |
| Energy | `#FF9600` (Orange) | `#E58700` | Streaks, Special Nodes |
| Error | `#FF4B4B` (Red) | `#D33131` | Mistakes, Try Again |
| Neutral | `#E5E5E5` (Gray) | `#AFB4BD` | Locked Levels, Troughs |
| Purple | `#CE82FF` | `#B066E0` | General Knowledge category |

### UI Colors
| Name | Hex | Usage |
|------|-----|-------|
| Background | `#FFFFFF` | Main app background |
| Surface | `#FFFFFF` | Card backgrounds |
| Text Primary | `#4B4B4B` | Headlines, important text |
| Text Secondary | `#777777` | Instructions, body text |
| Text Muted | `#AFAFAF` | Tooltips, labels |

### Category Colors
| Category | Base | Shade | Usage |
|----------|------|-------|-------|
| ABC | `#1CB0F6` | `#1899D6` | Letters & reading games |
| 123 | `#58CC02` | `#46A302` | Numbers & math games |
| Puzzles | `#FF9600` | `#E58700` | Brain & logic games |
| Discover | `#CE82FF` | `#B066E0` | World & learning games |

---

## 3. Core UI Components

### A. The "Duo" Button (3D Press Effect)

The signature Duolingo button with a 3D press effect.

**Structure:**
- A `Stack` with two layers: the shadow (shade color) and the top button (base color)
- Corner Radius: **16-24pt** (depending on size)
- Shadow Height: **4-8pt** (visible at bottom when not pressed)
- Padding: **16pt horizontal, 12pt vertical**

**Interaction:**
- On `TouchDown`: Top layer moves down, shadow disappears
- On `TouchUp`: Top layer returns to original position
- Duration: **100ms** with `easeOut` curve

```dart
// Standard 3D button structure
Stack(
  children: [
    // Shadow layer
    Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          color: shadeColor,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    // Face layer (animated)
    AnimatedPositioned(
      duration: Duration(milliseconds: 100),
      top: isPressed ? 4 : 0,
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      ),
    ),
  ],
)
```

### B. The Progress Bar (Lesson Top)

**Trough (Background):**
- Height: **16pt**
- Background: `#E5E5E5`
- Corner Radius: **8pt**

**Fill (Progress):**
- Background: `#58CC02` (Success green)
- Same corner radius

**The "Shine" Effect:**
- A white rectangle with **0.3 opacity**
- Height: **4pt**
- Runs across the top of the green fill
- Creates a 3D glass look

### C. Game Card (Answer Tiles)

Used for letter/number selection in games.

**Dimensions:** 120-150pt square
**Border Radius:** 20-24pt
**Shadow Offset:** 6-8pt

**States:**
| State | Background | Border |
|-------|------------|--------|
| Default | Tile color | None |
| Hinting | Pulsing glow | Attention color |
| Correct | Success green | 4pt Success |
| Wrong | Error red | 4pt Error |

### D. Flag Card (Country Flags Game)

Displays SVG flags with 3D card effect.

**Dimensions:** 220x170pt
**Border Radius:** 24pt
**Shadow Offset:** 8pt

```dart
// Flag card structure
SizedBox(
  width: 220,
  height: 170,
  child: Stack(
    children: [
      // Shadow
      Positioned(
        left: 0, right: 0, bottom: 0, top: 8,
        child: Container(
          decoration: BoxDecoration(
            color: shadeColor,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      // Face with flag
      AnimatedPositioned(
        top: isPressed ? 8 : 0,
        bottom: isPressed ? 0 : 8,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 4),
          ),
          child: FlagWidget(countryCode: code, size: 90),
        ),
      ),
    ],
  ),
)
```

---

## 4. Custom Graphics & Animation System

### A. Game Icons (Rich SVG Illustrations)

Custom SVG vector icons with detailed cartoon-style illustrations. Each icon features:
- Cute expressions with eyes and highlights
- Gradient fills and shadows
- Consistent visual style across all icons

**Available Icons (20):**
| Animals | Nature/Shapes |
|---------|---------------|
| cat, dog, rabbit, bear | star, heart, flower |
| fox, owl, elephant, lion | sun, moon, cloud |
| monkey, penguin, fish, bird | |
| turtle, butterfly | |

**Usage:**
```dart
import '../../core/utils/game_icon.dart';

GameIcon(
  iconId: 'cat',
  size: 60,
)
```

**Implementation:**
- Each icon is a complete inline SVG with viewBox
- Uses `SvgPicture.string()` for rendering
- Fallback to emoji if icon not found
- Scales cleanly to any size

### B. Animated Game Icons

Wrapper component that adds engaging micro-animations to game icons.

**Animation States:**
| State | Animation | Use Case |
|-------|-----------|----------|
| `idle` | Gentle floating + breathing | Default state |
| `tapped` | Quick scale-down bounce | User tap feedback |
| `correct` | Scale pop + wiggle + shimmer | Correct answer |
| `wrong` | Shake + red tint | Wrong answer |
| `hint` | Pulsing glow + scale | Hint animation |

**Usage:**
```dart
import '../../core/utils/animated_game_icon.dart';

AnimatedGameIcon(
  iconId: 'star',
  size: 60,
  state: GameIconState.idle,
  enableIdleAnimation: true,
  entranceDelay: Duration(milliseconds: 100),
  onAnimationComplete: () => print('Animation done'),
)
```

### C. Animated Game Card (Memory Games)

Card component with 3D flip animation for memory-style games.

**Features:**
- Smooth 3D flip with perspective transform
- Press-down effect on tap
- State-based effects (matched shimmer, wrong shake, hint glow)
- Back face with "?" placeholder

**Usage:**
```dart
AnimatedGameCard(
  isFlipped: true,
  isMatched: false,
  isWrong: false,
  showHint: false,
  cardColor: Color(0xFFE5E5E5),
  shadeColor: Color(0xFFAFB4BD),
  width: 100,
  height: 100,
  onTap: () => handleTap(),
  child: GameIcon(iconId: 'cat', size: 50),
)
```

### D. Celebration Particles

Particle burst effect for celebrating correct answers.

**Usage:**
```dart
CelebrationParticles(
  isPlaying: showParticles,
  color: Colors.amber,
  particleCount: 12,
)
```

### E. Flag Widget

SVG-based country flags with emoji fallback.

**Countries with SVG Flags (18):**
Japan, France, Germany, Italy, Ireland, Poland, Ukraine, Indonesia, Bangladesh, Switzerland, Sweden, Greece, Thailand, Nigeria, Peru, Chile, Turkey, Vietnam

**Countries with Emoji Fallback (21):**
US, GB, CA, ES, CN, IN, BR, AU, MX, KR, RU, PK, IL, AR, PT, JM, NZ, ZA, EG, KE, CU

**Usage:**
```dart
FlagWidget(
  countryCode: 'JP',  // ISO 3166-1 alpha-2 code
  size: 80,
)
```

---

## 5. Settings Dialog

The settings dialog follows the chunky 3D aesthetic.

### Settings Available
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Hints | Toggle | Off | Show hint animations |
| Sound | Toggle | On | Enable TTS and sounds |
| Voice Speed | 3-way | Slow | Speech rate control |

### Voice Speed Options
| Speed | Label | TTS Rate | Icon |
|-------|-------|----------|------|
| Slow | Best for learning | 0.3 | Turtle |
| Normal | Standard pace | 0.4 | Walking |
| Fast | Quick review | 0.5 | Running |

### Settings Tile Design
```dart
// Toggle setting tile
Container(
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  decoration: BoxDecoration(
    color: isEnabled ? color.withOpacity(0.1) : AppColors.neutral,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isEnabled ? color : AppColors.neutralShade,
      width: 3,
    ),
  ),
  child: Row(
    children: [
      Icon(icon, color: isEnabled ? color : AppColors.textMuted),
      Text(label),
      Spacer(),
      Switch(value: isEnabled, onChanged: onChanged),
    ],
  ),
)
```

---

## 6. Screen Layout Specs (iOS Safe Areas)

### The Home Screen

**Top Bar:**
- Star count display
- Settings gear icon

**Hero Area:**
- Mascot illustration
- Speech bubble with greeting
- TTS: "Hi there! Ready to play?"

**Category Grid:**
- 2x2 grid of category cards
- Each card: 3D button with emoji + name
- Tap navigates to game list

### The Game Screen

**Top Bar:**
- Back button (88pt touch target)
- Game title
- Round/Score indicators

**Content Area:**
- Game-specific content
- Large central elements
- Answer options

**Celebration Layer:**
- Confetti overlay on success
- Game complete dialog

---

## 7. UX Patterns for Incremental Complexity

To build games that get harder without overwhelming the child, use these **Progression Toggles**:

| Level | Name | Description | Example |
|-------|------|-------------|---------|
| 1 | The "Intro" | Single choice. No wrong answers. | "Tap the Apple" |
| 2 | The "Distractor" | Two choices. Simple selection. | Apple vs. Banana |
| 3 | The "Recall" | Dragging interaction. | Drag "Apple" to the picture |
| 4 | The "Build" | Multi-step task. | Sort Red, Green, Yellow apples into baskets |

### Implementation Notes:
- Start every game at Level 1
- Progress only after 3-5 successful attempts
- Never show more than 4 options at Level 2
- Add audio reinforcement at each level

---

## 8. Motion & Sound (The "Juice")

A game feels "premium" when it reacts to the user. These micro-interactions are essential.

### Flutter Animate Integration

We use `flutter_animate` for declarative, chainable animations.

**Package:** `flutter_animate: ^4.5.0`

**Common Patterns:**
```dart
import 'package:flutter_animate/flutter_animate.dart';

// Staggered entrance animation for grid items
GridView.builder(
  itemBuilder: (context, index) {
    final delay = Duration(milliseconds: 30 * (index % columns) + 50 * (index ~/ columns));
    return MyWidget()
      .animate(delay: delay)
      .fadeIn(duration: 300.ms)
      .scale(
        begin: const Offset(0.5, 0.5),
        end: const Offset(1, 1),
        duration: 400.ms,
        curve: Curves.elasticOut,
      );
  },
)

// Correct answer celebration
widget
  .animate()
  .scale(begin: Offset(1, 1), end: Offset(1.15, 1.15), duration: 200.ms)
  .then()
  .scale(begin: Offset(1.15, 1.15), end: Offset(1, 1), duration: 300.ms, curve: Curves.elasticOut)
  .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.4))

// Wrong answer shake
widget
  .animate()
  .shake(hz: 5, rotation: 0.05, duration: 400.ms)
  .tint(color: Colors.red.withOpacity(0.2), duration: 200.ms)

// Hint pulsing glow
widget
  .animate(onPlay: (c) => c.repeat(reverse: true))
  .scale(begin: Offset(1, 1), end: Offset(1.05, 1.05), duration: 600.ms)
  .boxShadow(
    begin: BoxShadow(color: Colors.amber.withOpacity(0), blurRadius: 0),
    end: BoxShadow(color: Colors.amber.withOpacity(0.7), blurRadius: 25, spreadRadius: 8),
    duration: 600.ms,
  )

// Matched card shimmer
widget
  .animate(onPlay: (c) => c.repeat())
  .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3))
```

### The "Pop" Animation

When a correct answer is chosen:
1. Object scales to **1.15-1.3x**
2. Returns to **1.0x**
3. Total duration: **400-500ms**
4. Easing: `Curves.elasticOut`

### Idle Floating Animation

Keeps icons feeling alive when not interacted with:
```dart
// Manual animation controller approach
_idleController = AnimationController(
  duration: Duration(milliseconds: 2000 + random.nextInt(1000)),
  vsync: this,
);
_floatAnimation = Tween<double>(begin: -3, end: 3).animate(
  CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
);
_idleController.repeat(reverse: true);

// Apply in build
Transform.translate(
  offset: Offset(0, _floatAnimation.value),
  child: child,
)
```

### Haptic Feedback

| Action | Implementation | Description |
|--------|----------------|-------------|
| Success | Double light tap | Two quick taps |
| Error | Heavy impact | Gentle buzz |
| Button Tap | Light impact | Single tap |
| Celebration | Medium impact | Stronger confirmation |

```dart
class HapticHelper {
  static void success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  static void error() => HapticFeedback.heavyImpact();
  static void lightTap() => HapticFeedback.lightImpact();
  static void celebration() => HapticFeedback.mediumImpact();
}
```

### Audio/TTS Settings

```dart
// TTS Configuration
await _tts.setSpeechRate(SettingsService.speechRate);
await _tts.setPitch(1.0);  // Natural pitch
await _tts.setVolume(1.0);

// iOS-specific audio settings
await _tts.setIosAudioCategory(
  IosTextToSpeechAudioCategory.playback,
  [
    IosTextToSpeechAudioCategoryOptions.allowBluetooth,
    IosTextToSpeechAudioCategoryOptions.mixWithOthers,
  ],
  IosTextToSpeechAudioMode.voicePrompt,
);

// Preferred voices (clearer for kids)
['Samantha', 'Zoe', 'Nicky', 'Alex', 'Karen']
```

---

## 9. Touch Targets

**Minimum size: 88x88 points** (larger than Apple's 44pt for adults)

| Element | Recommended Size |
|---------|-----------------|
| Game tiles (letters/numbers) | 120-150pt |
| Duo Buttons | 100-120pt height |
| Navigation icons | 88pt minimum |
| Path nodes | 80pt diameter |
| Flag cards | 220x170pt |
| Memory cards | Responsive (min 60pt) |

---

## 10. Animation Timing Reference

| Animation Type | Duration | Easing | Library |
|----------------|----------|--------|---------|
| Button press (3D effect) | 100ms | `easeOut` | Manual |
| Pop effect (correct) | 400-500ms | `elasticOut` | flutter_animate |
| Progress bar fill | 300ms | `easeInOut` | Manual |
| Confetti burst | 2s | Linear | confetti |
| Screen transition | 300ms | `easeInOut` | Navigator |
| Hint pulse | 600ms | Repeating | flutter_animate |
| Error shake | 400ms | flutter_animate | flutter_animate |
| Card flip | 400ms | `easeInOutBack` | Manual |
| Idle float | 2000-3000ms | `easeInOut` | Manual |
| Staggered entrance | 300-400ms | `elasticOut` | flutter_animate |
| Matched shimmer | 800-2000ms | Linear | flutter_animate |
| Wrong tint | 200ms | Linear | flutter_animate |
| Celebration particles | 800ms | `easeOut` | Manual |

---

## 11. Component Checklist for New Games

Before shipping a new game, verify:

- [ ] Uses 3D button with press effect
- [ ] Pop animation on correct answers
- [ ] Double-tap haptic on success
- [ ] Gentle error haptic (not harsh buzz)
- [ ] Voice prompt using TTS
- [ ] Touch targets >= 88pt
- [ ] Nunito font throughout
- [ ] Colors match 3D palette (base + shade)
- [ ] Back button in top-left
- [ ] Round/Score display
- [ ] Confetti on game complete
- [ ] Respects hints setting
- [ ] Works in landscape orientation

---

## 12. File Structure Reference

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart           # 3D Color palette, typography
│   ├── constants/
│   │   └── game_data.dart           # Game definitions
│   └── utils/
│       ├── audio_helper.dart        # TTS + sound effects
│       ├── haptic_helper.dart       # Duolingo-style haptics
│       ├── settings_service.dart    # App settings
│       ├── flag_widget.dart         # SVG flag renderer
│       ├── game_icon.dart           # Rich SVG icon illustrations
│       └── animated_game_icon.dart  # Animated icon wrapper + game card
├── widgets/
│   ├── duo_button.dart              # 3D press button
│   ├── duo_progress_bar.dart        # Progress bar with shine
│   ├── game_app_bar.dart            # Lesson top bar
│   ├── answer_tile.dart             # 3D answer button
│   ├── celebration_overlay.dart     # Confetti + success
│   ├── navigation_buttons.dart      # Back/Exit buttons
│   ├── path_node.dart               # Home screen path nodes
│   └── success_drawer.dart          # Success animations
├── screens/
│   ├── home_screen.dart             # Category navigation
│   └── games/
│       └── [game_name]_game.dart    # Individual games
```
