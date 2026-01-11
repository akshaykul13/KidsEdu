import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Duolingo-style Progress Bar with 3D "shine" effect
///
/// Features:
/// - Trough (background): Gray rounded bar
/// - Fill: Green rounded bar that grows with progress
/// - Shine: White semi-transparent overlay on top for glass effect
class DuoProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color fillColor;
  final Color troughColor;

  const DuoProgressBar({
    super.key,
    required this.progress,
    this.height = 16,
    this.fillColor = AppColors.success,
    this.troughColor = AppColors.neutral,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Trough (background)
          Container(
            height: height,
            decoration: BoxDecoration(
              color: troughColor,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
          // Fill with shine
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
              child: Stack(
                children: [
                  // Shine effect - white overlay at top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: height * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(height / 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated version of the progress bar
class DuoProgressBarAnimated extends StatelessWidget {
  final double progress;
  final double height;
  final Color fillColor;
  final Color troughColor;
  final Duration duration;

  const DuoProgressBarAnimated({
    super.key,
    required this.progress,
    this.height = 16,
    this.fillColor = AppColors.success,
    this.troughColor = AppColors.neutral,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Trough
          Container(
            height: height,
            decoration: BoxDecoration(
              color: troughColor,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
          // Animated fill
          AnimatedFractionallySizedBox(
            duration: duration,
            curve: Curves.easeInOut,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
              child: Stack(
                children: [
                  // Shine
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: height * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(height / 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for animated fractional sizing
class AnimatedFractionallySizedBox extends StatelessWidget {
  final double widthFactor;
  final Duration duration;
  final Curve curve;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.duration,
    required this.curve,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: duration,
          curve: curve,
          width: constraints.maxWidth * widthFactor,
          child: child,
        );
      },
    );
  }
}
