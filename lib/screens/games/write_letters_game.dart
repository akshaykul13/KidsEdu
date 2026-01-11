import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Write Letters Game - Trace and write letters
class WriteLettersGame extends StatefulWidget {
  const WriteLettersGame({super.key});

  @override
  State<WriteLettersGame> createState() => _WriteLettersGameState();
}

class _WriteLettersGameState extends State<WriteLettersGame> {
  late ConfettiController _confettiController;
  int _currentLetterIndex = 0;
  List<Offset?> _points = [];

  final List<String> _letters = List.generate(
    26,
    (index) => String.fromCharCode('A'.codeUnitAt(0) + index),
  );

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    AudioHelper.init();
    _speakLetter();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _speakLetter() async {
    await AudioHelper.speak("Trace the letter ${_letters[_currentLetterIndex]}");
  }

  void _clearDrawing() {
    HapticHelper.lightTap();
    setState(() => _points = []);
  }

  void _nextLetter() {
    HapticHelper.success();
    _confettiController.play();
    AudioHelper.speakSuccess();

    if (_currentLetterIndex < _letters.length - 1) {
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _currentLetterIndex++;
          _points = [];
        });
        _speakLetter();
      });
    } else {
      _showComplete();
    }
  }

  void _previousLetter() {
    if (_currentLetterIndex > 0) {
      HapticHelper.lightTap();
      setState(() {
        _currentLetterIndex--;
        _points = [];
      });
      _speakLetter();
    }
  }

  void _showComplete() {
    HapticHelper.celebration();
    AudioHelper.speakGameComplete();
    showDialog(
      context: context,
      builder: (context) => GameCompleteDialog(
        score: 26,
        totalRounds: 26,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _currentLetterIndex = 0;
            _points = [];
          });
          _speakLetter();
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
                      // Left - Letter to trace
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Trace this letter:',
                              style: TextStyle(fontSize: 28, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                HapticHelper.lightTap();
                                _speakLetter();
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
                                    _letters[_currentLetterIndex],
                                    style: const TextStyle(
                                      fontSize: 140,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.volume_up, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  'Tap to hear',
                                  style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Right - Drawing area
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppColors.secondary, width: 4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: GestureDetector(
                                      onPanStart: (details) {
                                        setState(() => _points.add(details.localPosition));
                                      },
                                      onPanUpdate: (details) {
                                        setState(() => _points.add(details.localPosition));
                                      },
                                      onPanEnd: (details) {
                                        setState(() => _points.add(null));
                                      },
                                      child: CustomPaint(
                                        painter: _DrawingPainter(_points, AppColors.secondary),
                                        size: Size.infinite,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_currentLetterIndex > 0)
                                    _ActionButton(
                                      icon: Icons.arrow_back,
                                      label: 'Back',
                                      color: AppColors.textSecondary,
                                      onTap: _previousLetter,
                                    ),
                                  const SizedBox(width: 16),
                                  _ActionButton(
                                    icon: Icons.refresh,
                                    label: 'Clear',
                                    color: AppColors.error,
                                    onTap: _clearDrawing,
                                  ),
                                  const SizedBox(width: 16),
                                  _ActionButton(
                                    icon: Icons.check,
                                    label: 'Done',
                                    color: AppColors.success,
                                    onTap: _nextLetter,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress dots
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(26, (index) {
                      return Container(
                        width: index == _currentLetterIndex ? 14 : 8,
                        height: index == _currentLetterIndex ? 14 : 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentLetterIndex ? AppColors.primary : AppColors.disabled,
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
      color: AppColors.tileColors[5], // Orange
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          const Text('Write Letters', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24)),
            child: Text(
              'Letter ${_currentLetterIndex + 1}/26',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;

  _DrawingPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
