import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/haptic_helper.dart';

enum AnswerTileState {
  normal,
  correct,
  wrong,
  hinting,
}

/// Reusable answer tile for games
/// Supports hint animation, correct/wrong states
class AnswerTile extends StatefulWidget {
  final String text;
  final AnswerTileState state;
  final VoidCallback onTap;
  final double size;
  final double fontSize;

  const AnswerTile({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
    this.size = 140,
    this.fontSize = 72,
  });

  @override
  State<AnswerTile> createState() => _AnswerTileState();
}

class _AnswerTileState extends State<AnswerTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _hintController;
  late Animation<double> _hintAnimation;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _hintAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnswerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == AnswerTileState.hinting) {
      _hintController.repeat(reverse: true);
    } else {
      _hintController.stop();
      _hintController.reset();
    }
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.state) {
      case AnswerTileState.correct:
        return AppColors.success;
      case AnswerTileState.wrong:
        return AppColors.error;
      case AnswerTileState.hinting:
        return AppColors.surface;
      case AnswerTileState.normal:
        return AppColors.surface;
    }
  }

  Color get _borderColor {
    switch (widget.state) {
      case AnswerTileState.correct:
        return AppColors.success;
      case AnswerTileState.wrong:
        return AppColors.error;
      case AnswerTileState.hinting:
        return AppColors.warning;
      case AnswerTileState.normal:
        return AppColors.secondary;
    }
  }

  Color get _textColor {
    switch (widget.state) {
      case AnswerTileState.correct:
      case AnswerTileState.wrong:
        return Colors.white;
      case AnswerTileState.hinting:
      case AnswerTileState.normal:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticHelper.lightTap();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _hintAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.state == AnswerTileState.hinting
                ? _hintAnimation.value
                : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _borderColor,
                  width: 4,
                ),
                boxShadow: widget.state == AnswerTileState.hinting
                    ? [
                        BoxShadow(
                          color: AppColors.warning.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
