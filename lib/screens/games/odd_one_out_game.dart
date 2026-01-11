import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Difficulty levels for Odd One Out
enum OddOneOutDifficulty {
  easy(name: 'Easy', description: '3 same items + 1 different'),
  hard(name: 'Hard', description: 'Category-based matching');

  final String name;
  final String description;

  const OddOneOutDifficulty({required this.name, required this.description});
}

/// Odd One Out Game - Find the item that doesn't belong
class OddOneOutGame extends StatefulWidget {
  const OddOneOutGame({super.key});

  @override
  State<OddOneOutGame> createState() => _OddOneOutGameState();
}

class _OddOneOutGameState extends State<OddOneOutGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  OddOneOutDifficulty? _difficulty;
  int _round = 0;
  final int _totalRounds = 10;
  int _score = 0;
  bool _isWaiting = false;
  int? _selectedIndex;
  int _oddIndex = 0;
  List<_ItemData> _items = [];
  Timer? _hintTimer;
  bool _showHint = false;
  String _currentItemName = '';

  // Categories of items with similar items grouped together
  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'fruits',
      'items': [
        {'emoji': '🍎', 'name': 'apple'},
        {'emoji': '🍊', 'name': 'orange'},
        {'emoji': '🍋', 'name': 'lemon'},
        {'emoji': '🍇', 'name': 'grapes'},
        {'emoji': '🍓', 'name': 'strawberry'},
        {'emoji': '🍌', 'name': 'banana'},
        {'emoji': '🍑', 'name': 'peach'},
        {'emoji': '🍒', 'name': 'cherries'},
      ],
    },
    {
      'name': 'animals',
      'items': [
        {'emoji': '🐶', 'name': 'dog'},
        {'emoji': '🐱', 'name': 'cat'},
        {'emoji': '🐰', 'name': 'rabbit'},
        {'emoji': '🐻', 'name': 'bear'},
        {'emoji': '🦁', 'name': 'lion'},
        {'emoji': '🐯', 'name': 'tiger'},
        {'emoji': '🐮', 'name': 'cow'},
        {'emoji': '🐷', 'name': 'pig'},
      ],
    },
    {
      'name': 'vehicles',
      'items': [
        {'emoji': '🚗', 'name': 'car'},
        {'emoji': '🚕', 'name': 'taxi'},
        {'emoji': '🚌', 'name': 'bus'},
        {'emoji': '🚎', 'name': 'trolleybus'},
        {'emoji': '🚓', 'name': 'police car'},
        {'emoji': '🚑', 'name': 'ambulance'},
        {'emoji': '🚒', 'name': 'fire truck'},
        {'emoji': '🏎️', 'name': 'race car'},
      ],
    },
    {
      'name': 'food',
      'items': [
        {'emoji': '🍕', 'name': 'pizza'},
        {'emoji': '🍔', 'name': 'burger'},
        {'emoji': '🌭', 'name': 'hot dog'},
        {'emoji': '🍟', 'name': 'fries'},
        {'emoji': '🌮', 'name': 'taco'},
        {'emoji': '🥪', 'name': 'sandwich'},
        {'emoji': '🥗', 'name': 'salad'},
        {'emoji': '🍝', 'name': 'pasta'},
      ],
    },
    {
      'name': 'sports balls',
      'items': [
        {'emoji': '⚽', 'name': 'soccer ball'},
        {'emoji': '🏀', 'name': 'basketball'},
        {'emoji': '🏈', 'name': 'football'},
        {'emoji': '⚾', 'name': 'baseball'},
        {'emoji': '🎾', 'name': 'tennis ball'},
        {'emoji': '🏐', 'name': 'volleyball'},
        {'emoji': '🏉', 'name': 'rugby ball'},
        {'emoji': '🎱', 'name': 'pool ball'},
      ],
    },
    {
      'name': 'flowers',
      'items': [
        {'emoji': '🌸', 'name': 'cherry blossom'},
        {'emoji': '🌹', 'name': 'rose'},
        {'emoji': '🌻', 'name': 'sunflower'},
        {'emoji': '🌷', 'name': 'tulip'},
        {'emoji': '🌺', 'name': 'hibiscus'},
        {'emoji': '🌼', 'name': 'daisy'},
        {'emoji': '💐', 'name': 'bouquet'},
        {'emoji': '🪻', 'name': 'hyacinth'},
      ],
    },
    {
      'name': 'sea animals',
      'items': [
        {'emoji': '🐟', 'name': 'fish'},
        {'emoji': '🐠', 'name': 'tropical fish'},
        {'emoji': '🐡', 'name': 'puffer fish'},
        {'emoji': '🦈', 'name': 'shark'},
        {'emoji': '🐙', 'name': 'octopus'},
        {'emoji': '🦀', 'name': 'crab'},
        {'emoji': '🦐', 'name': 'shrimp'},
        {'emoji': '🐳', 'name': 'whale'},
      ],
    },
    {
      'name': 'insects',
      'items': [
        {'emoji': '🦋', 'name': 'butterfly'},
        {'emoji': '🐛', 'name': 'caterpillar'},
        {'emoji': '🐜', 'name': 'ant'},
        {'emoji': '🐝', 'name': 'bee'},
        {'emoji': '🐞', 'name': 'ladybug'},
        {'emoji': '🦗', 'name': 'cricket'},
        {'emoji': '🪲', 'name': 'beetle'},
        {'emoji': '🦟', 'name': 'mosquito'},
      ],
    },
    {
      'name': 'weather',
      'items': [
        {'emoji': '☀️', 'name': 'sun'},
        {'emoji': '🌤️', 'name': 'partly cloudy'},
        {'emoji': '⛅', 'name': 'cloudy'},
        {'emoji': '🌧️', 'name': 'rain'},
        {'emoji': '⛈️', 'name': 'storm'},
        {'emoji': '🌩️', 'name': 'lightning'},
        {'emoji': '❄️', 'name': 'snow'},
        {'emoji': '🌈', 'name': 'rainbow'},
      ],
    },
    {
      'name': 'clothes',
      'items': [
        {'emoji': '👕', 'name': 't-shirt'},
        {'emoji': '👖', 'name': 'jeans'},
        {'emoji': '👗', 'name': 'dress'},
        {'emoji': '👔', 'name': 'shirt'},
        {'emoji': '🧥', 'name': 'coat'},
        {'emoji': '👚', 'name': 'blouse'},
        {'emoji': '🧣', 'name': 'scarf'},
        {'emoji': '🧢', 'name': 'cap'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    AudioHelper.init();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _selectDifficulty(OddOneOutDifficulty difficulty) {
    HapticHelper.lightTap();
    setState(() {
      _difficulty = difficulty;
    });
    _startNewRound();
  }

  void _startNewRound() {
    if (_round >= _totalRounds) {
      _showGameComplete();
      return;
    }

    _hintTimer?.cancel();

    if (_difficulty == OddOneOutDifficulty.easy) {
      _setupEasyRound();
    } else {
      _setupHardRound();
    }

    setState(() {
      _round++;
      _isWaiting = false;
      _selectedIndex = null;
      _showHint = false;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_difficulty == OddOneOutDifficulty.easy) {
        AudioHelper.speak("Find the one that is different!");
      } else {
        AudioHelper.speak("Which one doesn't belong?");
      }
      _startHintTimer();
    });
  }

  void _setupEasyRound() {
    // Easy mode: 3 identical items + 1 different
    final shuffledCategories = List<Map<String, dynamic>>.from(_categories)..shuffle(_random);
    final mainCategory = shuffledCategories[0];
    final oddCategory = shuffledCategories[1];

    final mainItems = List<Map<String, dynamic>>.from(mainCategory['items'])..shuffle(_random);
    final oddItems = List<Map<String, dynamic>>.from(oddCategory['items'])..shuffle(_random);

    final mainItem = mainItems[0];
    final oddItem = oddItems[0];

    _currentItemName = oddItem['name'];

    // Create 3 identical items + 1 different
    _items = [
      _ItemData(emoji: mainItem['emoji'], name: mainItem['name'], isOdd: false),
      _ItemData(emoji: mainItem['emoji'], name: mainItem['name'], isOdd: false),
      _ItemData(emoji: mainItem['emoji'], name: mainItem['name'], isOdd: false),
      _ItemData(emoji: oddItem['emoji'], name: oddItem['name'], isOdd: true),
    ];

    // Shuffle and find the odd index
    _items.shuffle(_random);
    _oddIndex = _items.indexWhere((item) => item.isOdd);
  }

  void _setupHardRound() {
    // Hard mode: 3 items from same category (different) + 1 from different category
    final shuffledCategories = List<Map<String, dynamic>>.from(_categories)..shuffle(_random);
    final mainCategory = shuffledCategories[0];
    final oddCategory = shuffledCategories[1];

    final mainItems = List<Map<String, dynamic>>.from(mainCategory['items'])..shuffle(_random);
    final oddItems = List<Map<String, dynamic>>.from(oddCategory['items'])..shuffle(_random);

    _currentItemName = oddItems[0]['name'];

    // Create 3 different items from same category + 1 from different
    _items = [
      _ItemData(emoji: mainItems[0]['emoji'], name: mainItems[0]['name'], isOdd: false),
      _ItemData(emoji: mainItems[1]['emoji'], name: mainItems[1]['name'], isOdd: false),
      _ItemData(emoji: mainItems[2]['emoji'], name: mainItems[2]['name'], isOdd: false),
      _ItemData(emoji: oddItems[0]['emoji'], name: oddItems[0]['name'], isOdd: true),
    ];

    // Shuffle and find the odd index
    _items.shuffle(_random);
    _oddIndex = _items.indexWhere((item) => item.isOdd);
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_isWaiting) {
        setState(() => _showHint = true);
        AudioHelper.speak("Here's a hint! The $_currentItemName is different!");
      }
    });
  }

  void _onItemTap(int index) {
    if (_isWaiting) return;
    if (_selectedIndex != null) return;

    HapticHelper.lightTap();
    _hintTimer?.cancel();

    setState(() {
      _selectedIndex = index;
    });

    if (index == _oddIndex) {
      // Correct!
      HapticHelper.success();
      _confettiController.play();
      AudioHelper.speakSuccess();
      setState(() {
        _score++;
        _isWaiting = true;
      });
      Future.delayed(const Duration(milliseconds: 1500), _startNewRound);
    } else {
      // Wrong - let user try again
      HapticHelper.error();
      AudioHelper.speakTryAgain();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _selectedIndex = null; // Clear selection so user can try again
          });
          _startHintTimer(); // Restart hint timer
        }
      });
    }
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
          setState(() {
            _score = 0;
            _round = 0;
          });
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
    if (_difficulty == null) {
      return _buildDifficultySelector();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 24),
                // Instructions
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 32),
                      const SizedBox(width: 16),
                      Text(
                        _difficulty == OddOneOutDifficulty.easy
                            ? 'Find the different one!'
                            : 'Tap the one that doesn\'t belong!',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Items grid
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: LayoutBuilder(
                        key: ValueKey('round_$_round'),
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth;
                          final availableHeight = constraints.maxHeight;
                          // Calculate item size based on available space (2x2 grid)
                          final itemSize = min(
                            (availableWidth - 24) / 2,
                            (availableHeight - 24) / 2,
                          ).clamp(100.0, 200.0);

                          return Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: List.generate(_items.length, (index) {
                              // Staggered entrance delay based on position
                              final delay = Duration(milliseconds: 100 * index);

                              return _ItemCard(
                                item: _items[index],
                                size: itemSize,
                                isSelected: _selectedIndex == index,
                                isCorrect: _selectedIndex == index && index == _oddIndex,
                                isWrong: _selectedIndex == index && index != _oddIndex,
                                isHinted: _showHint && index == _oddIndex,
                                onTap: () => _onItemTap(index),
                              )
                                  .animate(delay: delay)
                                  .fadeIn(duration: 300.ms)
                                  .scale(
                                    begin: const Offset(0.5, 0.5),
                                    end: const Offset(1, 1),
                                    duration: 400.ms,
                                    curve: Curves.elasticOut,
                                  );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          CelebrationOverlay(controller: _confettiController),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accent2,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const GameBackButton(),
                  const SizedBox(width: 24),
                  Text(
                    'Odd One Out',
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🔍',
                        style: TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Choose Difficulty',
                        style: GoogleFonts.nunito(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _DifficultyButton(
                        title: 'Easy',
                        subtitle: '3 same items + 1 different',
                        emoji: '🌟',
                        color: AppColors.success,
                        shadeColor: AppColors.successShade,
                        onTap: () => _selectDifficulty(OddOneOutDifficulty.easy),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
                      const SizedBox(height: 20),
                      _DifficultyButton(
                        title: 'Hard',
                        subtitle: 'Find what doesn\'t belong',
                        emoji: '🧠',
                        color: AppColors.error,
                        shadeColor: AppColors.errorShade,
                        onTap: () => _selectDifficulty(OddOneOutDifficulty.hard),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.accent2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          Text(
            'Odd One Out',
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _difficulty == OddOneOutDifficulty.easy
                  ? AppColors.success
                  : AppColors.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _difficulty?.name ?? '',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          // Round counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Round $_round/$_totalRounds',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  '$_score',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Difficulty selection button
class _DifficultyButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final Color shadeColor;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.shadeColor,
    required this.onTap,
  });

  @override
  State<_DifficultyButton> createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<_DifficultyButton> {
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
        width: 320,
        height: 90,
        child: Stack(
          children: [
            // Shadow
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 84,
                decoration: BoxDecoration(
                  color: widget.shadeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Face
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: 0,
              right: 0,
              top: _isPressed ? 6 : 0,
              child: Container(
                height: 84,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.nunito(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
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
}

/// Data class for items
class _ItemData {
  final String emoji;
  final String name;
  final bool isOdd;

  _ItemData({required this.emoji, required this.name, required this.isOdd});
}

/// Item card widget with 3D effect
class _ItemCard extends StatefulWidget {
  final _ItemData item;
  final double size;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isHinted;
  final VoidCallback onTap;

  const _ItemCard({
    required this.item,
    required this.size,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.isHinted,
    required this.onTap,
  });

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _idleController;
  late Animation<double> _floatAnimation;

  Color get _baseColor {
    if (widget.isCorrect) return AppColors.success;
    if (widget.isWrong) return AppColors.error;
    if (widget.isHinted) return AppColors.attention;
    return AppColors.primary;
  }

  Color get _shadeColor {
    if (widget.isCorrect) return AppColors.successShade;
    if (widget.isWrong) return AppColors.errorShade;
    if (widget.isHinted) return AppColors.attentionShade;
    return AppColors.primaryShade;
  }

  @override
  void initState() {
    super.initState();
    // Gentle idle floating animation
    _idleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
    _idleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _idleController,
        builder: (context, child) {
          // Only apply idle animation when not selected
          final offset =
              widget.isSelected ? 0.0 : _floatAnimation.value;
          return Transform.translate(
            offset: Offset(0, offset),
            child: child,
          );
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              // Shadow
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: _shadeColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              // Face
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                left: 0,
                right: 0,
                top: _isPressed ? 6 : 0,
                bottom: _isPressed ? 0 : 6,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _baseColor,
                    borderRadius: BorderRadius.circular(24),
                    border: widget.isHinted
                        ? Border.all(color: Colors.white, width: 4)
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.item.emoji,
                          style: TextStyle(fontSize: widget.size * 0.4),
                        ),
                        if (widget.isCorrect || widget.isWrong)
                          Icon(
                            widget.isCorrect ? Icons.check_circle : Icons.cancel,
                            color: Colors.white,
                            size: 32,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Apply state-specific animations
    if (widget.isCorrect) {
      card = card
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.15, 1.15),
            duration: 200.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.15, 1.15),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.elasticOut,
          )
          .shimmer(
            duration: 800.ms,
            color: Colors.white.withValues(alpha: 0.4),
          );
    } else if (widget.isWrong) {
      card = card
          .animate()
          .shake(hz: 5, rotation: 0.05, duration: 400.ms)
          .tint(color: Colors.red.withValues(alpha: 0.2), duration: 200.ms);
    } else if (widget.isHinted) {
      card = card
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 600.ms,
            curve: Curves.easeInOut,
          )
          .boxShadow(
            begin: BoxShadow(
              color: AppColors.attention.withValues(alpha: 0),
              blurRadius: 0,
              spreadRadius: 0,
            ),
            end: BoxShadow(
              color: AppColors.attention.withValues(alpha: 0.7),
              blurRadius: 25,
              spreadRadius: 8,
            ),
            duration: 600.ms,
          );
    }

    return card;
  }
}
