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

/// Big to Small Game - Arrange items from smallest to largest
class BigToSmallGame extends StatefulWidget {
  const BigToSmallGame({super.key});

  @override
  State<BigToSmallGame> createState() => _BigToSmallGameState();
}

class _BigToSmallGameState extends State<BigToSmallGame> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _bounceController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 5;
  int _score = 0;
  bool _isWaiting = false;
  List<_SizedItem> _items = [];
  List<_SizedItem?> _slots = [];
  bool _sortSmallestFirst = true;
  Timer? _hintTimer;
  int? _hintSlotIndex;

  // Item themes with Twemoji codes for network images
  static const List<Map<String, dynamic>> _itemThemes = [
    {'emoji': '🐻', 'code': '1f43b', 'name': 'bears', 'color': Color(0xFF795548)},
    {'emoji': '⭐', 'code': '2b50', 'name': 'stars', 'color': Color(0xFFFFD700)},
    {'emoji': '❤️', 'code': '2764', 'name': 'hearts', 'color': Color(0xFFE91E63)},
    {'emoji': '🌸', 'code': '1f338', 'name': 'flowers', 'color': Color(0xFFFF69B4)},
    {'emoji': '🐟', 'code': '1f41f', 'name': 'fish', 'color': Color(0xFF4FC3F7)},
    {'emoji': '🦋', 'code': '1f98b', 'name': 'butterflies', 'color': Color(0xFF9B59B6)},
    {'emoji': '🐢', 'code': '1f422', 'name': 'turtles', 'color': Color(0xFF27AE60)},
    {'emoji': '🌙', 'code': '1f319', 'name': 'moons', 'color': Color(0xFF5C6BC0)},
    {'emoji': '☀️', 'code': '2600', 'name': 'suns', 'color': Color(0xFFFF9800)},
    {'emoji': '🐱', 'code': '1f431', 'name': 'cats', 'color': Color(0xFFFF9800)},
    {'emoji': '🐶', 'code': '1f436', 'name': 'dogs', 'color': Color(0xFF8D6E63)},
    {'emoji': '🐰', 'code': '1f430', 'name': 'rabbits', 'color': Color(0xFFE91E63)},
    {'emoji': '🦉', 'code': '1f989', 'name': 'owls', 'color': Color(0xFF9C27B0)},
    {'emoji': '🐧', 'code': '1f427', 'name': 'penguins', 'color': Color(0xFF37474F)},
    {'emoji': '🐦', 'code': '1f426', 'name': 'birds', 'color': Color(0xFF2196F3)},
    {'emoji': '🐘', 'code': '1f418', 'name': 'elephants', 'color': Color(0xFF78909C)},
    {'emoji': '🦁', 'code': '1f981', 'name': 'lions', 'color': Color(0xFFFFC107)},
    {'emoji': '🍎', 'code': '1f34e', 'name': 'apples', 'color': Color(0xFFE74C3C)},
    {'emoji': '🎈', 'code': '1f388', 'name': 'balloons', 'color': Color(0xFFE74C3C)},
    {'emoji': '🚗', 'code': '1f697', 'name': 'cars', 'color': Color(0xFFE74C3C)},
  ];

  // Sizes from smallest to largest - adjusted for bigger display
  static const List<double> _sizes = [0.55, 0.7, 0.85, 1.0, 1.15];
  static const List<String> _sizeLabels = ['Tiny', 'Small', 'Medium', 'Big', 'Huge'];

  Map<String, dynamic>? _currentTheme;

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
    _hintTimer?.cancel();
    _confettiController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    if (_round >= _totalRounds) {
      _showGameComplete();
      return;
    }

    _hintTimer?.cancel();

    // Pick a random theme
    _currentTheme = _itemThemes[_random.nextInt(_itemThemes.length)];

    // Alternate between smallest-first and largest-first
    _sortSmallestFirst = _round % 2 == 0;

    // Create 5 items with different sizes
    _items = [];
    for (int i = 0; i < 5; i++) {
      _items.add(_SizedItem(
        id: i,
        emoji: _currentTheme!['emoji'],
        emojiCode: _currentTheme!['code'],
        size: _sizes[i],
        sizeLabel: _sizeLabels[i],
        correctPosition: _sortSmallestFirst ? i : (4 - i),
      ));
    }

    // Shuffle items
    _items.shuffle(_random);

    // Create empty slots
    _slots = List.filled(5, null);

    setState(() {
      _round++;
      _isWaiting = false;
      _hintSlotIndex = null;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      final orderText = _sortSmallestFirst ? 'smallest to biggest' : 'biggest to smallest';
      AudioHelper.speak("Order the ${_currentTheme!['name']} from $orderText!");
      _startHintTimer();
    });
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && !_isWaiting) {
        final firstEmptySlot = _slots.indexWhere((s) => s == null);
        if (firstEmptySlot != -1) {
          setState(() => _hintSlotIndex = firstEmptySlot);
          AudioHelper.speak("Try here!");
        }
      }
    });
  }

  void _onItemDroppedOnSlot(int itemId, int slotIndex) {
    if (_isWaiting) return;
    if (_slots[slotIndex] != null) return;

    final itemIndex = _items.indexWhere((i) => i.id == itemId && !_isItemPlaced(i));
    if (itemIndex == -1) return;

    final item = _items[itemIndex];

    if (item.correctPosition == slotIndex) {
      HapticHelper.success();
      setState(() {
        _slots[slotIndex] = item;
        _hintSlotIndex = null;
      });

      if (_slots.every((s) => s != null)) {
        _hintTimer?.cancel();
        _confettiController.play();
        AudioHelper.speakSuccess();
        setState(() {
          _score++;
          _isWaiting = true;
        });
        Future.delayed(const Duration(milliseconds: 1500), _startNewRound);
      } else {
        AudioHelper.speak("Good!");
        _startHintTimer();
      }
    } else {
      HapticHelper.error();
      AudioHelper.speak("Think about size!");
    }
  }

  bool _isItemPlaced(_SizedItem item) {
    return _slots.any((s) => s?.id == item.id);
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
    final themeColor = _currentTheme?['color'] as Color? ?? AppColors.primary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeColor.withValues(alpha: 0.15),
              themeColor.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: 100,
              left: 30,
              child: Text('📏', style: TextStyle(fontSize: 50, color: Colors.black.withValues(alpha: 0.1))),
            ),
            Positioned(
              top: 150,
              right: 40,
              child: Text('📐', style: TextStyle(fontSize: 45, color: Colors.black.withValues(alpha: 0.1))),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 16),
                  // Instructions
                  _buildInstructions(),
                  const SizedBox(height: 20),
                  // Slots area
                  Expanded(
                    flex: 4,
                    child: _buildSlotsArea(),
                  ),
                  const SizedBox(height: 16),
                  // Items to drag
                  Expanded(
                    flex: 4,
                    child: _buildItemsArea(),
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
    final themeColor = _currentTheme?['color'] as Color? ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _sortSmallestFirst ? '🐜' : '🐘',
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _sortSmallestFirst
                  ? 'SMALLEST → BIGGEST'
                  : 'BIGGEST → SMALLEST',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: themeColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _sortSmallestFirst ? '🐘' : '🐜',
            style: const TextStyle(fontSize: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsArea() {
    final themeColor = _currentTheme?['color'] as Color? ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // Direction indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _sortSmallestFirst ? '🔹' : '🔷',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _sortSmallestFirst ? 'Tiny' : 'Huge',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: themeColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    _sortSmallestFirst ? Icons.arrow_forward : Icons.arrow_back,
                    color: themeColor.withValues(alpha: 0.5),
                    size: 20,
                  ),
                )),
              ),
              Row(
                children: [
                  Text(
                    _sortSmallestFirst ? 'Huge' : 'Tiny',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _sortSmallestFirst ? '🔷' : '🔹',
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Slots
          Expanded(
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _SlotWidget(
                      index: index,
                      item: _slots[index],
                      themeColor: themeColor,
                      emoji: _currentTheme?['emoji'] ?? '⭐',
                      emojiCode: _currentTheme?['code'] ?? '2b50',
                      isHinted: _hintSlotIndex == index,
                      onItemDropped: (itemId) => _onItemDroppedOnSlot(itemId, index),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsArea() {
    final unplacedItems = _items.where((i) => !_isItemPlaced(i)).toList();
    final themeColor = _currentTheme?['color'] as Color? ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentTheme?['emoji'] ?? '⭐',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              Text(
                'Drag the ${_currentTheme?['name'] ?? 'items'}!',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: unplacedItems.map((item) => _DraggableItem(
                  item: item,
                  themeColor: themeColor,
                  bounceController: _bounceController,
                  onDragStarted: () => HapticHelper.lightTap(),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final themeColor = _currentTheme?['color'] as Color? ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: themeColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
            '📏 Size Sort',
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$_round/$_totalRounds',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
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

/// Data class for sized items
class _SizedItem {
  final int id;
  final String emoji;
  final String emojiCode;
  final double size;
  final String sizeLabel;
  final int correctPosition;

  _SizedItem({
    required this.id,
    required this.emoji,
    required this.emojiCode,
    required this.size,
    required this.sizeLabel,
    required this.correctPosition,
  });

  String get imageUrl => 'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/$emojiCode.png';
}

/// Draggable item widget with network image
class _DraggableItem extends StatelessWidget {
  final _SizedItem item;
  final Color themeColor;
  final AnimationController bounceController;
  final VoidCallback onDragStarted;

  const _DraggableItem({
    required this.item,
    required this.themeColor,
    required this.bounceController,
    required this.onDragStarted,
  });

  @override
  Widget build(BuildContext context) {
    // BIGGER base size - was 70, now 95
    final baseSize = 95.0;
    final actualSize = baseSize * item.size;

    return AnimatedBuilder(
      animation: bounceController,
      builder: (context, child) {
        final phase = (item.id * 0.35) % 1.0;
        final bounceValue = sin((bounceController.value + phase) * 2 * pi);
        final translateY = bounceValue * 5;
        final scale = 1.0 + bounceValue * 0.03;

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            child: Draggable<int>(
              data: item.id,
              onDragStarted: onDragStarted,
              feedback: Material(
                color: Colors.transparent,
                child: _ItemImage(
                  item: item,
                  size: actualSize * 1.1,
                  themeColor: themeColor,
                  isDragging: true,
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _ItemImage(
                  item: item,
                  size: actualSize,
                  themeColor: themeColor,
                ),
              ),
              child: _ItemImage(
                item: item,
                size: actualSize,
                themeColor: themeColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Item image widget using network image
class _ItemImage extends StatelessWidget {
  final _SizedItem item;
  final double size;
  final Color themeColor;
  final bool isDragging;

  const _ItemImage({
    required this.item,
    required this.size,
    required this.themeColor,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: themeColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: isDragging
                ? themeColor.withValues(alpha: 0.5)
                : themeColor.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: isDragging ? 12 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: CachedNetworkImage(
            imageUrl: item.imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => Center(
              child: Text(item.emoji, style: TextStyle(fontSize: size * 0.6)),
            ),
            errorWidget: (context, url, error) => Center(
              child: Text(item.emoji, style: TextStyle(fontSize: size * 0.6)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Slot widget for placing items
class _SlotWidget extends StatefulWidget {
  final int index;
  final _SizedItem? item;
  final Color themeColor;
  final String emoji;
  final String emojiCode;
  final bool isHinted;
  final Function(int) onItemDropped;

  const _SlotWidget({
    required this.index,
    required this.item,
    required this.themeColor,
    required this.emoji,
    required this.emojiCode,
    required this.isHinted,
    required this.onItemDropped,
  });

  @override
  State<_SlotWidget> createState() => _SlotWidgetState();
}

class _SlotWidgetState extends State<_SlotWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (widget.item != null) {
      // BIGGER slot size - was 55, now 75
      final baseSize = 75.0;
      final actualSize = baseSize * widget.item!.size;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.success, width: 3),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: CachedNetworkImage(
              imageUrl: widget.item!.imageUrl,
              width: actualSize,
              height: actualSize,
              fit: BoxFit.contain,
              placeholder: (context, url) => Text(
                widget.item!.emoji,
                style: TextStyle(fontSize: actualSize * 0.6),
              ),
              errorWidget: (context, url, error) => Text(
                widget.item!.emoji,
                style: TextStyle(fontSize: actualSize * 0.6),
              ),
            ),
          ),
        ),
      );
    }

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
        widget.onItemDropped(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovering
                ? widget.themeColor.withValues(alpha: 0.25)
                : widget.isHinted
                    ? AppColors.attention.withValues(alpha: 0.25)
                    : widget.themeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovering
                  ? widget.themeColor
                  : widget.isHinted
                      ? AppColors.attention
                      : widget.themeColor.withValues(alpha: 0.4),
              width: _isHovering || widget.isHinted ? 3 : 2,
            ),
            boxShadow: widget.isHinted
                ? [
                    BoxShadow(
                      color: AppColors.attention.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 32,
                  color: widget.isHinted
                      ? AppColors.attention
                      : widget.themeColor.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.index + 1}',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: widget.isHinted
                        ? AppColors.attention
                        : widget.themeColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
