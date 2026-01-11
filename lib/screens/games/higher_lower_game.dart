import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Higher or Lower Game - Compare numbers 1-20
class HigherLowerGame extends StatefulWidget {
  const HigherLowerGame({super.key});

  @override
  State<HigherLowerGame> createState() => _HigherLowerGameState();
}

class _HigherLowerGameState extends State<HigherLowerGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 10;
  int _score = 0;
  int _number1 = 0;
  int _number2 = 0;
  bool _askHigher = true; // true = "which is higher?", false = "which is lower?"
  int? _wrongTapped;
  bool _showSuccess = false;
  bool _isWaiting = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    AudioHelper.init();
    _startNewRound();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    if (_round >= _totalRounds) {
      _showGameComplete();
      return;
    }

    setState(() {
      _round++;
      _wrongTapped = null;
      _showSuccess = false;
      _isWaiting = false;
    });

    // Generate two different numbers between 1-20
    _number1 = _random.nextInt(20) + 1;
    do {
      _number2 = _random.nextInt(20) + 1;
    } while (_number2 == _number1);

    // Randomly decide if asking higher or lower
    _askHigher = _random.nextBool();

    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), _speakPrompt);
  }

  Future<void> _speakPrompt() async {
    final question = _askHigher ? "Which number is higher?" : "Which number is lower?";
    await AudioHelper.speak("$_number1 or $_number2. $question");
  }

  int get _correctAnswer {
    if (_askHigher) {
      return _number1 > _number2 ? _number1 : _number2;
    } else {
      return _number1 < _number2 ? _number1 : _number2;
    }
  }

  void _onNumberTap(int number) {
    if (_isWaiting) return;

    if (number == _correctAnswer) {
      HapticHelper.success();
      setState(() {
        _score++;
        _showSuccess = true;
        _isWaiting = true;
      });
      _confettiController.play();
      AudioHelper.speakSuccess();
      Future.delayed(const Duration(milliseconds: 1500), _startNewRound);
    } else {
      HapticHelper.error();
      setState(() => _wrongTapped = number);
      AudioHelper.speakTryAgain();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _wrongTapped = null);
      });
    }
  }

  void _showGameComplete() {
    HapticHelper.celebration();
    AudioHelper.speakGameComplete();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameCompleteDialog(
        score: _score,
        totalRounds: _totalRounds,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _score = 0;
            _round = 0;
          });
          _startNewRound();
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
                const SizedBox(height: 32),
                // Question
                GestureDetector(
                  onTap: () {
                    HapticHelper.lightTap();
                    _speakPrompt();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryShade,
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 16),
                        Text(
                          _askHigher ? 'Which is HIGHER?' : 'Which is LOWER?',
                          style: GoogleFonts.nunito(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Number choices
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NumberCard(
                      number: _number1,
                      isCorrect: _showSuccess && _number1 == _correctAnswer,
                      isWrong: _wrongTapped == _number1,
                      onTap: () => _onNumberTap(_number1),
                    ),
                    const SizedBox(width: 40),
                    Text(
                      'or',
                      style: GoogleFonts.nunito(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 40),
                    _NumberCard(
                      number: _number2,
                      isCorrect: _showSuccess && _number2 == _correctAnswer,
                      isWrong: _wrongTapped == _number2,
                      onTap: () => _onNumberTap(_number2),
                    ),
                  ],
                ),
                const Spacer(),
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
      decoration: BoxDecoration(
        color: AppColors.success,
        boxShadow: [
          BoxShadow(
            color: AppColors.successShade,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          Text(
            'Higher or Lower',
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_round / $_totalRounds',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.attention,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  '$_score',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Number card widget with 3D effect
class _NumberCard extends StatefulWidget {
  final int number;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _NumberCard({
    required this.number,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  State<_NumberCard> createState() => _NumberCardState();
}

class _NumberCardState extends State<_NumberCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.primary;
    Color shadeColor = AppColors.primaryShade;

    if (widget.isCorrect) {
      bgColor = AppColors.success;
      shadeColor = AppColors.successShade;
    } else if (widget.isWrong) {
      bgColor = AppColors.error;
      shadeColor = AppColors.errorShade;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: 180,
        height: 200,
        child: Stack(
          children: [
            // Shadow
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: shadeColor,
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            // Face
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              top: _isPressed ? 8 : 0,
              bottom: _isPressed ? 0 : 8,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(
                    '${widget.number}',
                    style: GoogleFonts.nunito(
                      fontSize: 80,
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
    );
  }
}
