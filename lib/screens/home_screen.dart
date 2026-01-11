import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/game_data.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/audio_helper.dart';
import '../core/utils/haptic_helper.dart';
import '../widgets/duo_button.dart';
import 'games/identify_letter_game.dart';
import 'games/phonics_game.dart';
import 'games/words_game.dart';
import 'games/identify_numbers_game.dart';
import 'games/math_game.dart';
import 'games/write_letters_game.dart';
import 'games/write_words_game.dart';
import 'games/write_numbers_game.dart';
import 'games/music_notes_game.dart';
import 'games/flags_game.dart';
import 'games/maze_game.dart';
import 'games/find_hidden_game.dart';
import 'games/calendar_game.dart';
import 'games/chore_tracker_game.dart';
import 'games/memory_match_game.dart';
import 'games/higher_lower_game.dart';
import 'games/before_after_game.dart';
import 'games/odd_one_out_game.dart';
import 'games/spot_the_difference_game.dart';
import 'games/color_sort_game.dart';
import 'games/big_to_small_game.dart';
import '../core/utils/settings_service.dart';
import '../core/utils/audio_helper.dart';

/// Category definition for home screen navigation
class HomeCategory {
  final String id;
  final String name;
  final String emoji;
  final Color baseColor;
  final Color shadeColor;
  final List<String> gameIds;

  const HomeCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.baseColor,
    required this.shadeColor,
    required this.gameIds,
  });
}

/// Categories with their games
class Categories {
  static const lettersAndWords = HomeCategory(
    id: 'letters_words',
    name: 'Letters & Words',
    emoji: '📚',
    baseColor: Color(0xFF1CB0F6),  // Blue
    shadeColor: Color(0xFF1899D6),
    gameIds: ['identify_letter', 'phonics', 'words', 'write_letters', 'write_words'],
  );

  static const numbers = HomeCategory(
    id: 'numbers',
    name: 'Numbers',
    emoji: '🔢',
    baseColor: Color(0xFF58CC02),  // Green
    shadeColor: Color(0xFF46A302),
    gameIds: ['identify_numbers', 'math', 'write_numbers', 'higher_lower', 'before_after'],
  );

  static const games = HomeCategory(
    id: 'games',
    name: 'Games',
    emoji: '🎮',
    baseColor: Color(0xFFFF9600),  // Orange
    shadeColor: Color(0xFFE58700),
    gameIds: ['maze', 'find_hidden', 'memory_match', 'odd_one_out', 'spot_difference', 'color_sort', 'big_to_small'],
  );

  static const generalKnowledge = HomeCategory(
    id: 'general_knowledge',
    name: 'General Knowledge',
    emoji: '🌍',
    baseColor: Color(0xFFCE82FF),  // Purple
    shadeColor: Color(0xFFB066E0),
    gameIds: ['music_notes', 'flags', 'calendar', 'chores'],
  );

  static const List<HomeCategory> all = [
    lettersAndWords,
    numbers,
    games,
    generalKnowledge,
  ];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalStars = 0;
  HomeCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _greetUser();
  }

  Future<void> _greetUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    AudioHelper.speak("Hi there! Ready to play?");
  }

  void _selectCategory(HomeCategory category) {
    HapticHelper.lightTap();
    setState(() => _selectedCategory = category);
    AudioHelper.speak(category.name);
  }

  void _goBack() {
    HapticHelper.lightTap();
    setState(() => _selectedCategory = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),

            // Hero area with mascot
            if (_selectedCategory == null) _buildHeroArea(),

            // Content: Categories or Games
            Expanded(
              child: _selectedCategory == null
                  ? _buildCategoryGrid()
                  : _buildGameGrid(_selectedCategory!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Back button (when in category) or Settings
          if (_selectedCategory != null)
            _BackButton(onTap: _goBack)
          else
            _SettingsButton(onLongPress: _showParentalGate),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              _selectedCategory?.name ?? 'Choose a Category',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 16),

          // Stars
          _StarCounter(count: _totalStars),
        ],
      ),
    );
  }

  Widget _buildHeroArea() {
    return GestureDetector(
      onTap: () {
        HapticHelper.lightTap();
        AudioHelper.speak("Hi there! Ready to play? Tap a category to start!");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neutral, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascot
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryShade,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🦉', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(width: 20),
            // Speech bubble
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        "What do you want to learn today?",
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: Categories.all.length,
            itemBuilder: (context, index) {
              final category = Categories.all[index];
              return _CategoryTile(
                category: category,
                onTap: () => _selectCategory(category),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameGrid(HomeCategory category) {
    // Get games for this category
    final categoryGames = category.gameIds
        .map((id) => GameData.games.firstWhere(
              (g) => g.id == id,
              orElse: () => GameInfo(
                id: id,
                title: id,
                description: '',
                icon: Icons.games,
                color: category.baseColor,
                category: GameCategory.literacy,
                route: '/$id',
              ),
            ))
        .toList();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categoryGames.length,
            itemBuilder: (context, index) {
              final game = categoryGames[index];
              return _GameTile(
                game: game,
                baseColor: category.baseColor,
                shadeColor: category.shadeColor,
                onTap: () => _navigateToGame(game),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToGame(GameInfo game) {
    HapticHelper.lightTap();
    Widget? gameScreen;

    switch (game.id) {
      case 'identify_letter':
        gameScreen = const IdentifyLetterGame();
        break;
      case 'phonics':
        gameScreen = const PhonicsGame();
        break;
      case 'words':
        gameScreen = const WordsGame();
        break;
      case 'identify_numbers':
        gameScreen = const IdentifyNumbersGame();
        break;
      case 'math':
        gameScreen = const MathGame();
        break;
      case 'write_letters':
        gameScreen = const WriteLettersGame();
        break;
      case 'write_words':
        gameScreen = const WriteWordsGame();
        break;
      case 'write_numbers':
        gameScreen = const WriteNumbersGame();
        break;
      case 'music_notes':
        gameScreen = const MusicNotesGame();
        break;
      case 'flags':
        gameScreen = const FlagsGame();
        break;
      case 'maze':
        gameScreen = const MazeGame();
        break;
      case 'find_hidden':
        gameScreen = const FindHiddenGame();
        break;
      case 'memory_match':
        gameScreen = const MemoryMatchGame();
        break;
      case 'calendar':
        gameScreen = const CalendarGame();
        break;
      case 'chores':
        gameScreen = const ChoreTrackerGame();
        break;
      case 'higher_lower':
        gameScreen = const HigherLowerGame();
        break;
      case 'before_after':
        gameScreen = const BeforeAfterGame();
        break;
      case 'odd_one_out':
        gameScreen = const OddOneOutGame();
        break;
      case 'spot_difference':
        gameScreen = const SpotTheDifferenceGame();
        break;
      case 'color_sort':
        gameScreen = const ColorSortGame();
        break;
      case 'big_to_small':
        gameScreen = const BigToSmallGame();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${game.title} - Coming soon!'),
            backgroundColor: _selectedCategory?.baseColor ?? AppColors.primary,
          ),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameScreen!),
    );
  }

  void _showParentalGate() {
    showDialog(
      context: context,
      builder: (context) => _ParentalGateDialog(),
    );
  }
}

/// Back button with 3D effect
class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: 52,
        height: 56,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.neutralShade,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              top: _isPressed ? 4 : 0,
              left: 0,
              right: 0,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.neutral,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 28,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings button with 3D effect
class _SettingsButton extends StatefulWidget {
  final VoidCallback onLongPress;
  const _SettingsButton({required this.onLongPress});

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticHelper.lightTap();
        widget.onLongPress();
      },
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: 52,
        height: 56,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.neutralShade,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              top: _isPressed ? 4 : 0,
              left: 0,
              right: 0,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.neutral,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  size: 28,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Star counter
class _StarCounter extends StatelessWidget {
  final int count;
  const _StarCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.attention,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.attentionShade,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Category tile with 3D effect - properly sized
class _CategoryTile extends StatefulWidget {
  final HomeCategory category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _isPressed = false;
  static const double _shadowOffset = 6.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticHelper.buttonDown();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Stack(
        children: [
          // Shadow
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: _shadowOffset,
            child: Container(
              decoration: BoxDecoration(
                color: widget.category.shadeColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Face
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            top: _isPressed ? _shadowOffset : 0,
            bottom: _isPressed ? 0 : _shadowOffset,
            child: Container(
              decoration: BoxDecoration(
                color: widget.category.baseColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji
                  Text(
                    widget.category.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  // Category name - BIG
                  Text(
                    widget.category.name,
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Game tile with 3D effect
class _GameTile extends StatefulWidget {
  final GameInfo game;
  final Color baseColor;
  final Color shadeColor;
  final VoidCallback onTap;

  const _GameTile({
    required this.game,
    required this.baseColor,
    required this.shadeColor,
    required this.onTap,
  });

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile> {
  bool _isPressed = false;
  static const double _shadowOffset = 5.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticHelper.buttonDown();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Stack(
        children: [
          // Shadow
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: _shadowOffset,
            child: Container(
              decoration: BoxDecoration(
                color: widget.shadeColor,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          // Face
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            top: _isPressed ? _shadowOffset : 0,
            bottom: _isPressed ? 0 : _shadowOffset,
            child: Container(
              decoration: BoxDecoration(
                color: widget.baseColor,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    widget.game.icon,
                    size: 44,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  // Title - BIG
                  Text(
                    widget.game.title,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Parental gate dialog
class _ParentalGateDialog extends StatefulWidget {
  @override
  State<_ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<_ParentalGateDialog> {
  final int _num1 = 5 + (DateTime.now().second % 5);
  final int _num2 = 2 + (DateTime.now().millisecond % 5);
  final _controller = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔒 Parents Only',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What is $_num1 + $_num2?',
              style: GoogleFonts.nunito(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Enter answer',
                errorText: _error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: DuoButton.primary(
                text: 'ENTER',
                onTap: _checkAnswer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswer() {
    final answer = int.tryParse(_controller.text);
    if (answer == _num1 + _num2) {
      Navigator.pop(context);
      // Show settings dialog
      showDialog(
        context: context,
        builder: (context) => const _SettingsDialog(),
      );
    } else {
      setState(() => _error = 'Try again');
    }
  }
}

/// Settings dialog
class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog();

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  bool _hintsEnabled = SettingsService.hintsEnabled;
  bool _soundEnabled = SettingsService.soundEnabled;
  int _speechSpeed = SettingsService.speechSpeed;

  String get _speechSpeedLabel {
    switch (_speechSpeed) {
      case 0: return 'Slow';
      case 1: return 'Normal';
      case 2: return 'Fast';
      default: return 'Slow';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '⚙️ Settings',
              style: GoogleFonts.nunito(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            // Speech Speed
            _SpeechSpeedTile(
              value: _speechSpeed,
              label: _speechSpeedLabel,
              onChanged: (value) async {
                setState(() => _speechSpeed = value);
                await SettingsService.setSpeechSpeed(value);
                await AudioHelper.updateSpeechRate();
                // Test the new speed
                AudioHelper.speak('This is how I sound now');
              },
            ),
            const SizedBox(height: 16),
            // Hints toggle
            _SettingsTile(
              icon: Icons.lightbulb_outline,
              title: 'Hints',
              subtitle: 'Show hints after a few seconds',
              value: _hintsEnabled,
              onChanged: (value) async {
                setState(() => _hintsEnabled = value);
                await SettingsService.setHintsEnabled(value);
              },
            ),
            const SizedBox(height: 16),
            // Sound toggle
            _SettingsTile(
              icon: Icons.volume_up_rounded,
              title: 'Sound',
              subtitle: 'Voice prompts and sounds',
              value: _soundEnabled,
              onChanged: (value) async {
                setState(() => _soundEnabled = value);
                await SettingsService.setSoundEnabled(value);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: DuoButton.primary(
                text: 'DONE',
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings toggle tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: value ? AppColors.success : AppColors.neutral,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: value ? Colors.white : AppColors.textSecondary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

/// Speech speed selector tile
class _SpeechSpeedTile extends StatelessWidget {
  final int value;
  final String label;
  final ValueChanged<int> onChanged;

  const _SpeechSpeedTile({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.speed_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Speed',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'How fast the voice speaks',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Speed buttons
          Row(
            children: [
              Expanded(
                child: _SpeedButton(
                  label: '🐢 Slow',
                  isSelected: value == 0,
                  onTap: () => onChanged(0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SpeedButton(
                  label: '🚶 Normal',
                  isSelected: value == 1,
                  onTap: () => onChanged(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SpeedButton(
                  label: '🏃 Fast',
                  isSelected: value == 2,
                  onTap: () => onChanged(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Speed button
class _SpeedButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeedButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.success : AppColors.neutral,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
