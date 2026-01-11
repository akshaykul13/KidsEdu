import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Before/After Game - Build numbers using digit tiles
class BeforeAfterGame extends StatefulWidget {
  const BeforeAfterGame({super.key});

  @override
  State<BeforeAfterGame> createState() => _BeforeAfterGameState();
}

class _BeforeAfterGameState extends State<BeforeAfterGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 10;
  int _score = 0;
  int _targetNumber = 0;
  bool _askBefore = true; // true = "what comes before?", false = "what comes after?"
  String _userAnswer = '';
  bool _showSuccess = false;
  bool _showError = false;
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
      _userAnswer = '';
      _showSuccess = false;
      _showError = false;
      _isWaiting = false;
    });

    // Generate target number 2-30 for "before" or 1-29 for "after"
    if (_random.nextBool()) {
      _askBefore = true;
      _targetNumber = _random.nextInt(29) + 2; // 2-30 (so answer is 1-29)
    } else {
      _askBefore = false;
      _targetNumber = _random.nextInt(29) + 1; // 1-29 (so answer is 2-30)
    }

    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), _speakPrompt);
  }

  Future<void> _speakPrompt() async {
    final question = _askBefore
        ? "What number comes before $_targetNumber?"
        : "What number comes after $_targetNumber?";
    await AudioHelper.speak(question);
  }

  int get _correctAnswer {
    return _askBefore ? _targetNumber - 1 : _targetNumber + 1;
  }

  void _onDigitTap(int digit) {
    if (_isWaiting) return;

    HapticHelper.lightTap();

    // Limit answer to 2 digits (max answer is 30)
    if (_userAnswer.length < 2) {
      setState(() {
        _userAnswer += digit.toString();
      });
    }
  }

  void _onBackspace() {
    if (_isWaiting || _userAnswer.isEmpty) return;

    HapticHelper.lightTap();
    setState(() {
      _userAnswer = _userAnswer.substring(0, _userAnswer.length - 1);
    });
  }

  void _onSubmit() {
    if (_isWaiting || _userAnswer.isEmpty) return;

    final answer = int.tryParse(_userAnswer);

    if (answer == _correctAnswer) {
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
      setState(() {
        _showError = true;
      });
      AudioHelper.speakTryAgain();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showError = false;
            _userAnswer = '';
          });
        }
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
                const Spacer(),
                // Question display
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
                          _askBefore ? 'What comes BEFORE?' : 'What comes AFTER?',
                          style: GoogleFonts.nunito(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Target number display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryShade,
                        offset: const Offset(0, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    '$_targetNumber',
                    style: GoogleFonts.nunito(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Answer display
                Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _showSuccess
                        ? AppColors.success
                        : _showError
                            ? AppColors.error
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _showSuccess
                          ? AppColors.success
                          : _showError
                              ? AppColors.error
                              : AppColors.primary,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _userAnswer.isEmpty ? '?' : _userAnswer,
                      style: GoogleFonts.nunito(
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                        color: _userAnswer.isEmpty
                            ? AppColors.textSecondary
                            : _showSuccess || _showError
                                ? Colors.white
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Digit tiles
                _buildDigitPad(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          CelebrationOverlay(controller: _confettiController),
        ],
      ),
    );
  }

  Widget _buildDigitPad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Digits 1-5
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => _DigitTile(
              digit: index + 1,
              onTap: () => _onDigitTap(index + 1),
            )),
          ),
          const SizedBox(height: 12),
          // Digits 6-0 + backspace + submit
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(4, (index) => _DigitTile(
                digit: index + 6,
                onTap: () => _onDigitTap(index + 6),
              )),
              _DigitTile(
                digit: 0,
                onTap: () => _onDigitTap(0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionTile(
                icon: Icons.backspace_rounded,
                color: AppColors.attention,
                shadeColor: AppColors.attentionShade,
                onTap: _onBackspace,
              ),
              const SizedBox(width: 16),
              _ActionTile(
                icon: Icons.check_rounded,
                color: AppColors.success,
                shadeColor: AppColors.successShade,
                onTap: _onSubmit,
                isLarge: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShade,
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
            'Before & After',
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

/// Digit tile widget with 3D effect
class _DigitTile extends StatefulWidget {
  final int digit;
  final VoidCallback onTap;

  const _DigitTile({
    required this.digit,
    required this.onTap,
  });

  @override
  State<_DigitTile> createState() => _DigitTileState();
}

class _DigitTileState extends State<_DigitTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: SizedBox(
          width: 70,
          height: 80,
          child: Stack(
            children: [
              // Shadow
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryShade,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // Face
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                top: _isPressed ? 6 : 0,
                bottom: _isPressed ? 0 : 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.digit}',
                      style: GoogleFonts.nunito(
                        fontSize: 40,
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

/// Action tile (backspace/submit) with 3D effect
class _ActionTile extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color shadeColor;
  final VoidCallback onTap;
  final bool isLarge;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.shadeColor,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: widget.isLarge ? 160 : 100,
        height: 70,
        child: Stack(
          children: [
            // Shadow
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.shadeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // Face
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              top: _isPressed ? 6 : 0,
              bottom: _isPressed ? 0 : 6,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 36,
                    color: Colors.white,
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
