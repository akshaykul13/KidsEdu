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

enum FlagsGameMode { learn, quiz }

/// Country Flags Game - Learn world flags with high-quality SVG flags
class FlagsGame extends StatefulWidget {
  const FlagsGame({super.key});

  @override
  State<FlagsGame> createState() => _FlagsGameState();
}

class _FlagsGameState extends State<FlagsGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  FlagsGameMode _mode = FlagsGameMode.learn;

  // Quiz mode state
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
    // Start in Learn mode by default - no need to initialize quiz
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _switchMode(FlagsGameMode mode) {
    if (mode == _mode) return;
    HapticHelper.lightTap();
    setState(() {
      _mode = mode;
      if (mode == FlagsGameMode.quiz) {
        // Reset quiz state when switching to quiz
        _score = 0;
        _round = 0;
        _startNewRound();
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
                const SizedBox(height: 16),
                _buildModeToggle(),
                const SizedBox(height: 16),
                Expanded(
                  child: _mode == FlagsGameMode.learn
                      ? _buildLearnMode()
                      : _buildQuizMode(),
                ),
              ],
            ),
          ),
          CelebrationOverlay(controller: _confettiController),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral, width: 3),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Learn',
              icon: Icons.school_rounded,
              isSelected: _mode == FlagsGameMode.learn,
              onTap: () => _switchMode(FlagsGameMode.learn),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Quiz',
              icon: Icons.quiz_rounded,
              isSelected: _mode == FlagsGameMode.quiz,
              onTap: () => _switchMode(FlagsGameMode.quiz),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnMode() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: CountryData.all.length,
      itemBuilder: (context, index) {
        final country = CountryData.all[index];
        return _LearnFlagCard(
          country: country,
          onTap: () {
            HapticHelper.lightTap();
            AudioHelper.speak(country.name);
          },
        );
      },
    );
  }

  Widget _buildQuizMode() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          // Compact header
          Text(
            'Find the flag of:',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () { HapticHelper.lightTap(); _speakPrompt(); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryShade,
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.volume_up_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    _targetCountry?.name ?? '',
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
          const SizedBox(height: 12),
          // 2x2 Grid that fills remaining space
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildQuizFlagCard(0)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuizFlagCard(1)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildQuizFlagCard(2)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuizFlagCard(3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizFlagCard(int index) {
    if (index >= _displayedFlags.length) return const SizedBox();
    final country = _displayedFlags[index];
    final isCorrect = _showSuccess && country.code == _targetCountry?.code;
    final isWrong = country.code == _wrongTapped;

    return _FlagCard(
      country: country,
      isCorrect: isCorrect,
      isWrong: isWrong,
      onTap: () => _onFlagTap(country),
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
          if (_mode == FlagsGameMode.quiz) ...[
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
        ],
      ),
    );
  }
}

/// Mode toggle button
class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Learn mode flag card with country name
class _LearnFlagCard extends StatefulWidget {
  final CountryData country;
  final VoidCallback onTap;

  const _LearnFlagCard({
    required this.country,
    required this.onTap,
  });

  @override
  State<_LearnFlagCard> createState() => _LearnFlagCardState();
}

class _LearnFlagCardState extends State<_LearnFlagCard> {
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
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE9ECEF),
                      width: 1,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final flagSize = (constraints.maxWidth * 0.75).clamp(50.0, 120.0);
                      return Center(
                        child: FlagWidget(
                          countryCode: widget.country.code,
                          size: flagSize,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        widget.country.name,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFDEE2E6);

    if (widget.isCorrect) {
      bgColor = AppColors.success.withValues(alpha: 0.15);
      borderColor = AppColors.success;
    } else if (widget.isWrong) {
      bgColor = AppColors.error.withValues(alpha: 0.15);
      borderColor = AppColors.error;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE9ECEF),
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final flagSize = (constraints.maxWidth * 0.7).clamp(60.0, 180.0);
                return Center(
                  child: FlagWidget(
                    countryCode: widget.country.code,
                    size: flagSize,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
