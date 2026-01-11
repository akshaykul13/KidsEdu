import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/game_icon.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Difficulty levels for Spot the Difference
enum SpotDifficulty {
  easy(
    name: 'Easy',
    description: '4 items, find 1 difference',
    itemCount: 4,
    differenceCount: 1,
  ),
  medium(
    name: 'Medium',
    description: '6 items, find 2 differences',
    itemCount: 6,
    differenceCount: 2,
  ),
  hard(
    name: 'Hard',
    description: '8 items, find 3 differences',
    itemCount: 8,
    differenceCount: 3,
  );

  final String name;
  final String description;
  final int itemCount;
  final int differenceCount;

  const SpotDifficulty({
    required this.name,
    required this.description,
    required this.itemCount,
    required this.differenceCount,
  });
}

/// Spot the Difference Game - Find differences between two pictures
class SpotTheDifferenceGame extends StatefulWidget {
  const SpotTheDifferenceGame({super.key});

  @override
  State<SpotTheDifferenceGame> createState() => _SpotTheDifferenceGameState();
}

class _SpotTheDifferenceGameState extends State<SpotTheDifferenceGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  SpotDifficulty? _difficulty;
  int _round = 0;
  final int _totalRounds = 5;
  int _score = 0;
  bool _isWaiting = false;
  Set<int> _foundDifferences = {};
  List<_SceneItem> _originalItems = [];
  List<_SceneItem> _modifiedItems = [];
  List<int> _differenceIndices = [];
  Timer? _hintTimer;
  int? _hintIndex;
  int _sceneKey = 0; // For triggering entrance animations

  int get _differencesToFind => _difficulty?.differenceCount ?? 2;
  int get _itemCount => _difficulty?.itemCount ?? 6;

  // Scene themes using our GameIcon icons
  static const List<Map<String, dynamic>> _sceneThemes = [
    {
      'name': 'Forest',
      'background': Color(0xFF87CEEB),
      'groundColor': Color(0xFF7CFC00),
      'items': [
        {'iconId': 'bear', 'name': 'bear'},
        {'iconId': 'fox', 'name': 'fox'},
        {'iconId': 'owl', 'name': 'owl'},
        {'iconId': 'rabbit', 'name': 'rabbit'},
        {'iconId': 'bird', 'name': 'bird'},
        {'iconId': 'butterfly', 'name': 'butterfly'},
        {'iconId': 'flower', 'name': 'flower'},
        {'iconId': 'sun', 'name': 'sun'},
        {'iconId': 'cloud', 'name': 'cloud'},
        {'iconId': 'turtle', 'name': 'turtle'},
      ],
    },
    {
      'name': 'Safari',
      'background': Color(0xFFFDB813),
      'groundColor': Color(0xFFD2691E),
      'items': [
        {'iconId': 'lion', 'name': 'lion'},
        {'iconId': 'elephant', 'name': 'elephant'},
        {'iconId': 'monkey', 'name': 'monkey'},
        {'iconId': 'bird', 'name': 'bird'},
        {'iconId': 'sun', 'name': 'sun'},
        {'iconId': 'butterfly', 'name': 'butterfly'},
        {'iconId': 'flower', 'name': 'flower'},
        {'iconId': 'turtle', 'name': 'turtle'},
        {'iconId': 'cloud', 'name': 'cloud'},
        {'iconId': 'star', 'name': 'star'},
      ],
    },
    {
      'name': 'Pet Park',
      'background': Color(0xFF98FB98),
      'groundColor': Color(0xFF8B4513),
      'items': [
        {'iconId': 'dog', 'name': 'dog'},
        {'iconId': 'cat', 'name': 'cat'},
        {'iconId': 'rabbit', 'name': 'rabbit'},
        {'iconId': 'bird', 'name': 'bird'},
        {'iconId': 'fish', 'name': 'fish'},
        {'iconId': 'butterfly', 'name': 'butterfly'},
        {'iconId': 'flower', 'name': 'flower'},
        {'iconId': 'sun', 'name': 'sun'},
        {'iconId': 'heart', 'name': 'heart'},
        {'iconId': 'star', 'name': 'star'},
      ],
    },
    {
      'name': 'Ocean',
      'background': Color(0xFF006994),
      'groundColor': Color(0xFF2E8B57),
      'items': [
        {'iconId': 'fish', 'name': 'fish'},
        {'iconId': 'penguin', 'name': 'penguin'},
        {'iconId': 'turtle', 'name': 'turtle'},
        {'iconId': 'star', 'name': 'starfish'},
        {'iconId': 'moon', 'name': 'moon'},
        {'iconId': 'cloud', 'name': 'cloud'},
        {'iconId': 'bird', 'name': 'seagull'},
        {'iconId': 'sun', 'name': 'sun'},
        {'iconId': 'heart', 'name': 'heart'},
        {'iconId': 'flower', 'name': 'coral'},
      ],
    },
    {
      'name': 'Night Sky',
      'background': Color(0xFF191970),
      'groundColor': Color(0xFF2F4F4F),
      'items': [
        {'iconId': 'moon', 'name': 'moon'},
        {'iconId': 'star', 'name': 'star'},
        {'iconId': 'owl', 'name': 'owl'},
        {'iconId': 'cloud', 'name': 'cloud'},
        {'iconId': 'butterfly', 'name': 'moth'},
        {'iconId': 'cat', 'name': 'cat'},
        {'iconId': 'fox', 'name': 'fox'},
        {'iconId': 'heart', 'name': 'heart'},
        {'iconId': 'flower', 'name': 'night flower'},
        {'iconId': 'bird', 'name': 'nightingale'},
      ],
    },
  ];

  // Alternative items for modifications (different from theme items)
  static const List<Map<String, String>> _alternativeItems = [
    {'iconId': 'heart', 'name': 'heart'},
    {'iconId': 'star', 'name': 'star'},
    {'iconId': 'sun', 'name': 'sun'},
    {'iconId': 'moon', 'name': 'moon'},
    {'iconId': 'cloud', 'name': 'cloud'},
    {'iconId': 'flower', 'name': 'flower'},
    {'iconId': 'butterfly', 'name': 'butterfly'},
    {'iconId': 'bird', 'name': 'bird'},
    {'iconId': 'fish', 'name': 'fish'},
    {'iconId': 'turtle', 'name': 'turtle'},
  ];

  Map<String, dynamic>? _currentTheme;

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

  void _selectDifficulty(SpotDifficulty difficulty) {
    HapticHelper.lightTap();
    setState(() {
      _difficulty = difficulty;
    });
    _startNewRound();
  }

  List<Offset> _getPositionsForItemCount(int count) {
    switch (count) {
      case 4:
        // 2x2 grid, big icons
        return const [
          Offset(0.28, 0.28),
          Offset(0.72, 0.28),
          Offset(0.28, 0.72),
          Offset(0.72, 0.72),
        ];
      case 6:
        // 2x3 grid
        return const [
          Offset(0.20, 0.25),
          Offset(0.50, 0.20),
          Offset(0.80, 0.25),
          Offset(0.20, 0.70),
          Offset(0.50, 0.75),
          Offset(0.80, 0.70),
        ];
      case 8:
      default:
        // 2x4 grid
        return const [
          Offset(0.14, 0.22),
          Offset(0.38, 0.18),
          Offset(0.62, 0.22),
          Offset(0.86, 0.18),
          Offset(0.14, 0.70),
          Offset(0.38, 0.74),
          Offset(0.62, 0.70),
          Offset(0.86, 0.74),
        ];
    }
  }

  void _startNewRound() {
    if (_round >= _totalRounds) {
      _showGameComplete();
      return;
    }

    _hintTimer?.cancel();

    // Pick a random theme
    _currentTheme = _sceneThemes[_random.nextInt(_sceneThemes.length)];
    final themeItems = List<Map<String, dynamic>>.from(_currentTheme!['items']);
    themeItems.shuffle(_random);

    // Create a scene with items based on difficulty
    _originalItems = [];
    _modifiedItems = [];
    _differenceIndices = [];

    // Get positions based on item count
    final positions = _getPositionsForItemCount(_itemCount);

    // Create original scene
    for (int i = 0; i < _itemCount && i < themeItems.length; i++) {
      _originalItems.add(_SceneItem(
        iconId: themeItems[i]['iconId'],
        name: themeItems[i]['name'],
        position: positions[i],
      ));
    }

    // Create modified scene (copy original first)
    _modifiedItems = _originalItems.map((item) => _SceneItem(
      iconId: item.iconId,
      name: item.name,
      position: item.position,
    )).toList();

    // Pick 3 random positions to change
    final changePositions = List.generate(_originalItems.length, (i) => i)..shuffle(_random);
    _differenceIndices = changePositions.take(_differencesToFind).toList();

    // Modify those items in the second picture with different icons
    final altItems = List<Map<String, String>>.from(_alternativeItems)
      ..removeWhere((alt) => themeItems.any((t) => t['iconId'] == alt['iconId']))
      ..shuffle(_random);

    for (int i = 0; i < _differenceIndices.length; i++) {
      final idx = _differenceIndices[i];
      _modifiedItems[idx] = _SceneItem(
        iconId: altItems[i % altItems.length]['iconId']!,
        name: altItems[i % altItems.length]['name']!,
        position: _modifiedItems[idx].position,
      );
    }

    setState(() {
      _round++;
      _isWaiting = false;
      _foundDifferences = {};
      _hintIndex = null;
      _sceneKey++; // Trigger new entrance animations
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      AudioHelper.speak("Find $_differencesToFind differences between the pictures!");
      _startHintTimer();
    });
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && !_isWaiting && _foundDifferences.length < _differencesToFind) {
        // Find an unfound difference
        for (final idx in _differenceIndices) {
          if (!_foundDifferences.contains(idx)) {
            setState(() => _hintIndex = idx);
            AudioHelper.speak("Here's a hint!");
            break;
          }
        }
      }
    });
  }

  void _onItemTap(int index, bool isModifiedPicture) {
    if (_isWaiting) return;
    if (_foundDifferences.contains(index)) return;

    // Only the modified picture has differences to find
    if (!isModifiedPicture) {
      // Tapped on original picture - show feedback but no points
      HapticHelper.lightTap();
      return;
    }

    // Check if this is a difference
    if (_differenceIndices.contains(index)) {
      // Found a difference!
      HapticHelper.success();
      setState(() {
        _foundDifferences.add(index);
        _hintIndex = null;
      });

      if (_foundDifferences.length >= _differencesToFind) {
        // All differences found!
        _hintTimer?.cancel();
        _score++;
        _confettiController.play();
        AudioHelper.speakSuccess();
        setState(() => _isWaiting = true);
        Future.delayed(const Duration(milliseconds: 1500), _startNewRound);
      } else {
        final remaining = _differencesToFind - _foundDifferences.length;
        AudioHelper.speak("Found one! $remaining more to find!");
        _startHintTimer();
      }
    } else {
      // Not a difference
      HapticHelper.error();
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
                const SizedBox(height: 16),
                // Instructions
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Find $_differencesToFind differences!',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_foundDifferences.length}/$_differencesToFind',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Two pictures side by side
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // Original picture
                        Expanded(
                          child: _buildPicture(
                            items: _originalItems,
                            isModified: false,
                            label: 'Picture 1',
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Modified picture
                        Expanded(
                          child: _buildPicture(
                            items: _modifiedItems,
                            isModified: true,
                            label: 'Picture 2',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          CelebrationOverlay(controller: _confettiController),
        ],
      ),
    );
  }

  Widget _buildPicture({
    required List<_SceneItem> items,
    required bool isModified,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _currentTheme?['background'] ?? AppColors.primary,
                  HSLColor.fromColor(_currentTheme?['background'] ?? AppColors.primary)
                      .withLightness(0.6)
                      .toColor(),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryShade,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                key: ValueKey('scene_${_sceneKey}_$isModified'),
                children: [
                  // Ground with gradient
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (_currentTheme?['groundColor'] ?? AppColors.success)
                                .withValues(alpha: 0.7),
                            _currentTheme?['groundColor'] ?? AppColors.success,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  // Items
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isFound = _foundDifferences.contains(index);
                    final isHinted = _hintIndex == index && isModified;
                    final isDifference = _differenceIndices.contains(index);

                    return Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Icon size varies by difficulty - fewer items = bigger icons
                          final sizeMultiplier = _difficulty == SpotDifficulty.easy
                              ? 0.32
                              : _difficulty == SpotDifficulty.medium
                                  ? 0.25
                                  : 0.18;
                          final iconSize = min(constraints.maxWidth, constraints.maxHeight) * sizeMultiplier;
                          final clampedSize = _difficulty == SpotDifficulty.easy
                              ? iconSize.clamp(60.0, 120.0)
                              : _difficulty == SpotDifficulty.medium
                                  ? iconSize.clamp(50.0, 100.0)
                                  : iconSize.clamp(40.0, 80.0);

                          Widget iconWidget = _SceneIconWidget(
                            item: item,
                            size: clampedSize,
                            isFound: isFound && isDifference && isModified,
                            isHinted: isHinted,
                            onTap: () => _onItemTap(index, isModified),
                          );

                          // Staggered entrance animation
                          final delay = Duration(milliseconds: 80 * index);
                          iconWidget = iconWidget
                              .animate(delay: delay)
                              .fadeIn(duration: 300.ms)
                              .scale(
                                begin: const Offset(0.3, 0.3),
                                end: const Offset(1, 1),
                                duration: 400.ms,
                                curve: Curves.elasticOut,
                              );

                          return Stack(
                            children: [
                              Positioned(
                                left: item.position.dx * constraints.maxWidth - (clampedSize + 24) / 2,
                                top: item.position.dy * constraints.maxHeight - (clampedSize + 24) / 2,
                                child: iconWidget,
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
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
                    'Spot the Difference',
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
                        subtitle: '4 items, find 1 difference',
                        emoji: '🌟',
                        color: AppColors.success,
                        shadeColor: AppColors.successShade,
                        onTap: () => _selectDifficulty(SpotDifficulty.easy),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
                      const SizedBox(height: 16),
                      _DifficultyButton(
                        title: 'Medium',
                        subtitle: '6 items, find 2 differences',
                        emoji: '🧩',
                        color: AppColors.attention,
                        shadeColor: AppColors.attentionShade,
                        onTap: () => _selectDifficulty(SpotDifficulty.medium),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
                      const SizedBox(height: 16),
                      _DifficultyButton(
                        title: 'Hard',
                        subtitle: '8 items, find 3 differences',
                        emoji: '🧠',
                        color: AppColors.error,
                        shadeColor: AppColors.errorShade,
                        onTap: () => _selectDifficulty(SpotDifficulty.hard),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
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
            'Spot the Difference',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _difficulty == SpotDifficulty.easy
                  ? AppColors.success
                  : _difficulty == SpotDifficulty.medium
                      ? AppColors.attention
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
          // Theme name
          if (_currentTheme != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _currentTheme!['name'],
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(width: 16),
          // Round counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Round $_round/$_totalRounds',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  '$_score',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
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

/// Data class for scene items
class _SceneItem {
  final String iconId;
  final String name;
  final Offset position;

  _SceneItem({
    required this.iconId,
    required this.name,
    required this.position,
  });
}

/// Scene icon widget with animations
class _SceneIconWidget extends StatefulWidget {
  final _SceneItem item;
  final double size;
  final bool isFound;
  final bool isHinted;
  final VoidCallback onTap;

  const _SceneIconWidget({
    required this.item,
    required this.size,
    required this.isFound,
    required this.isHinted,
    required this.onTap,
  });

  @override
  State<_SceneIconWidget> createState() => _SceneIconWidgetState();
}

class _SceneIconWidgetState extends State<_SceneIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleController;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    // Gentle idle floating animation with slight rotation
    _idleController = AnimationController(
      duration: Duration(milliseconds: 2000 + Random().nextInt(800)),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
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
    final cardSize = widget.size + 24;

    Widget iconContent = AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        // Pause idle animation when found
        final offset = widget.isFound ? 0.0 : _floatAnimation.value;
        final rotation = widget.isFound ? 0.0 : _rotateAnimation.value;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Transform.rotate(
            angle: rotation,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: cardSize,
          height: cardSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isFound
                  ? AppColors.success
                  : AppColors.primary.withValues(alpha: 0.3),
              width: widget.isFound ? 5 : 3,
            ),
            boxShadow: [
              // Main shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
              // Colored glow
              if (widget.isFound)
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                  ),
                ),
              ),
              // Icon
              Center(
                child: GameIcon(
                  iconId: widget.item.iconId,
                  size: widget.size,
                ),
              ),
              // Check mark for found items
              if (widget.isFound)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Apply found celebration animation
    if (widget.isFound) {
      iconContent = iconContent
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.15, 1.15),
            duration: 200.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.15, 1.15),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.elasticOut,
          )
          .shimmer(
            duration: 1200.ms,
            color: Colors.white.withValues(alpha: 0.6),
          );
    }

    // Apply hint pulsing animation
    if (widget.isHinted) {
      iconContent = iconContent
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
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
              color: AppColors.attention.withValues(alpha: 0.9),
              blurRadius: 25,
              spreadRadius: 8,
            ),
            duration: 600.ms,
          );
    }

    return iconContent;
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
