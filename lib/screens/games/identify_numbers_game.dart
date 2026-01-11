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

/// Identify Numbers Game - Find the correct number
class IdentifyNumbersGame extends StatefulWidget {
  const IdentifyNumbersGame({super.key});

  @override
  State<IdentifyNumbersGame> createState() => _IdentifyNumbersGameState();
}

class _IdentifyNumbersGameState extends State<IdentifyNumbersGame> {
  final Random _random = Random();
  late ConfettiController _confettiController;

  int _targetNumber = 0;
  List<int> _displayedNumbers = [];
  int _score = 0;
  int _round = 0;
  final int _totalRounds = 10;
  bool _isWaiting = false;
  int? _wrongTappedNumber;
  bool _showSuccess = false;
  bool _showHint = false;
  Timer? _hintTimer;

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
    _hintTimer = Timer(const Duration(seconds: 7), () {
      if (mounted && !_isWaiting) {
        setState(() => _showHint = true);
        AudioHelper.speak("Look for the number $_targetNumber");
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
      _wrongTappedNumber = null;
      _showSuccess = false;
      _showHint = false;
      _isWaiting = false;
    });

    // Pick random target number 1-20
    _targetNumber = _random.nextInt(20) + 1;

    // Create display numbers: include target + 5 random others
    Set<int> numberSet = {_targetNumber};
    while (numberSet.length < 6) {
      numberSet.add(_random.nextInt(20) + 1);
    }
    _displayedNumbers = numberSet.toList()..shuffle();

    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), () {
      _speakPrompt();
      if (SettingsService.hintsEnabled) {
        _startHintTimer();
      }
    });
  }

  Future<void> _speakPrompt() async {
    await AudioHelper.speak('Find the number $_targetNumber');
  }

  void _onNumberTap(int number) {
    if (_isWaiting) return;

    _hintTimer?.cancel();

    if (number == _targetNumber) {
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
        _wrongTappedNumber = number;
        _showHint = false;
      });
      AudioHelper.speakTryAgain();

      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _wrongTappedNumber = null);
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

  AnswerTileState _getTileState(int number) {
    if (_showSuccess && number == _targetNumber) return AnswerTileState.correct;
    if (number == _wrongTappedNumber) return AnswerTileState.wrong;
    if (_showHint && number == _targetNumber) return AnswerTileState.hinting;
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Text(
                        'Find the number',
                        style: TextStyle(fontSize: 32, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          HapticHelper.lightTap();
                          _speakPrompt();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.accent2,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.volume_up_rounded, color: Colors.white, size: 40),
                              const SizedBox(width: 20),
                              Text(
                                '$_targetNumber',
                                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Wrap(
                        spacing: 28,
                        runSpacing: 28,
                        alignment: WrapAlignment.center,
                        children: _displayedNumbers.map((number) {
                          return AnswerTile(
                            text: '$number',
                            state: _getTileState(number),
                            onTap: () => _onNumberTap(number),
                            size: 150,
                            fontSize: 72,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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
          const Text('Find the Number', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
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
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text('$_score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
