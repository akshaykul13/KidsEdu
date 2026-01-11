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
| Body M | Bold (700) | 18pt | `#777777` | Instructions, Dialogues |
| Button Text | ExtraBold (800) | 16pt | `#FFFFFF` | "CONTINUE", "START" |
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

| Category | Base Color | Shade Color (4px Bottom) | Visual Purpose |
|----------|------------|--------------------------|----------------|
| Primary | `#1CB0F6` (Blue) | `#1899D6` | Brand, Path Nodes, Info |
| Success | `#58CC02` (Green) | `#46A302` | Correct, Continue, Progress |
| Attention | `#FFC800` (Yellow) | `#E5A400` | Review, Gold Levels, Stars |
| Energy | `#FF9600` (Orange) | `#E58700` | Streaks, Special Nodes |
| Error | `#FF4B4B` (Red) | `#D33131` | Mistakes, Try Again |
| Neutral | `#E5E5E5` (Gray) | `#AFB4BD` | Locked Levels, Troughs |

### Additional UI Colors
| Name | Hex | Usage |
|------|-----|-------|
| Background | `#FFFFFF` | Main app background |
| Text Primary | `#4B4B4B` | Headlines, important text |
| Text Secondary | `#777777` | Instructions, body text |
| Text Muted | `#AFAFAF` | Tooltips, labels |

---

## 3. Core UI Components

### A. The "Duo" Button (Standard & Wide)

The signature Duolingo button with a 3D press effect.

**Structure:**
- A `Stack` with two layers: the shadow (shade color) and the top button (base color)
- Corner Radius: **16pt**
- Shadow Height: **4pt** (visible at bottom when not pressed)
- Padding: **16pt horizontal, 12pt vertical**

**Interaction:**
- On `TouchDown`: Top layer moves down 4pt, shadow disappears
- On `TouchUp`: Top layer returns to original position

```dart
class DuoButton extends StatefulWidget {
  final String text;
  final Color baseColor;
  final Color shadeColor;
  final VoidCallback onTap;

  // ... implementation
}

// The 3D effect is created by:
// 1. Bottom container (shade) with full height
// 2. Top container (base) positioned 4pt above bottom
// 3. On press, top moves down 4pt to meet bottom
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

```dart
Stack(
  children: [
    // Trough
    Container(height: 16, decoration: BoxDecoration(
      color: Color(0xFFE5E5E5),
      borderRadius: BorderRadius.circular(8),
    )),
    // Fill
    FractionallySizedBox(
      widthFactor: progress,
      child: Container(
        height: 16,
        decoration: BoxDecoration(
          color: Color(0xFF58CC02),
          borderRadius: BorderRadius.circular(8),
        ),
        child: // Shine overlay
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
          ),
      ),
    ),
  ],
)
```

### C. The Learning Path Node

**Shape:** Circle, usually **80x80pt**

**Active Node:**
- Has the Shade Color underneath (4pt offset)
- Small white "highlight" arc on top (shine effect)

**Progress Ring:**
- A circular border around the node
- Fills from 0% to 100% as sub-levels are completed
- Stroke width: **4pt**

---

## 4. Screen Layout Specs (iOS Safe Areas)

### The Home Path Screen

**Header:**
- Floating "Status Bar" showing Star Count and Unit Name
- Background: Transparent or matching the Unit theme

**The Path:**
- Use a `ScrollView`
- Nodes staggered in an **"S-curve"** pattern: Center → Right-ish → Center → Left-ish
- Vertical spacing: **32pt** between nodes

**Layout Example:**
```
       [Node 1]
              [Node 2]
       [Node 3]
  [Node 4]
       [Node 5]
```

### The Lesson Screen

**Top Bar:**
- Exit (X) icon on the **left**
- Progress Bar in the **middle**
- Height: Respects safe area

**Content Area:**
- Large central area for game mechanics
- Contains images, cards, answer options

**Bottom Interaction Zone:**
- Permanent white footer (`#FFFFFF`)
- **2pt top border** (`#E5E5E5`)
- Contains "Check" or "Continue" button
- Button centered, full width with padding

---

## 5. UX Patterns for Incremental Complexity

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

## 6. Motion & Sound (The "Juice")

A game feels "premium" when it reacts to the user. These micro-interactions are essential.

### The "Pop" Animation

When a correct answer is chosen:
1. Object scales to **1.2x**
2. Returns to **1.0x**
3. Total duration: **0.2 seconds**
4. Easing: `Curves.elasticOut`

```dart
// Pop animation controller
AnimatedScale(
  scale: isCorrect ? 1.2 : 1.0,
  duration: Duration(milliseconds: 200),
  curve: Curves.elasticOut,
  child: answerWidget,
)
```

### Haptic Feedback

| Action | iOS Implementation | Description |
|--------|-------------------|-------------|
| Success | `UIImpactFeedbackGenerator(style: .light)` — tap **twice rapidly** | Light double-tap feel |
| Error | `UINotificationFeedbackGenerator().notificationOccurred(.error)` | Gentle buzz |
| Button Tap | `UIImpactFeedbackGenerator(style: .light)` | Single light tap |
| Achievement | `UIImpactFeedbackGenerator(style: .medium)` | Stronger confirmation |

```dart
// Flutter implementation
class HapticHelper {
  static void success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  static void error() {
    HapticFeedback.heavyImpact(); // Simulates notification error
  }

  static void lightTap() {
    HapticFeedback.lightImpact();
  }
}
```

### Audio Cues

| Event | Sound | Characteristics |
|-------|-------|-----------------|
| Success | Rising major-scale "Ding!" | Bright, celebratory, ~0.5s |
| Failure | Soft, low-pitched "Bloop" | Never a loud buzzer, gentle |
| Button tap | Soft click | Subtle, not distracting |
| Level complete | Fanfare | Short celebration, ~1s |

---

## 7. Touch Targets

**Minimum size: 88x88 points** (larger than Apple's 44pt for adults)

| Element | Recommended Size |
|---------|-----------------|
| Game tiles (letters/numbers) | 120-150pt |
| Duo Buttons | 100-120pt height |
| Navigation icons | 88pt minimum |
| Path nodes | 80pt diameter |

---

## 8. Animation Timing Reference

| Animation Type | Duration | Easing |
|----------------|----------|--------|
| Button press (3D effect) | 100ms | `easeOut` |
| Pop effect (correct answer) | 200ms | `elasticOut` |
| Progress bar fill | 300ms | `easeInOut` |
| Confetti burst | 1.5-2s | Linear |
| Screen transition | 300ms | `easeInOut` |
| Hint pulse | 500ms | Repeating |
| Error shake | 300ms | `easeInOut` |

---

## 9. Component Checklist for New Games

Before shipping a new game, verify:

- [ ] Uses DuoButton with 3D press effect
- [ ] Progress bar has shine effect
- [ ] Pop animation on correct answers
- [ ] Double-tap haptic on success
- [ ] Gentle error haptic (not harsh buzz)
- [ ] Rising "ding" sound on success
- [ ] Soft "bloop" on errors
- [ ] Touch targets ≥ 88pt
- [ ] Nunito font throughout
- [ ] Colors match 3D palette (base + shade)
- [ ] Exit button in top-left
- [ ] Progress shown in top bar

---

## 10. File Structure Reference

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart      # 3D Color palette, typography
│   ├── constants/
│   │   └── game_data.dart      # Game definitions
│   └── utils/
│       ├── audio_helper.dart   # TTS + sound effects
│       └── haptic_helper.dart  # Duolingo-style haptics
├── widgets/
│   ├── duo_button.dart         # 3D press button
│   ├── duo_progress_bar.dart   # Progress bar with shine
│   ├── game_app_bar.dart       # Lesson top bar
│   ├── answer_tile.dart        # 3D answer button
│   ├── celebration_overlay.dart # Confetti + success
│   ├── path_node.dart          # Home screen path nodes
│   └── navigation_buttons.dart  # Back/Exit buttons
├── screens/
│   ├── home_screen.dart
│   └── games/
│       └── [game_name]_game.dart
```
