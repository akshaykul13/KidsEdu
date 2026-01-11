# Kids Educational App - Project Plan

## Overview
Educational games app for kids aged 4-6, built with Flutter for iPad deployment.

**See also:** [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) for UX patterns, color palette, and interaction guidelines.

## Tech Stack
- **Framework**: Flutter
- **Target Platform**: iOS (iPad)
- **Development**: Mac (all development and deployment)
- **State Management**: Provider
- **Local Storage**: Hive, SharedPreferences
- **Audio**: audioplayers
- **Drawing**: flutter_drawing_board
- **Animations**: Lottie, Confetti

---

## Games Checklist

### Literacy (Blue)
- [ ] **Letter Phonics** - Learn letter sounds with audio
- [x] **Identify Letters** - Tap to identify letters ✓
- [ ] **Build Words** - Make simple 3-4 letter words using phonics

### Numeracy (Green)
- [ ] **Identify Numbers** - Learn numbers 1-20
- [ ] **Basic Math** - Addition and counting

### Writing (Orange)
- [ ] **Write Letters** - Trace and write ABC
- [ ] **Write Words** - Write simple words
- [ ] **Write Numbers** - Trace and write 1-20

### Music (Purple)
- [ ] **Music Notes** - Learn musical notes

### World (Pink)
- [ ] **Country Flags** - Learn world flags

### Puzzles (Blue/Teal)
- [ ] **Maze Adventure** - Find path from A to B
- [ ] **Find Hidden** - Find Waldo-type game

### Life Skills (Red/Yellow)
- [ ] **Calendar & Date** - Learn days and months
- [ ] **Chore Tracker** - Daily tasks chart

---

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── core/
│   ├── constants/
│   │   └── game_data.dart         # Game definitions
│   ├── theme/
│   │   └── app_theme.dart         # Colors (Candy Bright palette)
│   └── utils/
│       ├── audio_helper.dart      # TTS wrapper
│       └── haptic_helper.dart     # iOS Taptic Engine
├── screens/
│   ├── home_screen.dart           # Activity Map with mascot
│   └── games/
│       ├── identify_letter_game.dart
│       └── (other games...)
├── widgets/
│   ├── navigation_buttons.dart    # Back/Home buttons (88pt)
│   ├── game_app_bar.dart          # Standard game header
│   ├── answer_tile.dart           # Reusable answer button with hints
│   └── celebration_overlay.dart   # Confetti + game complete dialog
└── services/                      # Storage, etc.

assets/
├── images/
├── audio/
└── fonts/
```

---

## Current Progress

### Completed
- [x] Project setup with dependencies
- [x] Game data structure (14 games defined)
- [x] App theme with Candy Bright palette
- [x] Main app entry with landscape mode
- [x] Design System document (DESIGN_SYSTEM.md)
- [x] Reusable widgets (navigation, answer tiles, celebrations)
- [x] Haptic feedback helper
- [x] Audio/TTS helper
- [x] Home screen with Activity Map layout
  - Mascot with speech bubble
  - Parental gate (math question)
  - My Badges section
- [x] Identify Letters game
  - Voice prompts
  - 7-second hint system
  - Haptic feedback
  - Confetti celebrations

### Next Up
- Letter Phonics game
- Identify Numbers game

---

## Development Notes

### Design Principles
- Large touch targets for small fingers
- Bright, engaging colors
- No time pressure
- Positive reinforcement (confetti, sounds)
- Landscape orientation for iPad

### Audio Assets Needed
- Letter sounds (A-Z phonics)
- Number sounds (1-20)
- Music notes
- Success/celebration sounds
- Button tap sounds
