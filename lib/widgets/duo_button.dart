import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/haptic_helper.dart';

/// Duolingo-style 3D "Chunky" Button
///
/// The button consists of two layers:
/// - Bottom Layer (Shadow): Shade color, stays static
/// - Top Layer (Face): Base color, moves down 4pt when pressed
class DuoButton extends StatefulWidget {
  final String text;
  final Color baseColor;
  final Color shadeColor;
  final VoidCallback onTap;
  final double height;
  final double? width;
  final IconData? icon;
  final bool enabled;

  const DuoButton({
    super.key,
    required this.text,
    required this.onTap,
    this.baseColor = AppColors.success,
    this.shadeColor = AppColors.successShade,
    this.height = 56,
    this.width,
    this.icon,
    this.enabled = true,
  });

  /// Primary blue button
  factory DuoButton.primary({
    required String text,
    required VoidCallback onTap,
    double height = 56,
    double? width,
    IconData? icon,
    bool enabled = true,
  }) {
    return DuoButton(
      text: text,
      onTap: onTap,
      baseColor: AppColors.primary,
      shadeColor: AppColors.primaryShade,
      height: height,
      width: width,
      icon: icon,
      enabled: enabled,
    );
  }

  /// Success green button (default)
  factory DuoButton.success({
    required String text,
    required VoidCallback onTap,
    double height = 56,
    double? width,
    IconData? icon,
    bool enabled = true,
  }) {
    return DuoButton(
      text: text,
      onTap: onTap,
      baseColor: AppColors.success,
      shadeColor: AppColors.successShade,
      height: height,
      width: width,
      icon: icon,
      enabled: enabled,
    );
  }

  /// Attention yellow button
  factory DuoButton.attention({
    required String text,
    required VoidCallback onTap,
    double height = 56,
    double? width,
    IconData? icon,
    bool enabled = true,
  }) {
    return DuoButton(
      text: text,
      onTap: onTap,
      baseColor: AppColors.attention,
      shadeColor: AppColors.attentionShade,
      height: height,
      width: width,
      icon: icon,
      enabled: enabled,
    );
  }

  /// Error red button
  factory DuoButton.error({
    required String text,
    required VoidCallback onTap,
    double height = 56,
    double? width,
    IconData? icon,
    bool enabled = true,
  }) {
    return DuoButton(
      text: text,
      onTap: onTap,
      baseColor: AppColors.error,
      shadeColor: AppColors.errorShade,
      height: height,
      width: width,
      icon: icon,
      enabled: enabled,
    );
  }

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;
  static const double _shadowOffset = 4.0;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    HapticHelper.buttonDown();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBaseColor = widget.enabled
        ? widget.baseColor
        : AppColors.neutral;
    final effectiveShadeColor = widget.enabled
        ? widget.shadeColor
        : AppColors.neutralShade;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: SizedBox(
        width: widget.width,
        height: widget.height + _shadowOffset,
        child: Stack(
          children: [
            // Bottom Layer (Shadow) - stays static
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: effectiveShadeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // Top Layer (Face) - moves down when pressed
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              top: _isPressed ? _shadowOffset : 0,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: effectiveBaseColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text.toUpperCase(),
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
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
}

/// Duolingo-style 3D Answer Tile for games
class DuoAnswerTile extends StatefulWidget {
  final String text;
  final Color baseColor;
  final Color shadeColor;
  final VoidCallback onTap;
  final bool isCorrect;
  final bool isWrong;
  final bool isHinting;
  final double size;

  const DuoAnswerTile({
    super.key,
    required this.text,
    required this.onTap,
    this.baseColor = AppColors.primary,
    this.shadeColor = AppColors.primaryShade,
    this.isCorrect = false,
    this.isWrong = false,
    this.isHinting = false,
    this.size = 120,
  });

  @override
  State<DuoAnswerTile> createState() => _DuoAnswerTileState();
}

class _DuoAnswerTileState extends State<DuoAnswerTile>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _popController;
  late Animation<double> _popAnimation;
  static const double _shadowOffset = 4.0;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _popAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(DuoAnswerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCorrect && !oldWidget.isCorrect) {
      _popController.forward().then((_) => _popController.reverse());
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticHelper.buttonDown();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  Color get _effectiveBaseColor {
    if (widget.isCorrect) return AppColors.success;
    if (widget.isWrong) return AppColors.error;
    return widget.baseColor;
  }

  Color get _effectiveShadeColor {
    if (widget.isCorrect) return AppColors.successShade;
    if (widget.isWrong) return AppColors.errorShade;
    return widget.shadeColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _popAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _popAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size + _shadowOffset,
          decoration: widget.isHinting
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.attention.withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: Stack(
            children: [
              // Shadow layer
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: _effectiveShadeColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // Face layer
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                top: _isPressed ? _shadowOffset : 0,
                child: Container(
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: _effectiveBaseColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.text,
                      style: GoogleFonts.nunito(
                        fontSize: widget.size * 0.4,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
