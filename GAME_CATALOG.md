# Kids Educational App - Game Catalog

Complete documentation of all 21 educational games organized by category.

---

## Category 1: ABC (Blue) - Letters & Reading

Games focused on literacy skills including letter recognition, phonics, and word building.

### 1.1 Identify Letters
**File:** `lib/screens/games/identify_letter_game.dart`

**Description:** Learn to recognize uppercase and lowercase letters by tapping the correct one from multiple options.

**Gameplay:**
- Voice prompt asks "Find the letter [X]"
- 4 letter options displayed as 3D buttons
- Tap correct letter to advance
- 10 rounds per game

**Features:**
- Uppercase and lowercase variants
- TTS voice prompts
- Optional hint system (pulsing animation after 7 seconds)
- Confetti celebration on correct answer
- Score tracking

---

### 1.2 Letter Phonics
**File:** `lib/screens/games/phonics_game.dart`

**Description:** Learn letter sounds through audio. Hear how each letter sounds and match it to the correct letter.

**Gameplay:**
- Audio plays the phonetic sound
- Multiple letter options displayed
- Match the sound to the correct letter

**Features:**
- Audio playback for letter sounds
- Visual letter cards
- Progressive difficulty

---

### 1.3 Words Game
**File:** `lib/screens/games/words_game.dart`

**Description:** Build vocabulary by identifying words and matching them to pictures.

**Gameplay:**
- Image or description shown
- Multiple word options displayed
- Select the matching word

**Features:**
- Picture-word association
- Common kid-friendly vocabulary
- Audio pronunciation

---

### 1.4 Write Letters
**File:** `lib/screens/games/write_letters_game.dart`

**Description:** Practice writing letters by tracing guides on screen.

**Gameplay:**
- Letter template displayed
- Trace the letter with finger
- Feedback on accuracy

**Features:**
- Drawing canvas with flutter_drawing_board
- Letter guides
- Clear and retry options

---

### 1.5 Write Words
**File:** `lib/screens/games/write_words_game.dart`

**Description:** Practice writing simple words by tracing or free writing.

**Gameplay:**
- Word displayed as target
- Write the word on canvas
- Review and continue

**Features:**
- Multi-letter writing
- Word pronunciation
- Drawing tools

---

## Category 2: 123 (Green) - Numbers & Math

Games focused on numeracy skills including number recognition, counting, and basic math.

### 2.1 Identify Numbers
**File:** `lib/screens/games/identify_numbers_game.dart`

**Description:** Learn to recognize numbers 1-20 by tapping the correct number from options.

**Gameplay:**
- Voice prompt asks "Find the number [X]"
- 4 number options displayed as 3D buttons
- Tap correct number to advance
- 10 rounds per game

**Features:**
- Numbers 1-20
- TTS voice prompts
- Optional hint system
- Score tracking

---

### 2.2 Basic Math
**File:** `lib/screens/games/math_game.dart`

**Description:** Simple addition and counting exercises for early math skills.

**Gameplay:**
- Math problem displayed (e.g., 2 + 3 = ?)
- Multiple answer options
- Select correct answer

**Features:**
- Addition problems
- Visual counting aids
- Progressive difficulty
- Optional hints

---

### 2.3 Write Numbers
**File:** `lib/screens/games/write_numbers_game.dart`

**Description:** Practice writing numbers 1-20 by tracing guides.

**Gameplay:**
- Number template displayed
- Trace the number with finger
- Feedback and continue

**Features:**
- Number templates 1-20
- Drawing canvas
- Clear and retry

---

### 2.4 Higher or Lower
**File:** `lib/screens/games/higher_lower_game.dart`

**Description:** Compare two numbers and determine which is higher or lower.

**Gameplay:**
- Two numbers displayed
- Voice asks "Which is higher?" or "Which is lower?"
- Tap the correct number

**Features:**
- Number comparison
- Visual number cards
- TTS prompts

---

### 2.5 Before and After
**File:** `lib/screens/games/before_after_game.dart`

**Description:** Learn number sequences by identifying what comes before or after a given number.

**Gameplay:**
- Number displayed (e.g., "7")
- Asked "What comes before?" or "What comes after?"
- Select from options (6, 8, etc.)

**Features:**
- Number sequence learning
- TTS prompts
- Multiple choice answers

---

## Category 3: Puzzles (Orange) - Brain Games

Puzzle and logic games that develop cognitive and visual skills.

### 3.1 Memory Match
**File:** `lib/screens/games/memory_match_game.dart`

**Description:** Classic memory matching game with illustrated icons. Find pairs by flipping cards.

**Gameplay:**
- Grid of face-down cards
- Flip two cards to find matches
- Match all pairs to win

**Difficulty Levels:**
| Level | Cards | Pairs | Grid |
|-------|-------|-------|------|
| Easy | 20 | 10 | 5x4 |
| Medium | 30 | 15 | 6x5 |
| Hard | 40 | 20 | 8x5 |

**Features:**
- 20 illustrated icons (animals, shapes, nature)
- Card flip animation (300ms)
- Move counter
- Timer
- Difficulty selection

**Icons Used:**
dog, cat, rabbit, fox, bear, penguin, lion, owl, elephant, monkey, fish, bird, turtle, butterfly, star, heart, flower, sun, moon, cloud

---

### 3.2 Maze Adventure
**File:** `lib/screens/games/maze_game.dart`

**Description:** Navigate through mazes by drawing a path from start to finish.

**Gameplay:**
- Maze displayed with start and end points
- Draw path through the maze
- Reach the goal to win

**Features:**
- Multiple maze layouts
- Path drawing
- Progressive difficulty

---

### 3.3 Find Hidden
**File:** `lib/screens/games/find_hidden_game.dart`

**Description:** Find hidden objects in a scene (Where's Waldo style).

**Gameplay:**
- Scene with hidden objects displayed
- Voice prompt tells what to find
- Tap when found

**Features:**
- Interactive scenes
- Object hunting
- TTS prompts
- Optional hints

---

### 3.4 Spot the Difference
**File:** `lib/screens/games/spot_the_difference_game.dart`

**Description:** Find differences between two similar images.

**Gameplay:**
- Two images displayed side by side
- Find and tap the differences
- Complete all differences to win

**Features:**
- Visual comparison
- Multiple differences per round
- Progress tracking

---

### 3.5 Odd One Out
**File:** `lib/screens/games/odd_one_out_game.dart`

**Description:** Identify the item that doesn't belong in a group.

**Gameplay:**
- Grid of items displayed
- One item is different
- Tap the odd one

**Features:**
- Pattern recognition
- Category matching
- Visual comparison

---

## Category 4: Discover (Purple) - World & Learning

Games focused on world knowledge, sorting skills, and life skills.

### 4.1 Country Flags
**File:** `lib/screens/games/flags_game.dart`

**Description:** Learn world flags from 39 countries with high-quality SVG graphics.

**Gameplay:**
- Voice prompt: "Find the flag of [Country]"
- 4 flag options displayed as 3D cards
- Tap correct flag to advance
- 10 rounds per game

**Countries (39 total):**

| Region | Countries |
|--------|-----------|
| Americas | USA, Canada, Brazil, Mexico, Argentina, Chile, Peru, Cuba, Jamaica |
| Europe | UK, France, Germany, Italy, Spain, Ireland, Poland, Ukraine, Portugal, Switzerland, Sweden, Greece, Russia |
| Asia | Japan, China, India, South Korea, Pakistan, Bangladesh, Israel, Vietnam, Indonesia, Turkey, Thailand |
| Oceania | Australia, New Zealand |
| Africa | South Africa, Egypt, Nigeria, Kenya |

**SVG Flags (18):**
Japan, France, Germany, Italy, Ireland, Poland, Ukraine, Indonesia, Bangladesh, Switzerland, Sweden, Greece, Thailand, Nigeria, Peru, Chile, Turkey, Vietnam

**Features:**
- High-quality SVG flag rendering
- Emoji fallback for unsupported flags
- TTS country name pronunciation
- 3D card press effect
- Score tracking

---

### 4.2 Calendar & Date
**File:** `lib/screens/games/calendar_game.dart`

**Description:** Learn days of the week and months of the year.

**Gameplay:**
- Calendar concepts displayed
- Questions about days/months
- Select correct answers

**Features:**
- Days of week
- Months of year
- Date concepts
- Optional hints

---

### 4.3 Music Notes
**File:** `lib/screens/games/music_notes_game.dart`

**Description:** Learn musical notes and basic music theory.

**Gameplay:**
- Musical staff displayed
- Notes shown and played
- Identify the correct note

**Features:**
- Audio playback of notes
- Visual musical staff
- Note identification
- Optional hints

---

### 4.4 Color Sort
**File:** `lib/screens/games/color_sort_game.dart`

**Description:** Sort items by their colors into matching containers.

**Gameplay:**
- Colored items displayed
- Color containers at bottom
- Drag items to matching colors

**Features:**
- Color recognition
- Drag and drop
- Multiple colors

---

### 4.5 Big to Small
**File:** `lib/screens/games/big_to_small_game.dart`

**Description:** Arrange items in order from biggest to smallest (or smallest to biggest).

**Gameplay:**
- Items of different sizes displayed
- Arrange in correct order
- Complete to win

**Features:**
- Size comparison
- Ordering skills
- Visual feedback

---

### 4.6 Chore Tracker
**File:** `lib/screens/games/chore_tracker_game.dart`

**Description:** Interactive daily task chart for building routines.

**Gameplay:**
- Daily chores displayed
- Mark tasks as complete
- Track progress

**Features:**
- Daily routine building
- Task completion
- Reward system

---

## Game Implementation Patterns

### Standard Game Structure

All games follow a consistent structure:

```dart
class [Game]Game extends StatefulWidget {
  const [Game]Game({super.key});

  @override
  State<[Game]Game> createState() => _[Game]GameState();
}

class _[Game]GameState extends State<[Game]Game> {
  late ConfettiController _confettiController;

  int _round = 0;
  final int _totalRounds = 10;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(...);
    AudioHelper.init();
    _startNewRound();
  }

  void _startNewRound() {
    // Setup next question
    if (SettingsService.hintsEnabled) {
      _startHintTimer();
    }
    _speakPrompt();
  }

  void _onCorrectAnswer() {
    HapticHelper.success();
    _confettiController.play();
    AudioHelper.speakSuccess();
    // Advance to next round
  }

  void _onWrongAnswer() {
    HapticHelper.error();
    AudioHelper.speakTryAgain();
  }
}
```

### Common Widgets Used

| Widget | Purpose |
|--------|---------|
| `GameBackButton` | Navigation back button |
| `CelebrationOverlay` | Confetti on success |
| `GameCompleteDialog` | End-of-game summary |
| `ConfettiController` | Confetti animation control |

### Audio Methods

| Method | When Used |
|--------|-----------|
| `AudioHelper.speak(text)` | Voice prompts |
| `AudioHelper.speakSuccess()` | Correct answer |
| `AudioHelper.speakTryAgain()` | Wrong answer |
| `AudioHelper.speakGameComplete()` | Game finished |

### Haptic Methods

| Method | When Used |
|--------|-----------|
| `HapticHelper.lightTap()` | Button press |
| `HapticHelper.success()` | Correct answer |
| `HapticHelper.error()` | Wrong answer |
| `HapticHelper.celebration()` | Game complete |

---

## Category Summary

| Category | Color | Emoji | Games | Focus |
|----------|-------|-------|-------|-------|
| ABC | Blue (#1CB0F6) | 📚 | 5 | Letters, phonics, words |
| 123 | Green (#58CC02) | 🔢 | 5 | Numbers, math, counting |
| Puzzles | Orange (#FF9600) | 🧩 | 5 | Memory, logic, visual |
| Discover | Purple (#CE82FF) | 🌍 | 6 | World, sorting, life skills |
