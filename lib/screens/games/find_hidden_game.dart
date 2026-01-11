import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/settings_service.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Find Hidden Game - Find hidden objects
class FindHiddenGame extends StatefulWidget {
  const FindHiddenGame({super.key});

  @override
  State<FindHiddenGame> createState() => _FindHiddenGameState();
}

class _FindHiddenGameState extends State<FindHiddenGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 5;
  int _score = 0;
  String _targetEmoji = '';
  List<Map<String, dynamic>> _items = [];
  Set<int> _foundIndices = {};
  int _targetCount = 0;
  Timer? _hintTimer;
  int? _hintIndex;

  final List<String> _searchEmojis = ['🌟', '🍎', '🎈', '🦋', '🌸'];
  final List<String> _fillerEmojis = ['🌳', '🌷', '🌻', '🍀', '🌺', '🌼', '🌹', '🌿', '🍃', '🌾'];

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

    setState(() {
      _round++;
      _foundIndices = {};
      _hintIndex = null;
    });

    // Pick target emoji
    _targetEmoji = _searchEmojis[_round - 1];
    _targetCount = 3 + _random.nextInt(3); // 3-5 items to find

    // Generate grid items
    _items = [];
    final totalItems = 24; // 6x4 grid

    // Add target items
    for (int i = 0; i < _targetCount; i++) {
      _items.add({'emoji': _targetEmoji, 'isTarget': true});
    }

    // Fill rest with filler
    while (_items.length < totalItems) {
      _items.add({'emoji': _fillerEmojis[_random.nextInt(_fillerEmojis.length)], 'isTarget': false});
    }

    _items.shuffle();
    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), () {
      AudioHelper.speak("Find all the ${_getEmojiName(_targetEmoji)}! There are $_targetCount hidden.");
      if (SettingsService.hintsEnabled) {
        _startHintTimer();
      }
    });
  }

  String _getEmojiName(String emoji) {
    switch (emoji) {
      case '🌟': return 'stars';
      case '🍎': return 'apples';
      case '🎈': return 'balloons';
      case '🦋': return 'butterflies';
      case '🌸': return 'flowers';
      default: return 'items';
    }
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _foundIndices.length < _targetCount) {
        // Find an unfound target and hint it
        for (int i = 0; i < _items.length; i++) {
          if (_items[i]['isTarget'] && !_foundIndices.contains(i)) {
            setState(() => _hintIndex = i);
            AudioHelper.speak("Here's a hint!");
            break;
          }
        }
      }
    });
  }

  void _onItemTap(int index) {
    if (_foundIndices.contains(index)) return;

    final item = _items[index];

    if (item['isTarget']) {
      HapticHelper.success();
      setState(() {
        _foundIndices.add(index);
        _hintIndex = null;
      });

      if (_foundIndices.length >= _targetCount) {
        // Round complete
        _hintTimer?.cancel();
        _score++;
        _confettiController.play();
        AudioHelper.speakSuccess();
        Future.delayed(const Duration(milliseconds: 1500), _startNewRound);
      } else {
        AudioHelper.speak("Found one! ${_targetCount - _foundIndices.length} more to go!");
        if (SettingsService.hintsEnabled) {
          _startHintTimer();
        }
      }
    } else {
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
          setState(() { _score = 0; _round = 0; });
          _startNewRound();
        },
        onHome: () { Navigator.pop(context); Navigator.pop(context); },
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

                // Target display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Find:', style: TextStyle(fontSize: 24, color: AppColors.textSecondary)),
                      const SizedBox(width: 16),
                      Text(_targetEmoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_foundIndices.length}/$_targetCount',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Game grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const columns = 6;
                        const rows = 4;
                        const spacing = 10.0;

                        final availableWidth = constraints.maxWidth;
                        final availableHeight = constraints.maxHeight;

                        final totalHorizontalSpacing = (columns - 1) * spacing;
                        final totalVerticalSpacing = (rows - 1) * spacing;

                        final cardWidth = (availableWidth - totalHorizontalSpacing) / columns;
                        final cardHeight = (availableHeight - totalVerticalSpacing) / rows;
                        final cardSize = cardWidth < cardHeight ? cardWidth : cardHeight;

                        return Center(
                          child: Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            alignment: WrapAlignment.center,
                            children: List.generate(_items.length, (index) {
                              final item = _items[index];
                              final isFound = _foundIndices.contains(index);
                              final isHinted = _hintIndex == index;

                              return GestureDetector(
                                onTap: () => _onItemTap(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: cardSize,
                                  height: cardSize,
                                  decoration: BoxDecoration(
                                    color: isFound ? AppColors.success.withValues(alpha: 0.3) : AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isFound ? AppColors.success : isHinted ? AppColors.warning : AppColors.disabled,
                                      width: isHinted ? 4 : 2,
                                    ),
                                    boxShadow: isHinted ? [BoxShadow(color: AppColors.warning.withValues(alpha: 0.5), blurRadius: 15)] : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      item['emoji'],
                                      style: TextStyle(fontSize: cardSize * 0.5, color: isFound ? Colors.grey : null),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          CelebrationOverlay(controller: _confettiController),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.accent2,
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          const Text('Find Hidden', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24)),
            child: Text('Round $_round/$_totalRounds', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: AppColors.accent1, borderRadius: BorderRadius.circular(24)),
            child: Row(children: [const Text('⭐', style: TextStyle(fontSize: 24)), const SizedBox(width: 8), Text('$_score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary))]),
          ),
        ],
      ),
    );
  }
}
