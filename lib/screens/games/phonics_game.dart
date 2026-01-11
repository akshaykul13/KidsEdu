import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/answer_tile.dart';
import '../../widgets/celebration_overlay.dart';

/// Letter Phonics Game - Learn letter sounds
class PhonicsGame extends StatefulWidget {
  const PhonicsGame({super.key});

  @override
  State<PhonicsGame> createState() => _PhonicsGameState();
}

class _PhonicsGameState extends State<PhonicsGame> {
  final Random _random = Random();
  late ConfettiController _confettiController;

  int _currentLetterIndex = 0;
  bool _showHint = false;
  Timer? _hintTimer;

  final List<Map<String, String>> _phonicsData = [
    {'letter': 'A', 'sound': 'ah', 'word': 'Apple', 'emoji': '🍎'},
    {'letter': 'B', 'sound': 'buh', 'word': 'Ball', 'emoji': '⚽'},
    {'letter': 'C', 'sound': 'kuh', 'word': 'Cat', 'emoji': '🐱'},
    {'letter': 'D', 'sound': 'duh', 'word': 'Dog', 'emoji': '🐕'},
    {'letter': 'E', 'sound': 'eh', 'word': 'Elephant', 'emoji': '🐘'},
    {'letter': 'F', 'sound': 'fuh', 'word': 'Fish', 'emoji': '🐟'},
    {'letter': 'G', 'sound': 'guh', 'word': 'Giraffe', 'emoji': '🦒'},
    {'letter': 'H', 'sound': 'huh', 'word': 'Hat', 'emoji': '🎩'},
    {'letter': 'I', 'sound': 'ih', 'word': 'Ice cream', 'emoji': '🍦'},
    {'letter': 'J', 'sound': 'juh', 'word': 'Jellyfish', 'emoji': '🪼'},
    {'letter': 'K', 'sound': 'kuh', 'word': 'Kite', 'emoji': '🪁'},
    {'letter': 'L', 'sound': 'luh', 'word': 'Lion', 'emoji': '🦁'},
    {'letter': 'M', 'sound': 'muh', 'word': 'Monkey', 'emoji': '🐵'},
    {'letter': 'N', 'sound': 'nuh', 'word': 'Nest', 'emoji': '🪺'},
    {'letter': 'O', 'sound': 'oh', 'word': 'Orange', 'emoji': '🍊'},
    {'letter': 'P', 'sound': 'puh', 'word': 'Penguin', 'emoji': '🐧'},
    {'letter': 'Q', 'sound': 'kwuh', 'word': 'Queen', 'emoji': '👸'},
    {'letter': 'R', 'sound': 'ruh', 'word': 'Rainbow', 'emoji': '🌈'},
    {'letter': 'S', 'sound': 'suh', 'word': 'Sun', 'emoji': '☀️'},
    {'letter': 'T', 'sound': 'tuh', 'word': 'Tiger', 'emoji': '🐯'},
    {'letter': 'U', 'sound': 'uh', 'word': 'Umbrella', 'emoji': '☂️'},
    {'letter': 'V', 'sound': 'vuh', 'word': 'Violin', 'emoji': '🎻'},
    {'letter': 'W', 'sound': 'wuh', 'word': 'Whale', 'emoji': '🐋'},
    {'letter': 'X', 'sound': 'ks', 'word': 'Xylophone', 'emoji': '🎵'},
    {'letter': 'Y', 'sound': 'yuh', 'word': 'Yo-yo', 'emoji': '🪀'},
    {'letter': 'Z', 'sound': 'zuh', 'word': 'Zebra', 'emoji': '🦓'},
  ];

  Map<String, String> get _currentPhonics => _phonicsData[_currentLetterIndex];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    AudioHelper.init();
    _speakCurrentLetter();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _speakCurrentLetter() async {
    final data = _currentPhonics;
    await AudioHelper.speak(
      "${data['letter']} says ${data['sound']}. ${data['letter']} is for ${data['word']}."
    );
  }

  void _nextLetter() {
    HapticHelper.lightTap();
    if (_currentLetterIndex < _phonicsData.length - 1) {
      setState(() {
        _currentLetterIndex++;
      });
      _confettiController.play();
      Future.delayed(const Duration(milliseconds: 500), _speakCurrentLetter);
    } else {
      _showComplete();
    }
  }

  void _previousLetter() {
    HapticHelper.lightTap();
    if (_currentLetterIndex > 0) {
      setState(() {
        _currentLetterIndex--;
      });
      Future.delayed(const Duration(milliseconds: 300), _speakCurrentLetter);
    }
  }

  void _showComplete() {
    HapticHelper.celebration();
    AudioHelper.speak("Great job! You learned all the letter sounds!");
    showDialog(
      context: context,
      builder: (context) => GameCompleteDialog(
        score: 26,
        totalRounds: 26,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() => _currentLetterIndex = 0);
          _speakCurrentLetter();
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
    final data = _currentPhonics;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Row(
                    children: [
                      // Left navigation
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: _currentLetterIndex > 0
                            ? _NavButton(
                                icon: Icons.arrow_back_rounded,
                                onTap: _previousLetter,
                              )
                            : const SizedBox(width: 88),
                      ),

                      // Main content
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Large letter
                            GestureDetector(
                              onTap: () {
                                HapticHelper.lightTap();
                                _speakCurrentLetter();
                              },
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: AppColors.tileColors[_currentLetterIndex % AppColors.tileColors.length],
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: Center(
                                  child: Text(
                                    data['letter']!,
                                    style: const TextStyle(
                                      fontSize: 120,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Sound
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.volume_up, size: 32, color: AppColors.textSecondary),
                                const SizedBox(width: 12),
                                Text(
                                  '"${data['sound']}"',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Word with emoji
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.secondary, width: 3),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    data['emoji']!,
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    data['word']!,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right navigation
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: _NavButton(
                          icon: Icons.arrow_forward_rounded,
                          onTap: _nextLetter,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress dots
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(26, (index) {
                      return Container(
                        width: index == _currentLetterIndex ? 16 : 10,
                        height: index == _currentLetterIndex ? 16 : 10,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index <= _currentLetterIndex
                              ? AppColors.primary
                              : AppColors.disabled,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
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
      color: AppColors.primary,
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          const Text(
            'Letter Phonics',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '${_currentLetterIndex + 1} / 26',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _NavButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: color ?? AppColors.secondary,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(icon, size: 48, color: Colors.white),
      ),
    );
  }
}
