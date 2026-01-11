import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/settings_service.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Music symbol data
class MusicSymbol {
  final String id;
  final String name;
  final String description;
  final Color color;

  const MusicSymbol({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });
}

/// Music Symbols Game - Learn music notation symbols
class MusicNotesGame extends StatefulWidget {
  const MusicNotesGame({super.key});

  @override
  State<MusicNotesGame> createState() => _MusicNotesGameState();
}

class _MusicNotesGameState extends State<MusicNotesGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 8;
  int _score = 0;
  MusicSymbol? _targetSymbol;
  List<MusicSymbol> _choices = [];
  bool _showHint = false;
  MusicSymbol? _wrongTapped;
  bool _showSuccess = false;
  bool _isWaiting = false;
  Timer? _hintTimer;

  // Music symbols to learn - using reliable Unicode and text
  final List<MusicSymbol> _symbols = const [
    MusicSymbol(
      id: 'quarter',
      name: 'Quarter Note',
      description: 'One beat',
      color: Color(0xFF1CB0F6),
    ),
    MusicSymbol(
      id: 'half',
      name: 'Half Note',
      description: 'Two beats',
      color: Color(0xFF58CC02),
    ),
    MusicSymbol(
      id: 'whole',
      name: 'Whole Note',
      description: 'Four beats',
      color: Color(0xFFFF9600),
    ),
    MusicSymbol(
      id: 'forte',
      name: 'Forte',
      description: 'Play loud',
      color: Color(0xFFFF4B4B),
    ),
    MusicSymbol(
      id: 'piano',
      name: 'Piano',
      description: 'Play soft',
      color: Color(0xFFCE82FF),
    ),
    MusicSymbol(
      id: 'treble',
      name: 'Treble Clef',
      description: 'High notes',
      color: Color(0xFF4A90D9),
    ),
    MusicSymbol(
      id: 'sharp',
      name: 'Sharp',
      description: 'Raise the note',
      color: Color(0xFFFFD93D),
    ),
    MusicSymbol(
      id: 'flat',
      name: 'Flat',
      description: 'Lower the note',
      color: Color(0xFFF472B6),
    ),
  ];

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
      _showHint = false;
      _wrongTapped = null;
      _showSuccess = false;
      _isWaiting = false;
    });

    // Pick target symbol (cycle through all symbols)
    _targetSymbol = _symbols[(_round - 1) % _symbols.length];

    // Pick 4 random symbols including target
    Set<MusicSymbol> symbolSet = {_targetSymbol!};
    while (symbolSet.length < 4) {
      symbolSet.add(_symbols[_random.nextInt(_symbols.length)]);
    }
    _choices = symbolSet.toList()..shuffle();

    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), () {
      _speakPrompt();
      if (SettingsService.hintsEnabled) {
        _startHintTimer();
      }
    });
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 7), () {
      if (mounted && !_isWaiting) {
        setState(() => _showHint = true);
        AudioHelper.speak("Look for ${_targetSymbol!.name}");
      }
    });
  }

  Future<void> _speakPrompt() async {
    await AudioHelper.speak("Find the ${_targetSymbol!.name}. It means ${_targetSymbol!.description}.");
  }

  void _onSymbolTap(MusicSymbol symbol) {
    if (_isWaiting) return;
    _hintTimer?.cancel();

    if (symbol == _targetSymbol) {
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
      setState(() => _wrongTapped = symbol);
      AudioHelper.speakTryAgain();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _wrongTapped = null);
          if (SettingsService.hintsEnabled) {
            _startHintTimer();
          }
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
    if (_targetSymbol == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
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
                // Prompt
                Text(
                  'Find the symbol:',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // Target symbol card
                GestureDetector(
                  onTap: () {
                    HapticHelper.lightTap();
                    _speakPrompt();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    decoration: BoxDecoration(
                      color: _targetSymbol!.color,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _targetSymbol!.color.withValues(alpha: 0.3),
                          offset: const Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              _targetSymbol!.name,
                              style: GoogleFonts.nunito(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _targetSymbol!.description,
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Symbol choices
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: _choices.map((symbol) {
                          final isCorrect = _showSuccess && symbol == _targetSymbol;
                          final isWrong = symbol == _wrongTapped;
                          final isHinting = _showHint && symbol == _targetSymbol;

                          return _SymbolTile(
                            symbol: symbol,
                            isCorrect: isCorrect,
                            isWrong: isWrong,
                            isHinting: isHinting,
                            onTap: () => _onSymbolTap(symbol),
                          );
                        }).toList(),
                      ),
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
            'Music Symbols',
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // Progress
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
          // Score
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

/// Symbol tile widget with 3D effect
class _SymbolTile extends StatefulWidget {
  final MusicSymbol symbol;
  final bool isCorrect;
  final bool isWrong;
  final bool isHinting;
  final VoidCallback onTap;

  const _SymbolTile({
    required this.symbol,
    required this.isCorrect,
    required this.isWrong,
    required this.isHinting,
    required this.onTap,
  });

  @override
  State<_SymbolTile> createState() => _SymbolTileState();
}

class _SymbolTileState extends State<_SymbolTile> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_SymbolTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHinting && !oldWidget.isHinting) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isHinting && oldWidget.isHinting) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildSymbolVisual() {
    switch (widget.symbol.id) {
      case 'quarter':
        // Quarter note - filled oval with stem
        return CustomPaint(
          size: const Size(60, 80),
          painter: _QuarterNotePainter(),
        );
      case 'half':
        // Half note - hollow oval with stem
        return CustomPaint(
          size: const Size(60, 80),
          painter: _HalfNotePainter(),
        );
      case 'whole':
        // Whole note - hollow oval, no stem
        return CustomPaint(
          size: const Size(60, 50),
          painter: _WholeNotePainter(),
        );
      case 'forte':
        return Text(
          'f',
          style: GoogleFonts.notoSerif(
            fontSize: 72,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        );
      case 'piano':
        return Text(
          'p',
          style: GoogleFonts.notoSerif(
            fontSize: 72,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        );
      case 'treble':
        return const Text(
          '𝄞',
          style: TextStyle(fontSize: 72, color: Colors.white),
        );
      case 'sharp':
        return const Text(
          '♯',
          style: TextStyle(fontSize: 72, color: Colors.white),
        );
      case 'flat':
        return const Text(
          '♭',
          style: TextStyle(fontSize: 72, color: Colors.white),
        );
      default:
        return const Icon(Icons.music_note, size: 60, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.symbol.color;
    Color shadeColor = HSLColor.fromColor(bgColor).withLightness(
      (HSLColor.fromColor(bgColor).lightness - 0.15).clamp(0.0, 1.0),
    ).toColor();

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
      child: ScaleTransition(
        scale: widget.isHinting ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
        child: SizedBox(
          width: 160,
          height: 180,
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
                top: _isPressed ? 6 : 0,
                bottom: _isPressed ? 0 : 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(24),
                    border: widget.isHinting
                        ? Border.all(color: Colors.white, width: 4)
                        : null,
                  ),
                  child: Center(child: _buildSymbolVisual()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for quarter note (filled note head with stem)
class _QuarterNotePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Note head (filled oval, slightly tilted)
    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.7);
    canvas.rotate(-0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 28, height: 22),
      paint,
    );
    canvas.restore();

    // Stem
    paint.strokeWidth = 4;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width / 2 + 12, size.height * 0.68),
      Offset(size.width / 2 + 12, size.height * 0.15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for half note (hollow note head with stem)
class _HalfNotePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Note head (hollow oval, slightly tilted)
    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.7);
    canvas.rotate(-0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 28, height: 22),
      paint,
    );
    canvas.restore();

    // Stem
    paint.strokeWidth = 4;
    canvas.drawLine(
      Offset(size.width / 2 + 12, size.height * 0.68),
      Offset(size.width / 2 + 12, size.height * 0.15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for whole note (hollow oval, no stem)
class _WholeNotePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Note head (hollow oval)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 40,
        height: 28,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
