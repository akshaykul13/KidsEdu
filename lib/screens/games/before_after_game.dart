import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Difficulty levels for Before/After game
enum BeforeAfterDifficulty {
  easy(
    name: 'Easy',
    description: 'Numbers 1-10',
    maxNumber: 10,
  ),
  medium(
    name: 'Medium',
    description: 'Numbers 1-20',
    maxNumber: 20,
  ),
  hard(
    name: 'Hard',
    description: 'Numbers 1-30',
    maxNumber: 30,
  );

  final String name;
  final String description;
  final int maxNumber;

  const BeforeAfterDifficulty({
    required this.name,
    required this.description,
    required this.maxNumber,
  });
}

/// Before/After Game - Build numbers using digit tiles
class BeforeAfterGame extends StatefulWidget {
  const BeforeAfterGame({super.key});

  @override
  State<BeforeAfterGame> createState() => _BeforeAfterGameState();
}

class _BeforeAfterGameState extends State<BeforeAfterGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  BeforeAfterDifficulty? _difficulty;
  int _round = 0;
  final int _totalRounds = 10;
  int _score = 0;
  int _targetNumber = 0;
  bool _askBefore = true; // true = "what comes before?", false = "what comes after?"
  String _userAnswer = '';
  bool _showSuccess = false;
  bool _showError = false;
  bool _isWaiting = false;

  int get _maxNumber => _difficulty?.maxNumber ?? 10;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    AudioHelper.init();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _selectDifficulty(BeforeAfterDifficulty difficulty) {
    HapticHelper.lightTap();
    setState(() {
      _difficulty = difficulty;
    });
    _startNewRound();
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

    // Generate target number based on difficulty
    if (_random.nextBool()) {
      _askBefore = true;
      _targetNumber = _random.nextInt(_maxNumber - 1) + 2; // 2 to maxNumber (so answer is 1 to maxNumber-1)
    } else {
      _askBefore = false;
      _targetNumber = _random.nextInt(_maxNumber - 1) + 1; // 1 to maxNumber-1 (so answer is 2 to maxNumber)
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
    if (_difficulty == null) {
      return _buildDifficultySelector();
    }

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

  Widget _buildDifficultySelector() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
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
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🔢',
                        style: TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Choose Difficulty',
                        style: GoogleFonts.nunito(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _DifficultyButton(
                        title: 'Easy',
                        subtitle: 'Numbers 1-10',
                        emoji: '🌟',
                        color: AppColors.success,
                        shadeColor: AppColors.successShade,
                        onTap: () => _selectDifficulty(BeforeAfterDifficulty.easy),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
                      const SizedBox(height: 16),
                      _DifficultyButton(
                        title: 'Medium',
                        subtitle: 'Numbers 1-20',
                        emoji: '🧩',
                        color: AppColors.attention,
                        shadeColor: AppColors.attentionShade,
                        onTap: () => _selectDifficulty(BeforeAfterDifficulty.medium),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
                      const SizedBox(height: 16),
                      _DifficultyButton(
                        title: 'Hard',
                        subtitle: 'Numbers 1-30',
                        emoji: '🧠',
                        color: AppColors.error,
                        shadeColor: AppColors.errorShade,
                        onTap: () => _selectDifficulty(BeforeAfterDifficulty.hard),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
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
          const SizedBox(width: 16),
          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _difficulty == BeforeAfterDifficulty.easy
                  ? AppColors.success
                  : _difficulty == BeforeAfterDifficulty.medium
                      ? AppColors.attention
                      : AppColors.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _difficulty?.name ?? '',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
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

/// Difficulty selection button
class _DifficultyButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final Color shadeColor;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.shadeColor,
    required this.onTap,
  });

  @override
  State<_DifficultyButton> createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<_DifficultyButton> {
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
        width: 320,
        height: 90,
        child: Stack(
          children: [
            // Shadow
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 84,
                decoration: BoxDecoration(
                  color: widget.shadeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Face
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: 0,
              right: 0,
              top: _isPressed ? 6 : 0,
              child: Container(
                height: 84,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.nunito(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
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
    );
  }
}
