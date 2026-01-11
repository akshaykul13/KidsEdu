import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import 'duo_button.dart';

/// Duolingo-style Success Drawer that slides up from bottom
///
/// Features:
/// - 25% of screen height
/// - Spring animation with bounce
/// - Mascot, celebratory text, and CONTINUE button
class SuccessDrawer extends StatelessWidget {
  final VoidCallback onContinue;
  final String message;

  const SuccessDrawer({
    super.key,
    required this.onContinue,
    this.message = 'AMAZING!',
  });

  static void show(BuildContext context, {
    required VoidCallback onContinue,
    String message = 'AMAZING!',
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => SuccessDrawer(
        onContinue: () {
          Navigator.pop(context);
          onContinue();
        },
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.25,
      decoration: const BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Mascot (victory pose)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(width: 24),
              // Message and button
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: DuoButton(
                        text: 'CONTINUE',
                        onTap: onContinue,
                        baseColor: Colors.white,
                        shadeColor: AppColors.successShade,
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
