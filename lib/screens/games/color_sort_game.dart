import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Color Sort Game - Drag colored toys into matching colored baskets
class ColorSortGame extends StatefulWidget {
  const ColorSortGame({super.key});

  @override
  State<ColorSortGame> createState() => _ColorSortGameState();
}

class _ColorSortGameState extends State<ColorSortGame> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _bounceController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 5;
  int _score = 0;
  bool _isWaiting = false;
  List<_ColoredToy> _toys = [];
  List<_ColorBasket> _baskets = [];
  int _sortedCount = 0;
  int _totalToysToSort = 0;

  // Twemoji CDN base URL for high quality emoji images
  static const String _twemojiBase = 'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/';

  // Color definitions with matching emoji toys
  static const List<Map<String, dynamic>> _colors = [
    {
      'name': 'Red',
      'color': Color(0xFFE74C3C),
      'shade': Color(0xFFC0392B),
      'light': Color(0xFFF5B7B1),
      'toys': [
        {'emoji': '❤️', 'code': '2764', 'name': 'heart'},
        {'emoji': '🔴', 'code': '1f534', 'name': 'circle'},
        {'emoji': '🍎', 'code': '1f34e', 'name': 'apple'},
      ],
    },
    {
      'name': 'Blue',
      'color': Color(0xFF3498DB),
      'shade': Color(0xFF2980B9),
      'light': Color(0xFFAED6F1),
      'toys': [
        {'emoji': '💙', 'code': '1f499', 'name': 'heart'},
        {'emoji': '🔵', 'code': '1f535', 'name': 'circle'},
        {'emoji': '🐳', 'code': '1f433', 'name': 'whale'},
      ],
    },
    {
      'name': 'Green',
      'color': Color(0xFF2ECC71),
      'shade': Color(0xFF27AE60),
      'light': Color(0xFFA9DFBF),
      'toys': [
        {'emoji': '💚', 'code': '1f49a', 'name': 'heart'},
        {'emoji': '🟢', 'code': '1f7e2', 'name': 'circle'},
        {'emoji': '🐸', 'code': '1f438', 'name': 'frog'},
      ],
    },
    {
      'name': 'Yellow',
      'color': Color(0xFFF1C40F),
      'shade': Color(0xFFD4AC0D),
      'light': Color(0xFFF9E79F),
      'toys': [
        {'emoji': '💛', 'code': '1f49b', 'name': 'heart'},
        {'emoji': '🟡', 'code': '1f7e1', 'name': 'circle'},
        {'emoji': '⭐', 'code': '2b50', 'name': 'star'},
      ],
    },
    {
      'name': 'Purple',
      'color': Color(0xFF9B59B6),
      'shade': Color(0xFF8E44AD),
      'light': Color(0xFFD7BDE2),
      'toys': [
        {'emoji': '💜', 'code': '1f49c', 'name': 'heart'},
        {'emoji': '🟣', 'code': '1f7e3', 'name': 'circle'},
        {'emoji': '🍇', 'code': '1f347', 'name': 'grapes'},
      ],
    },
    {
      'name': 'Orange',
      'color': Color(0xFFE67E22),
      'shade': Color(0xFFD35400),
      'light': Color(0xFFF5CBA7),
      'toys': [
        {'emoji': '🧡', 'code': '1f9e1', 'name': 'heart'},
        {'emoji': '🟠', 'code': '1f7e0', 'name': 'circle'},
        {'emoji': '🍊', 'code': '1f34a', 'name': 'orange'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    AudioHelper.init();
    _startNewRound();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    if (_round >= _totalRounds) {
      _showGameComplete();
      return;
    }

    // Pick 3 colors for baskets (fewer baskets = bigger baskets)
    final shuffledColors = List<Map<String, dynamic>>.from(_colors)..shuffle(_random);
    final selectedColors = shuffledColors.take(3).toList();

    // Create baskets
    _baskets = selectedColors.map((colorData) => _ColorBasket(
      name: colorData['name'],
      color: colorData['color'],
      shadeColor: colorData['shade'],
      lightColor: colorData['light'],
      toys: [],
    )).toList();

    // Create toys (2 toys per basket color)
    _toys = [];
    for (final colorData in selectedColors) {
      final toyOptions = List<Map<String, dynamic>>.from(colorData['toys'])..shuffle(_random);
      for (int i = 0; i < 2; i++) {
        final toyData = toyOptions[i % toyOptions.length];
        _toys.add(_ColoredToy(
          id: _toys.length,
          emoji: toyData['emoji'],
          emojiCode: toyData['code'],
          toyName: toyData['name'],
          colorName: colorData['name'],
          color: colorData['color'],
          isSorted: false,
        ));
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
      AudioHelper.speak("Sort by color!");
    });
  }

  void _onToyDroppedOnBasket(int toyId, int basketIndex) {
    if (_isWaiting) return;

    final toyIndex = _toys.indexWhere((t) => t.id == toyId);
    if (toyIndex == -1) return;

    final toy = _toys[toyIndex];
    final basket = _baskets[basketIndex];

    if (toy.colorName == basket.name) {
      // Correct basket!
      HapticHelper.success();
      setState(() {
        _toys[toyIndex] = toy.copyWith(isSorted: true);
        _baskets[basketIndex] = basket.copyWith(
          toys: [...basket.toys, toy],
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
        AudioHelper.speak("Yes!");
      }
    } else {
      // Wrong basket
      HapticHelper.error();
      AudioHelper.speak("Try ${toy.colorName}!");
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA), // Light cyan
              Color(0xFFB2EBF2),
              Color(0xFF80DEEA),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: 80,
              left: 20,
              child: _FloatingDecoration(emoji: '🌈', size: 60),
            ),
            Positioned(
              top: 120,
              right: 30,
              child: _FloatingDecoration(emoji: '☁️', size: 50),
            ),
            Positioned(
              bottom: 100,
              left: 40,
              child: _FloatingDecoration(emoji: '🎨', size: 45),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 16),
                  // Instructions
                  _buildInstructions(),
                  const SizedBox(height: 20),
                  // Toys area - BIG toys to drag
                  Expanded(
                    flex: 4,
                    child: _buildToyArea(),
                  ),
                  // Baskets area - BIG baskets to drop into
                  Expanded(
                    flex: 5,
                    child: _buildBasketArea(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            CelebrationOverlay(controller: _confettiController),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👆', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Text(
            'Drag to matching color!',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$_sortedCount / $_totalToysToSort',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToyArea() {
    final unsortedToys = _toys.where((t) => !t.isSorted).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Wrap(
          spacing: 24,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: unsortedToys.map((toy) => _DraggableToyWidget(
            toy: toy,
            bounceController: _bounceController,
            onDragStarted: () => HapticHelper.lightTap(),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildBasketArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _baskets.asMap().entries.map((entry) {
          final index = entry.key;
          final basket = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == _baskets.length - 1 ? 0 : 8,
              ),
              child: _BasketWidget(
                basket: basket,
                onToyDropped: (toyId) => _onToyDroppedOnBasket(toyId, index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          const SizedBox(width: 16),
          Text(
            '🎨 Color Sort',
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
          const SizedBox(width: 12),
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

/// Floating background decoration
class _FloatingDecoration extends StatelessWidget {
  final String emoji;
  final double size;

  const _FloatingDecoration({required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: TextStyle(fontSize: size),
    );
  }
}

/// Data class for colored toys
class _ColoredToy {
  final int id;
  final String emoji;
  final String emojiCode;
  final String toyName;
  final String colorName;
  final Color color;
  final bool isSorted;

  _ColoredToy({
    required this.id,
    required this.emoji,
    required this.emojiCode,
    required this.toyName,
    required this.colorName,
    required this.color,
    required this.isSorted,
  });

  String get imageUrl => 'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/$emojiCode.png';

  _ColoredToy copyWith({bool? isSorted}) {
    return _ColoredToy(
      id: id,
      emoji: emoji,
      emojiCode: emojiCode,
      toyName: toyName,
      colorName: colorName,
      color: color,
      isSorted: isSorted ?? this.isSorted,
    );
  }
}

/// Data class for color baskets
class _ColorBasket {
  final String name;
  final Color color;
  final Color shadeColor;
  final Color lightColor;
  final List<_ColoredToy> toys;

  _ColorBasket({
    required this.name,
    required this.color,
    required this.shadeColor,
    required this.lightColor,
    required this.toys,
  });

  _ColorBasket copyWith({List<_ColoredToy>? toys}) {
    return _ColorBasket(
      name: name,
      color: color,
      shadeColor: shadeColor,
      lightColor: lightColor,
      toys: toys ?? this.toys,
    );
  }
}

/// Draggable toy widget with network image
class _DraggableToyWidget extends StatelessWidget {
  final _ColoredToy toy;
  final AnimationController bounceController;
  final VoidCallback onDragStarted;

  const _DraggableToyWidget({
    required this.toy,
    required this.bounceController,
    required this.onDragStarted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bounceController,
      builder: (context, child) {
        final phase = (toy.id * 0.4) % 1.0;
        final bounceValue = sin((bounceController.value + phase) * 2 * pi);
        final translateY = bounceValue * 6;
        final scale = 1.0 + bounceValue * 0.05;

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            child: Draggable<int>(
              data: toy.id,
              onDragStarted: onDragStarted,
              feedback: Material(
                color: Colors.transparent,
                child: _ToyImage(toy: toy, size: 120, isDragging: true),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _ToyImage(toy: toy, size: 100),
              ),
              child: _ToyImage(toy: toy, size: 100),
            ),
          ),
        );
      },
    );
  }
}

/// Toy image widget using network image with fallback
class _ToyImage extends StatelessWidget {
  final _ColoredToy toy;
  final double size;
  final bool isDragging;

  const _ToyImage({
    required this.toy,
    required this.size,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: toy.color,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: isDragging
                ? toy.color.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, 6),
            blurRadius: isDragging ? 16 : 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: CachedNetworkImage(
            imageUrl: toy.imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => Center(
              child: Text(toy.emoji, style: TextStyle(fontSize: size * 0.5)),
            ),
            errorWidget: (context, url, error) => Center(
              child: Text(toy.emoji, style: TextStyle(fontSize: size * 0.5)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Basket widget with drag target
class _BasketWidget extends StatefulWidget {
  final _ColorBasket basket;
  final Function(int) onToyDropped;

  const _BasketWidget({
    required this.basket,
    required this.onToyDropped,
  });

  @override
  State<_BasketWidget> createState() => _BasketWidgetState();
}

class _BasketWidgetState extends State<_BasketWidget> {
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
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isHovering ? 1.05 : 1.0),
          transformAlignment: Alignment.center,
          child: Column(
            children: [
              // Color label at top
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.basket.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.basket.shadeColor,
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  widget.basket.name,
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Basket body
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.basket.lightColor,
                        widget.basket.color.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isHovering ? widget.basket.color : widget.basket.color.withValues(alpha: 0.5),
                      width: _isHovering ? 5 : 3,
                    ),
                    boxShadow: _isHovering
                        ? [
                            BoxShadow(
                              color: widget.basket.color.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                  ),
                  child: widget.basket.toys.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_downward_rounded,
                                size: 48,
                                color: widget.basket.color.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Drop here!',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: widget.basket.color.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: widget.basket.toys.map((toy) => _SmallToyImage(toy: toy)).toList(),
                          ),
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

/// Small toy image for inside baskets - BIGGER than before
class _SmallToyImage extends StatelessWidget {
  final _ColoredToy toy;

  const _SmallToyImage({required this.toy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: toy.color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: CachedNetworkImage(
            imageUrl: toy.imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => Center(
              child: Text(toy.emoji, style: const TextStyle(fontSize: 32)),
            ),
            errorWidget: (context, url, error) => Center(
              child: Text(toy.emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
        ),
      ),
    );
  }
}
