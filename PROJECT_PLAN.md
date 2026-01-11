# Kids Educational App - Project Plan

## Overview
Educational games app for kids aged 4-6, built with Flutter for iPad deployment. Features a Duolingo-style "Chunky Tactile" aesthetic with 3D buttons, engaging animations, and audio feedback.

**See also:**
- [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) - UX patterns, color palette, interaction guidelines
- [GAME_CATALOG.md](./GAME_CATALOG.md) - Detailed documentation of all games
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Technical architecture and code structure

---

## Tech Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| Framework | Flutter 3.10+ | Cross-platform UI |
| Platform | iOS (iPad) | Target deployment |
| State | Provider | State management |
| Storage | SharedPreferences, Hive | Settings & progress |
| Audio | flutter_tts, audioplayers | Voice & sounds |
| Drawing | flutter_drawing_board | Writing games |
| Animations | Lottie, Confetti | Celebrations |
| Graphics | flutter_svg | Vector flags |
| Typography | google_fonts (Nunito) | Kid-friendly fonts |

---

## Games Status (21 Total)

### ABC - Letters & Reading (5 Games)
| Game | Status | Description |
|------|--------|-------------|
| Identify Letters | Complete | Tap the correct letter from options |
| Letter Phonics | Complete | Learn letter sounds with audio |
| Words Game | Complete | Build and identify words |
| Write Letters | Complete | Trace and write ABC |
| Write Words | Complete | Write simple words |

### 123 - Numbers & Math (5 Games)
| Game | Status | Description |
|------|--------|-------------|
| Identify Numbers | Complete | Learn numbers 1-20 |
| Basic Math | Complete | Addition and counting |
| Write Numbers | Complete | Trace and write 1-20 |
| Higher/Lower | Complete | Compare number values |
| Before/After | Complete | Number sequence ordering |

### Puzzles - Brain Games (5 Games)
| Game | Status | Description |
|------|--------|-------------|
| Memory Match | Complete | Find matching pairs with illustrated icons |
| Maze Adventure | Complete | Find path from A to B |
| Find Hidden | Complete | Find Waldo-style game |
| Spot the Difference | Complete | Find differences between images |
| Odd One Out | Complete | Find the different item |

### Discover - World & Learning (6 Games)
| Game | Status | Description |
|------|--------|-------------|
| Country Flags | Complete | Learn 39 world flags with SVG graphics |
| Calendar & Date | Complete | Learn days and months |
| Music Notes | Complete | Learn musical notes |
| Color Sort | Complete | Sort items by color |
| Big to Small | Complete | Size ordering game |
| Chore Tracker | Complete | Daily tasks chart |

---

## Features

### Core Features
- [x] **21 Educational Games** across 4 categories
- [x] **Duolingo-style UI** with 3D chunky buttons
- [x] **Voice Prompts (TTS)** with adjustable speed
- [x] **Haptic Feedback** for all interactions
- [x] **Confetti Celebrations** on success
- [x] **Hint System** (optional, configurable)
- [x] **Illustrated Icons** - Custom vector animal/shape icons
- [x] **SVG Flags** - High-quality country flags

### Settings
- [x] **Hints Toggle** - Enable/disable hint system (default: off)
- [x] **Sound Toggle** - Enable/disable audio
- [x] **Voice Speed** - Slow/Normal/Fast speech rate

### UI/UX
- [x] **Category-based Navigation** - 4 color-coded categories
- [x] **Large Touch Targets** - 88pt minimum for kids
- [x] **Landscape Mode** - Optimized for iPad
- [x] **Mascot & Speech Bubbles** - Engaging welcome screen

---

## Project Structure

```
lib/
├── main.dart                         # App entry point
├── core/
│   ├── constants/
│   │   └── game_data.dart            # Game definitions
│   ├── theme/
│   │   └── app_theme.dart            # Colors & typography
│   └── utils/
│       ├── audio_helper.dart         # TTS wrapper with settings
│       ├── haptic_helper.dart        # iOS Taptic Engine
│       ├── settings_service.dart     # App settings (hints, sound, speed)
│       ├── flag_widget.dart          # SVG flag renderer
│       └── illustrated_icons.dart    # Custom vector icons
├── screens/
│   ├── home_screen.dart              # Category navigation
│   └── games/
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
├── widgets/
│   ├── navigation_buttons.dart       # Back/Home buttons (88pt)
│   ├── game_app_bar.dart             # Standard game header
│   ├── answer_tile.dart              # Reusable answer button
│   ├── duo_button.dart               # 3D press button
│   ├── duo_progress_bar.dart         # Progress bar with shine
│   ├── celebration_overlay.dart      # Confetti + dialogs
│   ├── success_drawer.dart           # Success animations
│   └── path_node.dart                # Home screen nodes
└── services/                         # Future: cloud sync, etc.

assets/
├── images/
├── lottie/
└── flags/
```

---

## Dependencies

```yaml
dependencies:
  # UI & Icons
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.0.10+1
  google_fonts: ^6.1.0

  # Audio
  audioplayers: ^6.1.0
  flutter_tts: ^4.2.0

  # Drawing
  flutter_drawing_board: ^0.9.1

  # State & Storage
  provider: ^6.1.2
  shared_preferences: ^2.3.4
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Animations
  lottie: ^3.1.3
  confetti: ^0.8.0
```

---

## Design Principles

1. **Large Touch Targets** - Minimum 88pt for small fingers
2. **Bright Colors** - Engaging, high-contrast palette
3. **No Time Pressure** - Learning at child's pace
4. **Positive Reinforcement** - Confetti, sounds, haptics
5. **Audio Guidance** - TTS for non-readers
6. **3D Visual Feedback** - Buttons feel like toys
7. **Configurable Difficulty** - Hints can be toggled

---

## Future Enhancements

- [ ] Progress tracking and badges
- [ ] Parent dashboard
- [ ] Cloud sync for multi-device
- [ ] More languages
- [ ] Additional game categories
- [ ] Accessibility improvements
