import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/settings_service.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/answer_tile.dart';
import '../../widgets/celebration_overlay.dart';

/// Difficulty levels for Math game
enum MathDifficulty {
  easy(
    name: 'Easy',
    description: 'Add numbers 1-5',
    maxNumber: 5,
  ),
  medium(
    name: 'Medium',
    description: 'Add numbers 1-10',
    maxNumber: 10,
  );

  final String name;
  final String description;
  final int maxNumber;

  const MathDifficulty({
    required this.name,
    required this.description,
    required this.maxNumber,
  });
}

/// Basic Math Game - Simple addition
class MathGame extends StatefulWidget {
  const MathGame({super.key});

  @override
  State<MathGame> createState() => _MathGameState();
}

class _MathGameState extends State<MathGame> {
  final Random _random = Random();
  late ConfettiController _confettiController;

  MathDifficulty? _difficulty;
  int _num1 = 0;
  int _num2 = 0;
  int _answer = 0;
  List<int> _options = [];
  int _score = 0;
  int _round = 0;
  final int _totalRounds = 10;
  bool _isWaiting = false;
  int? _wrongTappedAnswer;
  bool _showSuccess = false;
  bool _showHint = false;
  Timer? _hintTimer;

  int get _maxNumber => _difficulty?.maxNumber ?? 5;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    AudioHelper.init();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _selectDifficulty(MathDifficulty difficulty) {
    HapticHelper.lightTap();
    setState(() {
      _difficulty = difficulty;
    });
    _startNewRound();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_isWaiting) {
        setState(() => _showHint = true);
        AudioHelper.speak("The answer is $_answer");
      }
    });
  }

  void _startNewRound() {
    if (_round >= _totalRounds) {
      _showGameComplete();
      return;
    }

    setState(() {
      _round++;
      _wrongTappedAnswer = null;
      _showSuccess = false;
      _showHint = false;
      _isWaiting = false;
    });

    // Generate addition based on difficulty
    _num1 = _random.nextInt(_maxNumber) + 1;
    _num2 = _random.nextInt(_maxNumber) + 1;
    _answer = _num1 + _num2;

    // Create options: correct answer + 3 wrong
    Set<int> optionSet = {_answer};
    while (optionSet.length < 4) {
      int wrong = _answer + (_random.nextInt(5) - 2);
      if (wrong > 0 && wrong != _answer) {
        optionSet.add(wrong);
      }
    }
    _options = optionSet.toList()..shuffle();

    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), () {
      _speakPrompt();
      if (SettingsService.hintsEnabled) {
        _startHintTimer();
      }
    });
  }

  Future<void> _speakPrompt() async {
    await AudioHelper.speak('What is $_num1 plus $_num2?');
  }

  void _onAnswerTap(int answer) {
    if (_isWaiting) return;

    _hintTimer?.cancel();

    if (answer == _answer) {
      HapticHelper.success();
      setState(() {
        _score++;
        _showSuccess = true;
        _showHint = false;
        _isWaiting = true;
      });
      _confettiController.play();
      AudioHelper.speakSuccess();

      Future.delayed(const Duration(milliseconds: 1500), _startNewRound);
    } else {
      HapticHelper.error();
      setState(() {
        _wrongTappedAnswer = answer;
        _showHint = false;
      });
      AudioHelper.speakTryAgain();

      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _wrongTappedAnswer = null);
        if (SettingsService.hintsEnabled) {
          _startHintTimer();
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

  AnswerTileState _getTileState(int option) {
    if (_showSuccess && option == _answer) return AnswerTileState.correct;
    if (option == _wrongTappedAnswer) return AnswerTileState.wrong;
    if (_showHint && option == _answer) return AnswerTileState.hinting;
    return AnswerTileState.normal;
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
                const SizedBox(height: 32),

                // Math problem
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.secondary, width: 4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNumberBox(_num1),
                      const SizedBox(width: 24),
                      const Text('+', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(width: 24),
                      _buildNumberBox(_num2),
                      const SizedBox(width: 24),
                      const Text('=', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(width: 24),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.accent1.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent1, width: 3),
                        ),
                        child: const Center(
                          child: Text('?', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Speaker button
                GestureDetector(
                  onTap: () {
                    HapticHelper.lightTap();
                    _speakPrompt();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text('Hear it', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Answer options
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: _options.map((option) {
                        return AnswerTile(
                          text: '$option',
                          state: _getTileState(option),
                          onTap: () => _onAnswerTap(option),
                          size: 140,
                          fontSize: 64,
                        );
                      }).toList(),
                    ),
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

  Widget _buildNumberBox(int number) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
              color: AppColors.success,
              child: Row(
                children: [
                  const GameBackButton(),
                  const SizedBox(width: 24),
                  Text(
                    'Basic Math',
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
                        '➕',
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
                        subtitle: 'Add numbers 1-5',
                        emoji: '🌟',
                        color: AppColors.success,
                        shadeColor: AppColors.successShade,
                        onTap: () => _selectDifficulty(MathDifficulty.easy),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
                      const SizedBox(height: 16),
                      _DifficultyButton(
                        title: 'Medium',
                        subtitle: 'Add numbers 1-10',
                        emoji: '🧩',
                        color: AppColors.attention,
                        shadeColor: AppColors.attentionShade,
                        onTap: () => _selectDifficulty(MathDifficulty.medium),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
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
      color: AppColors.success,
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          Text(
            'Basic Math',
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
              color: _difficulty == MathDifficulty.easy
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppColors.attention,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24)),
            child: Text('Round $_round/$_totalRounds', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: AppColors.accent1, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text('$_score', style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
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
