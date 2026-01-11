import 'package:flutter/services.dart';

/// Duolingo-style haptic feedback helper for iOS Taptic Engine
class HapticHelper {
  /// Light tap feedback - for button taps (single light impact)
  static void lightTap() {
    HapticFeedback.lightImpact();
  }

  /// Success feedback - Duolingo style: light impact tapped TWICE rapidly
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error feedback - gentle notification error (not harsh)
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Achievement/Celebration - medium impact for stronger confirmation
  static void celebration() {
    HapticFeedback.mediumImpact();
  }

  /// Button press down - subtle feedback when pressing 3D button
  static void buttonDown() {
    HapticFeedback.selectionClick();
  }
}
