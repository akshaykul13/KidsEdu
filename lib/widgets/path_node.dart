import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/haptic_helper.dart';

/// Duolingo-style Learning Path Node
///
/// Features:
/// - Circular 80x80pt node with 3D effect
/// - Progress ring around the node
/// - White highlight arc on top for shine
/// - Shadow underneath for depth
class PathNode extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color baseColor;
  final Color shadeColor;
  final double progress; // 0.0 to 1.0
  final bool isLocked;
  final VoidCallback onTap;

  const PathNode({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.baseColor = AppColors.primary,
    this.shadeColor = AppColors.primaryShade,
    this.progress = 0.0,
    this.isLocked = false,
  });

  @override
  State<PathNode> createState() => _PathNodeState();
}

class _PathNodeState extends State<PathNode> {
  bool _isPressed = false;
  static const double _size = 80.0;
  static const double _shadowOffset = 4.0;

  void _handleTapDown(TapDownDetails details) {
    if (widget.isLocked) return;
    setState(() => _isPressed = true);
    HapticHelper.buttonDown();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isLocked) return;
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBaseColor = widget.isLocked
        ? AppColors.neutral
        : widget.baseColor;
    final effectiveShadeColor = widget.isLocked
        ? AppColors.neutralShade
        : widget.shadeColor;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Node with progress ring
          SizedBox(
            width: _size + 16, // Extra space for progress ring
            height: _size + _shadowOffset + 16,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring (behind the node)
                if (widget.progress > 0)
                  SizedBox(
                    width: _size + 12,
                    height: _size + 12,
                    child: CircularProgressIndicator(
                      value: widget.progress,
                      strokeWidth: 4,
                      backgroundColor: AppColors.neutral,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isLocked ? AppColors.neutralShade : AppColors.success,
                      ),
                    ),
                  ),
                // Node shadow
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: _size,
                    height: _size,
                    decoration: BoxDecoration(
                      color: effectiveShadeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Node face
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  bottom: _isPressed ? 0 : _shadowOffset,
                  child: Container(
                    width: _size,
                    height: _size,
                    decoration: BoxDecoration(
                      color: effectiveBaseColor,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        // Shine arc at top
                        Positioned(
                          top: 4,
                          left: _size * 0.2,
                          right: _size * 0.2,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        // Icon
                        Center(
                          child: widget.isLocked
                              ? Icon(
                                  Icons.lock,
                                  size: 32,
                                  color: Colors.white.withValues(alpha: 0.5),
                                )
                              : Icon(
                                  widget.icon,
                                  size: 36,
                                  color: Colors.white,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            widget.label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: widget.isLocked ? AppColors.textMuted : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Helper to calculate S-curve horizontal offset for path nodes
double getPathNodeOffset(int index, {double offsetAmount = 60}) {
  switch (index % 4) {
    case 0:
      return 0; // Center
    case 1:
      return offsetAmount; // Right
    case 2:
      return 0; // Center
    case 3:
      return -offsetAmount; // Left
    default:
      return 0;
  }
}
