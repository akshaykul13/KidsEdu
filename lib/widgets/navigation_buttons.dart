import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/haptic_helper.dart';

/// Standard back button following design system
/// Minimum 88pt touch target, always visible
class GameBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GameBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticHelper.lightTap();
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.secondary,
            width: 3,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          size: 44,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}

/// Home button for navigation
class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticHelper.lightTap();
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.secondary,
            width: 3,
          ),
        ),
        child: const Icon(
          Icons.home_rounded,
          size: 44,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
