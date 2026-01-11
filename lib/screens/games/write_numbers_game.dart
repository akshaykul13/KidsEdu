import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Write Numbers Game - Trace and write numbers 1-20
class WriteNumbersGame extends StatefulWidget {
  const WriteNumbersGame({super.key});

  @override
  State<WriteNumbersGame> createState() => _WriteNumbersGameState();
}

class _WriteNumbersGameState extends State<WriteNumbersGame> {
  late ConfettiController _confettiController;
  int _currentNumber = 1;
  List<Offset?> _points = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    AudioHelper.init();
    _speakNumber();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _speakNumber() async {
    await AudioHelper.speak("Trace the number $_currentNumber");
  }

  void _clearDrawing() {
    HapticHelper.lightTap();
    setState(() => _points = []);
  }

  void _nextNumber() {
    HapticHelper.success();
    _confettiController.play();
    AudioHelper.speakSuccess();

    if (_currentNumber < 20) {
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _currentNumber++;
          _points = [];
        });
        _speakNumber();
      });
    } else {
      _showComplete();
    }
  }

  void _previousNumber() {
    if (_currentNumber > 1) {
      HapticHelper.lightTap();
      setState(() {
        _currentNumber--;
        _points = [];
      });
      _speakNumber();
    }
  }

  void _showComplete() {
    HapticHelper.celebration();
    AudioHelper.speakGameComplete();
    showDialog(
      context: context,
      builder: (context) => GameCompleteDialog(
        score: 20,
        totalRounds: 20,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _currentNumber = 1;
            _points = [];
          });
          _speakNumber();
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
                      // Left - Number to trace
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Trace this number:', style: TextStyle(fontSize: 28, color: AppColors.textSecondary)),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                HapticHelper.lightTap();
                                _speakNumber();
                              },
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: AppColors.tileColors[(_currentNumber - 1) % AppColors.tileColors.length],
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: Center(
                                  child: Text(
                                    '$_currentNumber',
                                    style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: Colors.white),
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
                                Text('Tap to hear', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
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
                                    border: Border.all(color: AppColors.accent2, width: 4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: GestureDetector(
                                      onPanStart: (details) => setState(() => _points.add(details.localPosition)),
                                      onPanUpdate: (details) => setState(() => _points.add(details.localPosition)),
                                      onPanEnd: (details) => setState(() => _points.add(null)),
                                      child: CustomPaint(
                                        painter: _DrawingPainter(_points, AppColors.accent2),
                                        size: Size.infinite,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_currentNumber > 1)
                                    _ActionButton(icon: Icons.arrow_back, label: 'Back', color: AppColors.textSecondary, onTap: _previousNumber),
                                  const SizedBox(width: 16),
                                  _ActionButton(icon: Icons.refresh, label: 'Clear', color: AppColors.error, onTap: _clearDrawing),
                                  const SizedBox(width: 16),
                                  _ActionButton(icon: Icons.check, label: 'Done', color: AppColors.success, onTap: _nextNumber),
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
                    children: List.generate(20, (index) {
                      return Container(
                        width: index == _currentNumber - 1 ? 14 : 8,
                        height: index == _currentNumber - 1 ? 14 : 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index < _currentNumber ? AppColors.accent2 : AppColors.disabled,
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
      color: AppColors.accent2,
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          const Text('Write Numbers', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24)),
            child: Text('Number $_currentNumber/20', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
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
