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
| Letters & Words | `#1CB0F6` | `#1899D6` | Literacy games |
| Numbers | `#58CC02` | `#46A302` | Math games |
| Games | `#FF9600` | `#E58700` | Puzzle games |
| General Knowledge | `#CE82FF` | `#B066E0` | World learning |

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

## 4. Custom Graphics

### A. Illustrated Icons

Custom vector icons drawn with `CustomPaint` for consistent visual style.

**Available Icons (20):**
| Animals | Nature/Shapes |
|---------|---------------|
| cat, dog, rabbit, bear | star, heart, flower |
| fox, owl, elephant, lion | sun, moon, cloud |
| monkey, penguin, fish, bird | |
| turtle, butterfly | |

**Usage:**
```dart
IllustratedIcon(
  iconId: 'cat',
  size: 60,
  backgroundColor: Colors.orange.withOpacity(0.1),
)
```

**Implementation:**
- Each icon is drawn programmatically using `CustomPaint`
- Primary and accent colors for each icon
- Fallback to emoji if icon not found

### B. Flag Widget

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

### The "Pop" Animation

When a correct answer is chosen:
1. Object scales to **1.2x**
2. Returns to **1.0x**
3. Total duration: **200ms**
4. Easing: `Curves.elasticOut`

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

| Animation Type | Duration | Easing |
|----------------|----------|--------|
| Button press (3D effect) | 100ms | `easeOut` |
| Pop effect (correct answer) | 200ms | `elasticOut` |
| Progress bar fill | 300ms | `easeInOut` |
| Confetti burst | 2s | Linear |
| Screen transition | 300ms | `easeInOut` |
| Hint pulse | 500ms | Repeating |
| Error shake | 300ms | `easeInOut` |
| Card flip | 300ms | `easeInOut` |

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
│   │   └── app_theme.dart         # 3D Color palette, typography
│   ├── constants/
│   │   └── game_data.dart         # Game definitions
│   └── utils/
│       ├── audio_helper.dart      # TTS + sound effects
│       ├── haptic_helper.dart     # Duolingo-style haptics
│       ├── settings_service.dart  # App settings
│       ├── flag_widget.dart       # SVG flag renderer
│       └── illustrated_icons.dart # Custom vector icons
├── widgets/
│   ├── duo_button.dart            # 3D press button
│   ├── duo_progress_bar.dart      # Progress bar with shine
│   ├── game_app_bar.dart          # Lesson top bar
│   ├── answer_tile.dart           # 3D answer button
│   ├── celebration_overlay.dart   # Confetti + success
│   ├── navigation_buttons.dart    # Back/Exit buttons
│   ├── path_node.dart             # Home screen path nodes
│   └── success_drawer.dart        # Success animations
├── screens/
│   ├── home_screen.dart           # Category navigation
│   └── games/
│       └── [game_name]_game.dart  # Individual games
```
