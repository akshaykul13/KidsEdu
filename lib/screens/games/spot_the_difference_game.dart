import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Spot the Difference Game - Find differences between two pictures
class SpotTheDifferenceGame extends StatefulWidget {
  const SpotTheDifferenceGame({super.key});

  @override
  State<SpotTheDifferenceGame> createState() => _SpotTheDifferenceGameState();
}

class _SpotTheDifferenceGameState extends State<SpotTheDifferenceGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 5;
  int _score = 0;
  bool _isWaiting = false;
  Set<int> _foundDifferences = {};
  int _differencesToFind = 3;
  List<_SceneItem> _originalItems = [];
  List<_SceneItem> _modifiedItems = [];
  List<int> _differenceIndices = [];
  Timer? _hintTimer;
  int? _hintIndex;

  // Scene themes with items that can be placed
  static const List<Map<String, dynamic>> _sceneThemes = [
    {
      'name': 'Park',
      'background': Color(0xFF87CEEB),
      'groundColor': Color(0xFF7CFC00),
      'items': [
        {'emoji': '🌳', 'name': 'tree'},
        {'emoji': '🌸', 'name': 'flower'},
        {'emoji': '🦋', 'name': 'butterfly'},
        {'emoji': '🐦', 'name': 'bird'},
        {'emoji': '🌻', 'name': 'sunflower'},
        {'emoji': '🍄', 'name': 'mushroom'},
        {'emoji': '🐿️', 'name': 'squirrel'},
        {'emoji': '🌷', 'name': 'tulip'},
        {'emoji': '☀️', 'name': 'sun'},
        {'emoji': '☁️', 'name': 'cloud'},
      ],
    },
    {
      'name': 'Beach',
      'background': Color(0xFF00BFFF),
      'groundColor': Color(0xFFF4A460),
      'items': [
        {'emoji': '🏖️', 'name': 'beach umbrella'},
        {'emoji': '🐚', 'name': 'shell'},
        {'emoji': '🦀', 'name': 'crab'},
        {'emoji': '🐠', 'name': 'fish'},
        {'emoji': '🌴', 'name': 'palm tree'},
        {'emoji': '⛱️', 'name': 'parasol'},
        {'emoji': '🏄', 'name': 'surfer'},
        {'emoji': '🐬', 'name': 'dolphin'},
        {'emoji': '☀️', 'name': 'sun'},
        {'emoji': '🦩', 'name': 'flamingo'},
      ],
    },
    {
      'name': 'Farm',
      'background': Color(0xFF87CEEB),
      'groundColor': Color(0xFF8B4513),
      'items': [
        {'emoji': '🐄', 'name': 'cow'},
        {'emoji': '🐷', 'name': 'pig'},
        {'emoji': '🐔', 'name': 'chicken'},
        {'emoji': '🐴', 'name': 'horse'},
        {'emoji': '🐑', 'name': 'sheep'},
        {'emoji': '🌾', 'name': 'wheat'},
        {'emoji': '🚜', 'name': 'tractor'},
        {'emoji': '🏠', 'name': 'barn'},
        {'emoji': '🌻', 'name': 'sunflower'},
        {'emoji': '🐓', 'name': 'rooster'},
      ],
    },
    {
      'name': 'Space',
      'background': Color(0xFF191970),
      'groundColor': Color(0xFF2F4F4F),
      'items': [
        {'emoji': '🚀', 'name': 'rocket'},
        {'emoji': '🌙', 'name': 'moon'},
        {'emoji': '⭐', 'name': 'star'},
        {'emoji': '🪐', 'name': 'planet'},
        {'emoji': '👽', 'name': 'alien'},
        {'emoji': '🛸', 'name': 'UFO'},
        {'emoji': '🌍', 'name': 'Earth'},
        {'emoji': '☄️', 'name': 'comet'},
        {'emoji': '🌟', 'name': 'bright star'},
        {'emoji': '🛰️', 'name': 'satellite'},
      ],
    },
    {
      'name': 'Underwater',
      'background': Color(0xFF006994),
      'groundColor': Color(0xFF2E8B57),
      'items': [
        {'emoji': '🐙', 'name': 'octopus'},
        {'emoji': '🐠', 'name': 'fish'},
        {'emoji': '🦈', 'name': 'shark'},
        {'emoji': '🐢', 'name': 'turtle'},
        {'emoji': '🦑', 'name': 'squid'},
        {'emoji': '🐡', 'name': 'puffer fish'},
        {'emoji': '🦐', 'name': 'shrimp'},
        {'emoji': '🐚', 'name': 'shell'},
        {'emoji': '🪸', 'name': 'coral'},
        {'emoji': '🐳', 'name': 'whale'},
      ],
    },
  ];

  // Alternative items for modifications
  static const List<Map<String, String>> _alternativeItems = [
    {'emoji': '🌺', 'name': 'hibiscus'},
    {'emoji': '🦜', 'name': 'parrot'},
    {'emoji': '🐛', 'name': 'caterpillar'},
    {'emoji': '🎈', 'name': 'balloon'},
    {'emoji': '🍎', 'name': 'apple'},
    {'emoji': '🌈', 'name': 'rainbow'},
    {'emoji': '⚡', 'name': 'lightning'},
    {'emoji': '🎪', 'name': 'tent'},
    {'emoji': '🎁', 'name': 'gift'},
    {'emoji': '🏀', 'name': 'basketball'},
  ];

  Map<String, dynamic>? _currentTheme;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    AudioHelper.init();
    _startNewRound();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
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

    // Create a scene with 8 items in fixed positions
    _originalItems = [];
    _modifiedItems = [];
    _differenceIndices = [];

    // Define 8 positions in the scene (2 rows x 4 columns)
    final positions = [
      const Offset(0.12, 0.2),
      const Offset(0.37, 0.15),
      const Offset(0.62, 0.2),
      const Offset(0.87, 0.15),
      const Offset(0.12, 0.7),
      const Offset(0.37, 0.75),
      const Offset(0.62, 0.7),
      const Offset(0.87, 0.75),
    ];

    // Create original scene
    for (int i = 0; i < 8 && i < themeItems.length; i++) {
      _originalItems.add(_SceneItem(
        emoji: themeItems[i]['emoji'],
        name: themeItems[i]['name'],
        position: positions[i],
      ));
    }

    // Create modified scene (copy original first)
    _modifiedItems = _originalItems.map((item) => _SceneItem(
      emoji: item.emoji,
      name: item.name,
      position: item.position,
    )).toList();

    // Pick 3 random positions to change
    final changePositions = List.generate(_originalItems.length, (i) => i)..shuffle(_random);
    _differenceIndices = changePositions.take(_differencesToFind).toList();

    // Modify those items in the second picture
    final altItems = List<Map<String, String>>.from(_alternativeItems)..shuffle(_random);
    for (int i = 0; i < _differenceIndices.length; i++) {
      final idx = _differenceIndices[i];
      _modifiedItems[idx] = _SceneItem(
        emoji: altItems[i]['emoji']!,
        name: altItems[i]['name']!,
        position: _modifiedItems[idx].position,
      );
    }

    setState(() {
      _round++;
      _isWaiting = false;
      _foundDifferences = {};
      _hintIndex = null;
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
              color: _currentTheme?['background'] ?? AppColors.primary,
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
                children: [
                  // Ground
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _currentTheme?['groundColor'] ?? AppColors.success,
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
                          return Stack(
                            children: [
                              Positioned(
                                left: item.position.dx * constraints.maxWidth - 25,
                                top: item.position.dy * constraints.maxHeight - 25,
                                child: GestureDetector(
                                  onTap: () => _onItemTap(index, isModified),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isFound && isDifference && isModified
                                          ? AppColors.success.withValues(alpha: 0.3)
                                          : isHinted
                                              ? AppColors.attention.withValues(alpha: 0.3)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(25),
                                      border: isFound && isDifference && isModified
                                          ? Border.all(color: AppColors.success, width: 3)
                                          : isHinted
                                              ? Border.all(color: AppColors.attention, width: 3)
                                              : null,
                                      boxShadow: isHinted
                                          ? [
                                              BoxShadow(
                                                color: AppColors.attention.withValues(alpha: 0.5),
                                                blurRadius: 15,
                                                spreadRadius: 3,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.emoji,
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    ),
                                  ),
                                ),
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
  final String emoji;
  final String name;
  final Offset position;

  _SceneItem({
    required this.emoji,
    required this.name,
    required this.position,
  });
}
