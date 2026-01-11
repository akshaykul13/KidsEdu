import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Write Words Game - Write simple words
class WriteWordsGame extends StatefulWidget {
  const WriteWordsGame({super.key});

  @override
  State<WriteWordsGame> createState() => _WriteWordsGameState();
}

class _WriteWordsGameState extends State<WriteWordsGame> {
  late ConfettiController _confettiController;
  int _currentWordIndex = 0;
  List<Offset?> _points = [];

  final List<Map<String, String>> _words = [
    {'word': 'CAT', 'emoji': '🐱'},
    {'word': 'DOG', 'emoji': '🐕'},
    {'word': 'SUN', 'emoji': '☀️'},
    {'word': 'HAT', 'emoji': '🎩'},
    {'word': 'BEE', 'emoji': '🐝'},
    {'word': 'CUP', 'emoji': '☕'},
    {'word': 'BUS', 'emoji': '🚌'},
    {'word': 'PIG', 'emoji': '🐷'},
    {'word': 'COW', 'emoji': '🐄'},
    {'word': 'ANT', 'emoji': '🐜'},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    AudioHelper.init();
    _speakWord();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _speakWord() async {
    await AudioHelper.speak("Write the word ${_words[_currentWordIndex]['word']}");
  }

  void _clearDrawing() {
    HapticHelper.lightTap();
    setState(() => _points = []);
  }

  void _nextWord() {
    HapticHelper.success();
    _confettiController.play();
    AudioHelper.speakSuccess();

    if (_currentWordIndex < _words.length - 1) {
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _currentWordIndex++;
          _points = [];
        });
        _speakWord();
      });
    } else {
      _showComplete();
    }
  }

  void _showComplete() {
    HapticHelper.celebration();
    AudioHelper.speakGameComplete();
    showDialog(
      context: context,
      builder: (context) => GameCompleteDialog(
        score: _words.length,
        totalRounds: _words.length,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _currentWordIndex = 0;
            _points = [];
          });
          _speakWord();
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
    final currentWord = _words[_currentWordIndex];

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
                      // Left - Word to write
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(currentWord['emoji']!, style: const TextStyle(fontSize: 80)),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                HapticHelper.lightTap();
                                _speakWord();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.volume_up, color: Colors.white, size: 32),
                                    const SizedBox(width: 12),
                                    Text(
                                      currentWord['word']!,
                                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
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
                                    border: Border.all(color: AppColors.primary, width: 4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: GestureDetector(
                                      onPanStart: (d) => setState(() => _points.add(d.localPosition)),
                                      onPanUpdate: (d) => setState(() => _points.add(d.localPosition)),
                                      onPanEnd: (d) => setState(() => _points.add(null)),
                                      child: CustomPaint(painter: _DrawingPainter(_points, AppColors.primary), size: Size.infinite),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _ActionButton(icon: Icons.refresh, label: 'Clear', color: AppColors.error, onTap: _clearDrawing),
                                  const SizedBox(width: 24),
                                  _ActionButton(icon: Icons.check, label: 'Done', color: AppColors.success, onTap: _nextWord),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_words.length, (i) => Container(
                      width: i == _currentWordIndex ? 14 : 8,
                      height: i == _currentWordIndex ? 14 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(color: i <= _currentWordIndex ? AppColors.primary : AppColors.disabled, shape: BoxShape.circle),
                    )),
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
      color: AppColors.primary,
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          const Text('Write Words', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24)),
            child: Text('Word ${_currentWordIndex + 1}/${_words.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
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

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [Icon(icon, color: Colors.white, size: 28), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))]),
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
    final paint = Paint()..color = color..strokeCap = StrokeCap.round..strokeWidth = 12.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) canvas.drawLine(points[i]!, points[i + 1]!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
