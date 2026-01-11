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
import '../../core/utils/game_icon.dart';

/// Difficulty levels for the memory game
enum MemoryDifficulty {
  easy(cardCount: 20, columns: 5, rows: 4, name: 'Easy'),
  medium(cardCount: 30, columns: 6, rows: 5, name: 'Medium'),
  hard(cardCount: 40, columns: 8, rows: 5, name: 'Hard');

  final int cardCount;
  final int columns;
  final int rows;
  final String name;

  const MemoryDifficulty({
    required this.cardCount,
    required this.columns,
    required this.rows,
    required this.name,
  });

  int get pairCount => cardCount ~/ 2;
}

/// Card data for the memory game
class MemoryCard {
  final int id;
  final String iconId;
  final Color color;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.iconId,
    required this.color,
    this.isFlipped = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({
    bool? isFlipped,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id,
      iconId: iconId,
      color: color,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

/// Memory Match Game - Find matching pairs of cards
class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  MemoryDifficulty? _difficulty;
  List<MemoryCard> _cards = [];
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  bool _isChecking = false;
  int _matchesFound = 0;
  int _moves = 0;
  Timer? _gameTimer;
  int _elapsedSeconds = 0;

  // Icons for cards - using illustrated icons
  static const List<Map<String, dynamic>> _cardData = [
    {'iconId': 'dog', 'color': Color(0xFF8D6E63)},
    {'iconId': 'cat', 'color': Color(0xFFFF9800)},
    {'iconId': 'rabbit', 'color': Color(0xFFE91E63)},
    {'iconId': 'fox', 'color': Color(0xFFFF5722)},
    {'iconId': 'bear', 'color': Color(0xFF795548)},
    {'iconId': 'penguin', 'color': Color(0xFF37474F)},
    {'iconId': 'lion', 'color': Color(0xFFFFC107)},
    {'iconId': 'owl', 'color': Color(0xFF9C27B0)},
    {'iconId': 'elephant', 'color': Color(0xFF78909C)},
    {'iconId': 'monkey', 'color': Color(0xFF8D6E63)},
    {'iconId': 'fish', 'color': Color(0xFF2196F3)},
    {'iconId': 'bird', 'color': Color(0xFF4CAF50)},
    {'iconId': 'turtle', 'color': Color(0xFF4CAF50)},
    {'iconId': 'butterfly', 'color': Color(0xFFE91E63)},
    {'iconId': 'star', 'color': Color(0xFFFFC107)},
    {'iconId': 'heart', 'color': Color(0xFFF44336)},
    {'iconId': 'flower', 'color': Color(0xFFE91E63)},
    {'iconId': 'sun', 'color': Color(0xFFFFC107)},
    {'iconId': 'moon', 'color': Color(0xFF3F51B5)},
    {'iconId': 'cloud', 'color': Color(0xFF90CAF9)},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    AudioHelper.init();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _selectDifficulty(MemoryDifficulty difficulty) {
    HapticHelper.lightTap();
    setState(() {
      _difficulty = difficulty;
    });
    _startGame();
  }

  void _startGame() {
    _gameTimer?.cancel();

    // Create pairs of cards
    final pairCount = _difficulty!.pairCount;
    List<MemoryCard> cards = [];

    // Shuffle card data and pick the needed number
    final shuffledData = List<Map<String, dynamic>>.from(_cardData)..shuffle(_random);

    for (int i = 0; i < pairCount; i++) {
      final data = shuffledData[i % shuffledData.length];
      // Create two cards with the same id (pair)
      cards.add(MemoryCard(
        id: i,
        iconId: data['iconId'],
        color: data['color'],
      ));
      cards.add(MemoryCard(
        id: i,
        iconId: data['iconId'],
        color: data['color'],
      ));
    }

    // Shuffle the cards
    cards.shuffle(_random);

    setState(() {
      _cards = cards;
      _firstFlippedIndex = null;
      _secondFlippedIndex = null;
      _isChecking = false;
      _matchesFound = 0;
      _moves = 0;
      _elapsedSeconds = 0;
    });

    // Start timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    AudioHelper.speak("Find the matching pairs!");
  }

  void _onCardTap(int index) {
    if (_isChecking) return;
    if (_cards[index].isFlipped) return;
    if (_cards[index].isMatched) return;

    HapticHelper.lightTap();

    setState(() {
      _cards[index] = _cards[index].copyWith(isFlipped: true);
    });

    if (_firstFlippedIndex == null) {
      // First card flipped
      setState(() {
        _firstFlippedIndex = index;
      });
    } else {
      // Second card flipped
      setState(() {
        _secondFlippedIndex = index;
        _moves++;
        _isChecking = true;
      });

      // Check for match
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    final firstCard = _cards[_firstFlippedIndex!];
    final secondCard = _cards[_secondFlippedIndex!];

    if (firstCard.id == secondCard.id) {
      // Match found!
      HapticHelper.success();
      AudioHelper.speakSuccess();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _cards[_firstFlippedIndex!] = _cards[_firstFlippedIndex!].copyWith(isMatched: true);
          _cards[_secondFlippedIndex!] = _cards[_secondFlippedIndex!].copyWith(isMatched: true);
          _matchesFound++;
          _firstFlippedIndex = null;
          _secondFlippedIndex = null;
          _isChecking = false;
        });

        // Check for game complete
        if (_matchesFound == _difficulty!.pairCount) {
          _onGameComplete();
        }
      });
    } else {
      // No match - flip back
      HapticHelper.error();

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _cards[_firstFlippedIndex!] = _cards[_firstFlippedIndex!].copyWith(isFlipped: false);
          _cards[_secondFlippedIndex!] = _cards[_secondFlippedIndex!].copyWith(isFlipped: false);
          _firstFlippedIndex = null;
          _secondFlippedIndex = null;
          _isChecking = false;
        });
      });
    }
  }

  void _onGameComplete() {
    _gameTimer?.cancel();
    _confettiController.play();
    HapticHelper.celebration();
    AudioHelper.speakGameComplete();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _GameCompleteDialog(
        moves: _moves,
        time: _formatTime(_elapsedSeconds),
        difficulty: _difficulty!.name,
        onPlayAgain: () {
          Navigator.pop(context);
          _startGame();
        },
        onChangeDifficulty: () {
          Navigator.pop(context);
          setState(() {
            _difficulty = null;
          });
        },
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
                const SizedBox(height: 16),
                _buildStats(),
                const SizedBox(height: 16),
                Expanded(child: _buildCardGrid()),
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
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryShade,
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
                    'Memory Match',
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
                        '🃏',
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
                        difficulty: MemoryDifficulty.easy,
                        subtitle: '20 cards (10 pairs)',
                        color: AppColors.success,
                        shadeColor: AppColors.successShade,
                        onTap: () => _selectDifficulty(MemoryDifficulty.easy),
                      ),
                      const SizedBox(height: 16),
                      _DifficultyButton(
                        difficulty: MemoryDifficulty.medium,
                        subtitle: '30 cards (15 pairs)',
                        color: AppColors.attention,
                        shadeColor: AppColors.attentionShade,
                        onTap: () => _selectDifficulty(MemoryDifficulty.medium),
                      ),
                      const SizedBox(height: 16),
                      _DifficultyButton(
                        difficulty: MemoryDifficulty.hard,
                        subtitle: '40 cards (20 pairs)',
                        color: AppColors.error,
                        shadeColor: AppColors.errorShade,
                        onTap: () => _selectDifficulty(MemoryDifficulty.hard),
                      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShade,
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
            'Memory Match',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _difficulty!.name,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatCard(
            icon: Icons.grid_view_rounded,
            label: 'Matches',
            value: '$_matchesFound / ${_difficulty!.pairCount}',
            color: AppColors.success,
          ),
          _StatCard(
            icon: Icons.touch_app_rounded,
            label: 'Moves',
            value: '$_moves',
            color: AppColors.attention,
          ),
          _StatCard(
            icon: Icons.timer_rounded,
            label: 'Time',
            value: _formatTime(_elapsedSeconds),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    final columns = _difficulty!.columns;
    final rows = _difficulty!.rows;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final availableHeight = constraints.maxHeight;

          // Calculate card size based on grid dimensions
          const spacing = 8.0;
          final totalHorizontalSpacing = (columns - 1) * spacing;
          final totalVerticalSpacing = (rows - 1) * spacing;

          final maxCardWidth = (availableWidth - totalHorizontalSpacing) / columns;
          final maxCardHeight = (availableHeight - totalVerticalSpacing) / rows;

          // Use the smaller dimension to ensure cards fit, with aspect ratio
          final cardWidth = maxCardWidth;
          final cardHeight = maxCardHeight;

          return Center(
            child: SizedBox(
              width: (cardWidth * columns) + totalHorizontalSpacing,
              height: (cardHeight * rows) + totalVerticalSpacing,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: cardWidth / cardHeight,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  // Staggered entrance animation
                  final delay = Duration(milliseconds: 30 * (index % columns) + 50 * (index ~/ columns));
                  return _MemoryCardWidget(
                    card: _cards[index],
                    onTap: () => _onCardTap(index),
                  )
                      .animate(delay: delay)
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Difficulty selection button
class _DifficultyButton extends StatefulWidget {
  final MemoryDifficulty difficulty;
  final String subtitle;
  final Color color;
  final Color shadeColor;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.difficulty,
    required this.subtitle,
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
        width: 300,
        height: 80,
        child: Stack(
          children: [
            // Shadow
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 74,
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
                height: 74,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.difficulty.name,
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
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
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Memory card widget with flip animation
class _MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;

  const _MemoryCardWidget({
    required this.card,
    required this.onTap,
  });

  @override
  State<_MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<_MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _flipController.addListener(() {
      if (_flipController.value >= 0.5 && !_showFront) {
        setState(() => _showFront = true);
      } else if (_flipController.value < 0.5 && _showFront) {
        setState(() => _showFront = false);
      }
    });
  }

  @override
  void didUpdateWidget(_MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped != oldWidget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ListenableBuilder(
        listenable: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * 3.14159;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: _showFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShade,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '?',
          style: GoogleFonts.nunito(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFront() {
    final isMatched = widget.card.isMatched;
    Widget content = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        decoration: BoxDecoration(
          color: isMatched ? AppColors.success : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMatched ? AppColors.success : widget.card.color,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isMatched
                  ? AppColors.successShade
                  : HSLColor.fromColor(widget.card.color)
                      .withLightness(
                        (HSLColor.fromColor(widget.card.color).lightness - 0.15)
                            .clamp(0.0, 1.0),
                      )
                      .toColor(),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = constraints.maxWidth * 0.75;
            return Center(
              child: GameIcon(
                iconId: widget.card.iconId,
                size: iconSize.clamp(35.0, 90.0),
              ),
            );
          },
        ),
      ),
    );

    // Add shimmer effect for matched cards
    if (isMatched) {
      content = content
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 2000.ms,
            color: Colors.white.withValues(alpha: 0.3),
          );
    }

    return content;
  }
}

/// Game complete dialog
class _GameCompleteDialog extends StatelessWidget {
  final int moves;
  final String time;
  final String difficulty;
  final VoidCallback onPlayAgain;
  final VoidCallback onChangeDifficulty;
  final VoidCallback onHome;

  const _GameCompleteDialog({
    required this.moves,
    required this.time,
    required this.difficulty,
    required this.onPlayAgain,
    required this.onChangeDifficulty,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Great Job!',
              style: GoogleFonts.nunito(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            _ResultRow(label: 'Difficulty', value: difficulty),
            _ResultRow(label: 'Moves', value: '$moves'),
            _ResultRow(label: 'Time', value: time),
            const SizedBox(height: 32),
            _DialogButton(
              text: 'Play Again',
              color: AppColors.success,
              shadeColor: AppColors.successShade,
              onTap: onPlayAgain,
            ),
            const SizedBox(height: 12),
            _DialogButton(
              text: 'Change Difficulty',
              color: AppColors.primary,
              shadeColor: AppColors.primaryShade,
              onTap: onChangeDifficulty,
            ),
            const SizedBox(height: 12),
            _DialogButton(
              text: 'Home',
              color: AppColors.neutral,
              shadeColor: AppColors.neutralShade,
              onTap: onHome,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  final String text;
  final Color color;
  final Color shadeColor;
  final VoidCallback onTap;

  const _DialogButton({
    required this.text,
    required this.color,
    required this.shadeColor,
    required this.onTap,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
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
        width: double.infinity,
        height: 56,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: widget.shadeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: 0,
              right: 0,
              top: _isPressed ? 4 : 0,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.text,
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
