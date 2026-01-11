import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/settings_service.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/answer_tile.dart';
import '../../widgets/celebration_overlay.dart';

/// Calendar Game - Learn days and months
class CalendarGame extends StatefulWidget {
  const CalendarGame({super.key});

  @override
  State<CalendarGame> createState() => _CalendarGameState();
}

class _CalendarGameState extends State<CalendarGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 10;
  int _score = 0;
  String _question = '';
  String _answer = '';
  List<String> _options = [];
  String? _wrongTapped;
  bool _showSuccess = false;
  bool _isWaiting = false;
  bool _showHint = false;
  Timer? _hintTimer;
  bool _isMonthQuestion = true;

  final List<String> _days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

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

  void _startNewRound() {
    if (_round >= _totalRounds) {
      _showGameComplete();
      return;
    }

    setState(() {
      _round++;
      _wrongTapped = null;
      _showSuccess = false;
      _showHint = false;
      _isWaiting = false;
    });

    // Alternate between day and month questions
    _isMonthQuestion = _round % 2 == 0;

    if (_isMonthQuestion) {
      final monthNum = _random.nextInt(12) + 1;
      _question = 'Which month is number $monthNum?';
      _answer = _months[monthNum - 1];
      Set<String> optSet = {_answer};
      while (optSet.length < 4) optSet.add(_months[_random.nextInt(12)]);
      _options = optSet.toList()..shuffle();
    } else {
      final dayNum = _random.nextInt(7) + 1;
      _question = 'Which day is number $dayNum of the week?';
      _answer = _days[dayNum - 1];
      Set<String> optSet = {_answer};
      while (optSet.length < 4) optSet.add(_days[_random.nextInt(7)]);
      _options = optSet.toList()..shuffle();
    }

    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), () {
      AudioHelper.speak(_question);
      if (SettingsService.hintsEnabled) {
        _startHintTimer();
      }
    });
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_isWaiting) {
        setState(() => _showHint = true);
        AudioHelper.speak("The answer is $_answer");
      }
    });
  }

  void _onOptionTap(String option) {
    if (_isWaiting) return;
    _hintTimer?.cancel();

    if (option == _answer) {
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
      setState(() => _wrongTapped = option);
      AudioHelper.speakTryAgain();
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _wrongTapped = null);
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
          setState(() { _score = 0; _round = 0; });
          _startNewRound();
        },
        onHome: () { Navigator.pop(context); Navigator.pop(context); },
      ),
    );
  }

  AnswerTileState _getTileState(String option) {
    if (_showSuccess && option == _answer) return AnswerTileState.correct;
    if (option == _wrongTapped) return AnswerTileState.wrong;
    if (_showHint && option == _answer) return AnswerTileState.hinting;
    return AnswerTileState.normal;
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
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.secondary, width: 3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () { HapticHelper.lightTap(); AudioHelper.speak(_question); },
                        child: const Icon(Icons.volume_up_rounded, color: AppColors.secondary, size: 40),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        child: Text(
                          _question,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Options
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: _options.map((option) {
                        return _OptionButton(
                          text: option,
                          state: _getTileState(option),
                          onTap: () => _onOptionTap(option),
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.error,
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          const Text('Calendar & Date', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24)),
            child: Text('Round $_round/$_totalRounds', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: AppColors.accent1, borderRadius: BorderRadius.circular(24)),
            child: Row(children: [const Text('⭐', style: TextStyle(fontSize: 24)), const SizedBox(width: 8), Text('$_score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary))]),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final AnswerTileState state;
  final VoidCallback onTap;

  const _OptionButton({required this.text, required this.state, required this.onTap});

  Color get _bgColor {
    switch (state) {
      case AnswerTileState.correct: return AppColors.success;
      case AnswerTileState.wrong: return AppColors.error;
      case AnswerTileState.hinting: return AppColors.surface;
      case AnswerTileState.normal: return AppColors.surface;
    }
  }

  Color get _borderColor {
    switch (state) {
      case AnswerTileState.correct: return AppColors.success;
      case AnswerTileState.wrong: return AppColors.error;
      case AnswerTileState.hinting: return AppColors.warning;
      case AnswerTileState.normal: return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor, width: state == AnswerTileState.hinting ? 4 : 3),
          boxShadow: state == AnswerTileState.hinting ? [BoxShadow(color: AppColors.warning.withValues(alpha: 0.5), blurRadius: 15)] : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: state == AnswerTileState.correct || state == AnswerTileState.wrong ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
