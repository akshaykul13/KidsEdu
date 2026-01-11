import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/settings_service.dart';
import '../../widgets/duo_button.dart';
import '../../widgets/duo_progress_bar.dart';
import '../../widgets/celebration_overlay.dart';

class IdentifyLetterGame extends StatefulWidget {
  const IdentifyLetterGame({super.key});

  @override
  State<IdentifyLetterGame> createState() => _IdentifyLetterGameState();
}

class _IdentifyLetterGameState extends State<IdentifyLetterGame> {
  final Random _random = Random();
  late ConfettiController _confettiController;

  String _targetLetter = '';
  List<String> _displayedLetters = [];
  int _score = 0;
  int _round = 0;
  final int _totalRounds = 10;
  bool _isWaiting = false;
  String? _wrongTappedLetter;
  String? _correctTappedLetter;
  bool _showHint = false;
  Timer? _hintTimer;

  final List<String> _allLetters = List.generate(
    26,
    (index) => String.fromCharCode('A'.codeUnitAt(0) + index),
  );

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    AudioHelper.init();
    _startNewRound();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_isWaiting) {
        setState(() => _showHint = true);
        AudioHelper.speak("The answer is $_targetLetter");
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
      _wrongTappedLetter = null;
      _correctTappedLetter = null;
      _showHint = false;
      _isWaiting = false;
    });

    _targetLetter = _allLetters[_random.nextInt(26)];

    Set<String> letterSet = {_targetLetter};
    while (letterSet.length < 6) {
      letterSet.add(_allLetters[_random.nextInt(26)]);
    }
    _displayedLetters = letterSet.toList()..shuffle();

    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), () {
      _speakPrompt();
      if (SettingsService.hintsEnabled) {
        _startHintTimer();
      }
    });
  }

  Future<void> _speakPrompt() async {
    await AudioHelper.speak('Find the letter $_targetLetter');
  }

  void _onLetterTap(String letter) {
    if (_isWaiting) return;
    _hintTimer?.cancel();

    if (letter == _targetLetter) {
      HapticHelper.success();
      setState(() {
        _score++;
        _correctTappedLetter = letter;
        _showHint = false;
        _isWaiting = true;
      });
      _confettiController.play();
      AudioHelper.speakSuccess();

      Future.delayed(const Duration(milliseconds: 1500), _startNewRound);
    } else {
      HapticHelper.error();
      setState(() {
        _wrongTappedLetter = letter;
        _showHint = false;
      });
      AudioHelper.speakTryAgain();

      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _wrongTappedLetter = null);
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
      builder: (context) => _GameCompleteDialog(
        score: _score,
        totalRounds: _totalRounds,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() { _score = 0; _round = 0; });
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
                // Top bar with exit and progress
                _buildTopBar(),

                // Main content area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Prompt section
                      _buildPromptSection(),
                      const SizedBox(height: 48),
                      // Letters grid
                      _buildLettersGrid(),
                    ],
                  ),
                ),

                // Bottom action zone
                _buildBottomZone(),
              ],
            ),
          ),
          CelebrationOverlay(controller: _confettiController),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.neutral, width: 2),
        ),
      ),
      child: Row(
        children: [
          // Exit button (X) - Duolingo style
          _ExitButton(onTap: () => Navigator.pop(context)),

          const SizedBox(width: 16),

          // Progress bar
          Expanded(
            child: DuoProgressBarAnimated(
              progress: _round / _totalRounds,
              height: 16,
            ),
          ),

          const SizedBox(width: 16),

          // Star counter
          _StarBadge(count: _score),
        ],
      ),
    );
  }

  Widget _buildPromptSection() {
    return Column(
      children: [
        Text(
          'Find the letter',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        // Target letter card with audio
        GestureDetector(
          onTap: () {
            HapticHelper.lightTap();
            _speakPrompt();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neutral, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 36),
                const SizedBox(width: 20),
                Text(
                  _targetLetter,
                  style: GoogleFonts.nunito(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLettersGrid() {
    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: _displayedLetters.map((letter) {
          return _LetterTile(
            letter: letter,
            isCorrect: _correctTappedLetter == letter,
            isWrong: _wrongTappedLetter == letter,
            isHinting: _showHint && letter == _targetLetter,
            onTap: () => _onLetterTap(letter),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomZone() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.neutral, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tap the correct letter!',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Exit (X) button with 3D effect
class _ExitButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ExitButton({required this.onTap});

  @override
  State<_ExitButton> createState() => _ExitButtonState();
}

class _ExitButtonState extends State<_ExitButton> {
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
        width: 44,
        height: 48,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.neutralShade,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              top: _isPressed ? 4 : 0,
              left: 0,
              right: 0,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.neutral,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.close, color: AppColors.textSecondary, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Star badge
class _StarBadge extends StatelessWidget {
  final int count;
  const _StarBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.attention,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.attentionShade, offset: const Offset(0, 3), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text('$count', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }
}

/// 3D Letter tile with pop animation
class _LetterTile extends StatefulWidget {
  final String letter;
  final bool isCorrect;
  final bool isWrong;
  final bool isHinting;
  final VoidCallback onTap;

  const _LetterTile({
    required this.letter,
    required this.onTap,
    this.isCorrect = false,
    this.isWrong = false,
    this.isHinting = false,
  });

  @override
  State<_LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<_LetterTile> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _popController;
  late Animation<double> _popAnimation;

  static const double _size = 120.0;
  static const double _shadowOffset = 6.0;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _popAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCorrect && !oldWidget.isCorrect) {
      _popController.forward().then((_) => _popController.reverse());
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  Color get _baseColor {
    if (widget.isCorrect) return AppColors.success;
    if (widget.isWrong) return AppColors.error;
    return AppColors.primary;
  }

  Color get _shadeColor {
    if (widget.isCorrect) return AppColors.successShade;
    if (widget.isWrong) return AppColors.errorShade;
    return AppColors.primaryShade;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticHelper.buttonDown();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _popAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _popAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _size,
          height: _size + _shadowOffset,
          decoration: widget.isHinting
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.attention.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                )
              : null,
          child: Stack(
            children: [
              // Shadow
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: _size,
                  decoration: BoxDecoration(
                    color: _shadeColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // Face
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                top: _isPressed ? _shadowOffset : 0,
                left: 0,
                right: 0,
                child: Container(
                  height: _size,
                  decoration: BoxDecoration(
                    color: _baseColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Shine
                      Positioned(
                        top: 4,
                        left: 16,
                        right: 16,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      // Letter
                      Center(
                        child: Text(
                          widget.letter,
                          style: GoogleFonts.nunito(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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

/// Game complete dialog with Duolingo style
class _GameCompleteDialog extends StatelessWidget {
  final int score;
  final int totalRounds;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const _GameCompleteDialog({
    required this.score,
    required this.totalRounds,
    required this.onPlayAgain,
    required this.onHome,
  });

  String get _message {
    final ratio = score / totalRounds;
    if (ratio >= 0.8) return 'AMAZING!';
    if (ratio >= 0.6) return 'GREAT JOB!';
    if (ratio >= 0.4) return 'GOOD TRY!';
    return 'KEEP PRACTICING!';
  }

  int get _starCount {
    final ratio = score / totalRounds;
    if (ratio >= 0.8) return 3;
    if (ratio >= 0.5) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message
            Text(
              _message,
              style: GoogleFonts.nunito(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    index < _starCount ? '⭐' : '☆',
                    style: TextStyle(fontSize: 48),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Score
            Text(
              '$score / $totalRounds correct',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 32),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: DuoButton(
                    text: 'HOME',
                    baseColor: Colors.white,
                    shadeColor: AppColors.successShade,
                    onTap: onHome,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DuoButton(
                    text: 'PLAY AGAIN',
                    baseColor: AppColors.attention,
                    shadeColor: AppColors.attentionShade,
                    onTap: onPlayAgain,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
