import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'navigation_buttons.dart';

/// Standard game app bar with back button, title, progress, and score
class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int currentRound;
  final int totalRounds;
  final int score;
  final Color? backgroundColor;

  const GameAppBar({
    super.key,
    required this.title,
    required this.currentRound,
    required this.totalRounds,
    required this.score,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.secondary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              // Back button
              const BackButton(),
              const SizedBox(width: 24),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const Spacer(),

              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Round $currentRound/$totalRounds',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent1,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Text(
                      '⭐',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 24,
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
      ),
    );
  }
}
