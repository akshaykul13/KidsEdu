import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Color Sort Game - Drag colored toys into matching colored bins
class ColorSortGame extends StatefulWidget {
  const ColorSortGame({super.key});

  @override
  State<ColorSortGame> createState() => _ColorSortGameState();
}

class _ColorSortGameState extends State<ColorSortGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 5;
  int _score = 0;
  bool _isWaiting = false;
  List<_ColoredToy> _toys = [];
  List<_ColorBin> _bins = [];
  int _sortedCount = 0;
  int _totalToysToSort = 0;

  // Color definitions with kid-friendly names
  static const List<Map<String, dynamic>> _colors = [
    {'name': 'Red', 'color': Color(0xFFE74C3C), 'shade': Color(0xFFC0392B)},
    {'name': 'Blue', 'color': Color(0xFF3498DB), 'shade': Color(0xFF2980B9)},
    {'name': 'Green', 'color': Color(0xFF2ECC71), 'shade': Color(0xFF27AE60)},
    {'name': 'Yellow', 'color': Color(0xFFF1C40F), 'shade': Color(0xFFD4AC0D)},
    {'name': 'Purple', 'color': Color(0xFF9B59B6), 'shade': Color(0xFF8E44AD)},
    {'name': 'Orange', 'color': Color(0xFFE67E22), 'shade': Color(0xFFD35400)},
  ];

  // Toy emojis that can be colored
  static const List<String> _toyEmojis = [
    '🧸', '🎈', '⭐', '❤️', '🔵', '🟢', '🟡', '🟣', '🟠', '🔴',
    '🎀', '🎁', '🧩', '🎯', '🏀', '⚽', '🎾', '🧶', '🪀', '🎨',
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
    _confettiController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    if (_round >= _totalRounds) {
      _showGameComplete();
      return;
    }

    // Pick 3-4 colors for bins
    final shuffledColors = List<Map<String, dynamic>>.from(_colors)..shuffle(_random);
    final numBins = 3 + (_round ~/ 2).clamp(0, 1); // 3 bins for first 2 rounds, 4 for later
    final selectedColors = shuffledColors.take(numBins).toList();

    // Create bins
    _bins = selectedColors.map((colorData) => _ColorBin(
      name: colorData['name'],
      color: colorData['color'],
      shadeColor: colorData['shade'],
      toys: [],
    )).toList();

    // Create toys (2 toys per bin color)
    _toys = [];
    final toyEmojis = List<String>.from(_toyEmojis)..shuffle(_random);
    int toyIndex = 0;

    for (final colorData in selectedColors) {
      for (int i = 0; i < 2; i++) {
        _toys.add(_ColoredToy(
          id: _toys.length,
          emoji: toyEmojis[toyIndex % toyEmojis.length],
          colorName: colorData['name'],
          color: colorData['color'],
          isSorted: false,
        ));
        toyIndex++;
      }
    }

    // Shuffle toys
    _toys.shuffle(_random);
    _totalToysToSort = _toys.length;

    setState(() {
      _round++;
      _isWaiting = false;
      _sortedCount = 0;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      AudioHelper.speak("Sort the toys into the matching colored bins!");
    });
  }

  void _onToyDroppedOnBin(int toyId, int binIndex) {
    if (_isWaiting) return;

    final toyIndex = _toys.indexWhere((t) => t.id == toyId);
    if (toyIndex == -1) return;

    final toy = _toys[toyIndex];
    final bin = _bins[binIndex];

    if (toy.colorName == bin.name) {
      // Correct bin!
      HapticHelper.success();
      setState(() {
        _toys[toyIndex] = toy.copyWith(isSorted: true);
        _bins[binIndex] = bin.copyWith(
          toys: [...bin.toys, toy],
        );
        _sortedCount++;
      });

      if (_sortedCount >= _totalToysToSort) {
        // All toys sorted!
        _confettiController.play();
        AudioHelper.speakSuccess();
        setState(() {
          _score++;
          _isWaiting = true;
        });
        Future.delayed(const Duration(milliseconds: 1500), _startNewRound);
      } else {
        AudioHelper.speak("Good job!");
      }
    } else {
      // Wrong bin
      HapticHelper.error();
      AudioHelper.speak("Try the ${toy.colorName} bin!");
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
                const SizedBox(height: 16),
                // Instructions and progress
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.drag_indicator_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Drag toys to matching bins!',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_sortedCount/$_totalToysToSort',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Toys to sort
                Expanded(
                  flex: 2,
                  child: _buildToyArea(),
                ),
                const SizedBox(height: 16),
                // Color bins
                Expanded(
                  flex: 2,
                  child: _buildBinArea(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          CelebrationOverlay(controller: _confettiController),
        ],
      ),
    );
  }

  Widget _buildToyArea() {
    final unsortedToys = _toys.where((t) => !t.isSorted).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Toys',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: unsortedToys.map((toy) => _DraggableToy(
                  toy: toy,
                  onDragStarted: () => HapticHelper.lightTap(),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBinArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: _bins.asMap().entries.map((entry) {
          final index = entry.key;
          final bin = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == _bins.length - 1 ? 0 : 8,
              ),
              child: _ColorBinWidget(
                bin: bin,
                onToyDropped: (toyId) => _onToyDroppedOnBin(toyId, index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.attention,
        boxShadow: [
          BoxShadow(
            color: AppColors.attentionShade,
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
            'Color Sort',
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Round $_round/$_totalRounds',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  '$_score',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
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

/// Data class for colored toys
class _ColoredToy {
  final int id;
  final String emoji;
  final String colorName;
  final Color color;
  final bool isSorted;

  _ColoredToy({
    required this.id,
    required this.emoji,
    required this.colorName,
    required this.color,
    required this.isSorted,
  });

  _ColoredToy copyWith({bool? isSorted}) {
    return _ColoredToy(
      id: id,
      emoji: emoji,
      colorName: colorName,
      color: color,
      isSorted: isSorted ?? this.isSorted,
    );
  }
}

/// Data class for color bins
class _ColorBin {
  final String name;
  final Color color;
  final Color shadeColor;
  final List<_ColoredToy> toys;

  _ColorBin({
    required this.name,
    required this.color,
    required this.shadeColor,
    required this.toys,
  });

  _ColorBin copyWith({List<_ColoredToy>? toys}) {
    return _ColorBin(
      name: name,
      color: color,
      shadeColor: shadeColor,
      toys: toys ?? this.toys,
    );
  }
}

/// Draggable toy widget
class _DraggableToy extends StatelessWidget {
  final _ColoredToy toy;
  final VoidCallback onDragStarted;

  const _DraggableToy({
    required this.toy,
    required this.onDragStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      data: toy.id,
      onDragStarted: onDragStarted,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.2,
          child: _buildToyContent(isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildToyContent(),
      ),
      child: _buildToyContent(),
    );
  }

  Widget _buildToyContent({bool isDragging = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: toy.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDragging
                ? toy.color.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: isDragging ? 12 : 4,
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          toy.emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}

/// Color bin widget with drag target
class _ColorBinWidget extends StatefulWidget {
  final _ColorBin bin;
  final Function(int) onToyDropped;

  const _ColorBinWidget({
    required this.bin,
    required this.onToyDropped,
  });

  @override
  State<_ColorBinWidget> createState() => _ColorBinWidgetState();
}

class _ColorBinWidgetState extends State<_ColorBinWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        setState(() => _isHovering = true);
        return true;
      },
      onLeave: (_) {
        setState(() => _isHovering = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _isHovering = false);
        widget.onToyDropped(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovering
                ? widget.bin.color.withValues(alpha: 0.3)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.bin.color,
              width: _isHovering ? 4 : 3,
            ),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: widget.bin.color.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              // Bin label
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: widget.bin.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                  ),
                ),
                child: Text(
                  widget.bin.name,
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Bin content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: widget.bin.toys.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.inbox_rounded,
                            size: 48,
                            color: widget.bin.color.withValues(alpha: 0.3),
                          ),
                        )
                      : Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: widget.bin.toys.map((toy) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: toy.color.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                toy.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          )).toList(),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
