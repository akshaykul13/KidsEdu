import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../core/theme/app_theme.dart';

/// Celebration overlay with confetti for correct answers
class CelebrationOverlay extends StatelessWidget {
  final ConfettiController controller;

  const CelebrationOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirection: pi / 2,
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 25,
        gravity: 0.1,
        shouldLoop: false,
        colors: const [
          AppColors.primary,
          AppColors.secondary,
          AppColors.accent1,
          AppColors.accent2,
          AppColors.success,
        ],
      ),
    );
  }
}

/// Game complete dialog with stars
class GameCompleteDialog extends StatelessWidget {
  final int score;
  final int totalRounds;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const GameCompleteDialog({
    super.key,
    required this.score,
    required this.totalRounds,
    required this.onPlayAgain,
    required this.onHome,
  });

  String get _starDisplay {
    final percentage = score / totalRounds;
    if (percentage >= 0.8) return '⭐⭐⭐';
    if (percentage >= 0.5) return '⭐⭐';
    return '⭐';
  }

  String get _message {
    final percentage = score / totalRounds;
    if (percentage >= 0.8) return 'Amazing!';
    if (percentage >= 0.5) return 'Great job!';
    return 'Good try!';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🎉 $_message',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              _starDisplay,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              'You got $score out of $totalRounds correct!',
              style: const TextStyle(
                fontSize: 24,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Home button
                GestureDetector(
                  onTap: onHome,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 3,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.home_rounded,
                          size: 28,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Home',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Play again button
                GestureDetector(
                  onTap: onPlayAgain,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.replay_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Play Again',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
