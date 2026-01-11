import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/flag_widget.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Country Flags Game - Learn world flags with high-quality SVG flags
class FlagsGame extends StatefulWidget {
  const FlagsGame({super.key});

  @override
  State<FlagsGame> createState() => _FlagsGameState();
}

class _FlagsGameState extends State<FlagsGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 10;
  int _score = 0;
  CountryData? _targetCountry;
  List<CountryData> _displayedFlags = [];
  String? _wrongTapped;
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

    // Pick random target
    _targetCountry = CountryData.all[_random.nextInt(CountryData.all.length)];

    // Pick 4 random flags including target
    Set<CountryData> flagSet = {_targetCountry!};
    while (flagSet.length < 4) {
      flagSet.add(CountryData.all[_random.nextInt(CountryData.all.length)]);
    }
    _displayedFlags = flagSet.toList()..shuffle();

    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), () {
      _speakPrompt();
    });
  }

  Future<void> _speakPrompt() async {
    await AudioHelper.speak("Find the flag of ${_targetCountry?.name}");
  }

  void _onFlagTap(CountryData country) {
    if (_isWaiting) return;

    if (country.code == _targetCountry?.code) {
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
      setState(() => _wrongTapped = country.code);
      AudioHelper.speakTryAgain();
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _wrongTapped = null);
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
                const SizedBox(height: 24),
                Text(
                  'Find the flag of:',
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () { HapticHelper.lightTap(); _speakPrompt(); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(28),
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
                        const Icon(Icons.volume_up_rounded, color: Colors.white, size: 36),
                        const SizedBox(width: 16),
                        Text(
                          _targetCountry?.name ?? '',
                          style: GoogleFonts.nunito(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: _displayedFlags.map((country) {
                        final isCorrect = _showSuccess && country.code == _targetCountry?.code;
                        final isWrong = country.code == _wrongTapped;

                        return _FlagCard(
                          country: country,
                          isCorrect: isCorrect,
                          isWrong: isWrong,
                          onTap: () => _onFlagTap(country),
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
            'Country Flags',
            style: GoogleFonts.nunito(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Round $_round/$_totalRounds',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.attention,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  '$_score',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
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

/// Flag card with 3D effect and SVG flag
class _FlagCard extends StatefulWidget {
  final CountryData country;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _FlagCard({
    required this.country,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  State<_FlagCard> createState() => _FlagCardState();
}

class _FlagCardState extends State<_FlagCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.surface;
    Color borderColor = AppColors.neutral;
    Color shadeColor = AppColors.neutralShade;

    if (widget.isCorrect) {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      borderColor = AppColors.success;
      shadeColor = AppColors.successShade;
    } else if (widget.isWrong) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      borderColor = AppColors.error;
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
        width: 220,
        height: 170,
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
                  borderRadius: BorderRadius.circular(24),
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
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: FlagWidget(
                        countryCode: widget.country.code,
                        size: 90,
                      ),
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
