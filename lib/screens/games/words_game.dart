import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/settings_service.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/answer_tile.dart';
import '../../widgets/celebration_overlay.dart';

/// Build Words Game - Spell simple words using letter tiles
class WordsGame extends StatefulWidget {
  const WordsGame({super.key});

  @override
  State<WordsGame> createState() => _WordsGameState();
}

class _WordsGameState extends State<WordsGame> {
  final Random _random = Random();
  late ConfettiController _confettiController;

  int _round = 0;
  final int _totalRounds = 10;
  int _score = 0;
  List<String> _targetWord = [];
  List<String> _availableLetters = [];
  List<String> _selectedLetters = [];
  bool _showHint = false;
  Timer? _hintTimer;

  final List<String> _words = [
    'CAT', 'DOG', 'SUN', 'HAT', 'BAT', 'RAT', 'PIG', 'COW', 'BEE', 'ANT',
    'CUP', 'BUS', 'BED', 'BOX', 'FAN', 'JAM', 'MAP', 'PEN', 'TEN', 'VAN',
  ];

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
      _showHint = false;
      _selectedLetters = [];
    });

    // Pick random word
    final word = _words[_random.nextInt(_words.length)];
    _targetWord = word.split('');

    // Create letter options: word letters + 3 random
    Set<String> letters = {..._targetWord};
    while (letters.length < _targetWord.length + 3) {
      letters.add(String.fromCharCode('A'.codeUnitAt(0) + _random.nextInt(26)));
    }
    _availableLetters = letters.toList()..shuffle();

    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), () {
      AudioHelper.speak("Spell the word ${_targetWord.join()}");
      if (SettingsService.hintsEnabled) {
        _startHintTimer();
      }
    });
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _showHint = true);
        AudioHelper.speak("The first letter is ${_targetWord.first}");
      }
    });
  }

  void _onLetterTap(String letter) {
    if (_selectedLetters.length >= _targetWord.length) return;

    HapticHelper.lightTap();
    setState(() {
      _selectedLetters.add(letter);
    });

    // Check if word is complete
    if (_selectedLetters.length == _targetWord.length) {
      _hintTimer?.cancel();
      if (_selectedLetters.join() == _targetWord.join()) {
        // Correct!
        HapticHelper.success();
        _score++;
        _confettiController.play();
        AudioHelper.speakSuccess();
        Future.delayed(const Duration(milliseconds: 1500), _startNewRound);
      } else {
        // Wrong
        HapticHelper.error();
        AudioHelper.speakTryAgain();
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() => _selectedLetters = []);
          if (SettingsService.hintsEnabled) {
            _startHintTimer();
          }
        });
      }
    }
  }

  void _removeLetter() {
    if (_selectedLetters.isNotEmpty) {
      HapticHelper.lightTap();
      setState(() => _selectedLetters.removeLast());
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
                const SizedBox(height: 24),

                // Word to spell (with picture hint)
                Text(
                  'Spell the word:',
                  style: TextStyle(
                    fontSize: 28,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Word boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_targetWord.length, (index) {
                    final hasLetter = index < _selectedLetters.length;
                    final isHinted = _showHint && index == 0;
                    return Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: hasLetter ? AppColors.secondary : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHinted ? AppColors.warning : AppColors.secondary,
                          width: isHinted ? 4 : 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          hasLetter ? _selectedLetters[index] : (isHinted ? _targetWord[0] : ''),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: hasLetter ? Colors.white : AppColors.warning,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Clear button
                if (_selectedLetters.isNotEmpty)
                  GestureDetector(
                    onTap: _removeLetter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.error, width: 2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.backspace, color: AppColors.error),
                          SizedBox(width: 8),
                          Text(
                            'Undo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Available letters
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: _availableLetters.map((letter) {
                        final usedCount = _selectedLetters.where((l) => l == letter).length;
                        final availableCount = _availableLetters.where((l) => l == letter).length;
                        final isDisabled = usedCount >= availableCount;

                        return GestureDetector(
                          onTap: isDisabled ? null : () => _onLetterTap(letter),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: isDisabled ? AppColors.disabled : AppColors.accent1,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: isDisabled ? AppColors.textSecondary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
          const Text(
            'Build Words',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Round $_round/$_totalRounds',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent1,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  '$_score',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
