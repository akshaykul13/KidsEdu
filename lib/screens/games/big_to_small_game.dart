import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/illustrated_icons.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Big to Small Game - Arrange items from smallest to largest
class BigToSmallGame extends StatefulWidget {
  const BigToSmallGame({super.key});

  @override
  State<BigToSmallGame> createState() => _BigToSmallGameState();
}

class _BigToSmallGameState extends State<BigToSmallGame> {
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _round = 0;
  final int _totalRounds = 5;
  int _score = 0;
  bool _isWaiting = false;
  List<_SizedItem> _items = [];
  List<_SizedItem?> _slots = [];
  bool _sortSmallestFirst = true; // true = smallest to largest, false = largest to smallest
  Timer? _hintTimer;
  int? _hintSlotIndex;

  // Item themes with illustrated icons
  static const List<Map<String, dynamic>> _itemThemes = [
    {'iconId': 'bear', 'name': 'bears', 'color': Color(0xFF795548)},
    {'iconId': 'star', 'name': 'stars', 'color': Color(0xFFFFD700)},
    {'iconId': 'heart', 'name': 'hearts', 'color': Color(0xFFE91E63)},
    {'iconId': 'flower', 'name': 'flowers', 'color': Color(0xFFFF69B4)},
    {'iconId': 'fish', 'name': 'fish', 'color': Color(0xFF4FC3F7)},
    {'iconId': 'butterfly', 'name': 'butterflies', 'color': Color(0xFF9B59B6)},
    {'iconId': 'turtle', 'name': 'turtles', 'color': Color(0xFF27AE60)},
    {'iconId': 'moon', 'name': 'moons', 'color': Color(0xFFF39C12)},
    {'iconId': 'sun', 'name': 'suns', 'color': Color(0xFFFF9800)},
    {'iconId': 'cat', 'name': 'cats', 'color': Color(0xFFFF9800)},
    {'iconId': 'dog', 'name': 'dogs', 'color': Color(0xFF8D6E63)},
    {'iconId': 'rabbit', 'name': 'rabbits', 'color': Color(0xFFE91E63)},
    {'iconId': 'owl', 'name': 'owls', 'color': Color(0xFF9C27B0)},
    {'iconId': 'penguin', 'name': 'penguins', 'color': Color(0xFF37474F)},
    {'iconId': 'bird', 'name': 'birds', 'color': Color(0xFF2196F3)},
    {'iconId': 'elephant', 'name': 'elephants', 'color': Color(0xFF78909C)},
    {'iconId': 'lion', 'name': 'lions', 'color': Color(0xFFFFC107)},
  ];

  // Sizes from smallest to largest
  static const List<double> _sizes = [0.5, 0.65, 0.8, 0.95, 1.1];
  static const List<String> _sizeLabels = ['Tiny', 'Small', 'Medium', 'Big', 'Huge'];

  Map<String, dynamic>? _currentTheme;

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
        iconId: _currentTheme!['iconId'],
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
      AudioHelper.speak("Put the ${_currentTheme!['name']} in order from $orderText!");
      _startHintTimer();
    });
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && !_isWaiting) {
        // Find the first empty slot
        final firstEmptySlot = _slots.indexWhere((s) => s == null);
        if (firstEmptySlot != -1) {
          setState(() => _hintSlotIndex = firstEmptySlot);
          AudioHelper.speak("Try putting the next ${_currentTheme!['name']} here!");
        }
      }
    });
  }

  void _onItemDroppedOnSlot(int itemId, int slotIndex) {
    if (_isWaiting) return;
    if (_slots[slotIndex] != null) return; // Slot already filled

    final itemIndex = _items.indexWhere((i) => i.id == itemId && !_isItemPlaced(i));
    if (itemIndex == -1) return;

    final item = _items[itemIndex];

    // Check if this is the correct position
    if (item.correctPosition == slotIndex) {
      // Correct!
      HapticHelper.success();
      setState(() {
        _slots[slotIndex] = item;
        _hintSlotIndex = null;
      });

      // Check if all slots are filled
      if (_slots.every((s) => s != null)) {
        // All items placed correctly!
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
      // Wrong position
      HapticHelper.error();
      AudioHelper.speak("Try again! Think about the size!");
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 16),
                // Instructions
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _currentTheme?['color'] ?? AppColors.primary, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _sortSmallestFirst ? '📏' : '📐',
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _sortSmallestFirst
                            ? 'Order from SMALLEST to BIGGEST'
                            : 'Order from BIGGEST to SMALLEST',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Slots area
                Expanded(
                  flex: 2,
                  child: _buildSlotsArea(),
                ),
                // Items to drag
                Expanded(
                  flex: 2,
                  child: _buildItemsArea(),
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

  Widget _buildSlotsArea() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_sortSmallestFirst) ...[
                const Text('🐜', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'Small',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Big',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🐘', style: TextStyle(fontSize: 24)),
              ] else ...[
                const Text('🐘', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'Big',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Small',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🐜', style: TextStyle(fontSize: 24)),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _SlotWidget(
                      index: index,
                      item: _slots[index],
                      themeColor: _currentTheme?['color'] ?? AppColors.primary,
                      isHinted: _hintSlotIndex == index,
                      onItemDropped: (itemId) => _onItemDroppedOnSlot(itemId, index),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Arrow indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _sortSmallestFirst ? '→ → → → →' : '← ← ← ← ←',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _currentTheme?['color'] ?? AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsArea() {
    final unplacedItems = _items.where((i) => !_isItemPlaced(i)).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (_currentTheme?['color'] as Color?)?.withValues(alpha: 0.1) ?? AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _currentTheme?['color'] ?? AppColors.neutral, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Drag the ${_currentTheme?['name'] ?? 'items'}',
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
                spacing: 20,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: unplacedItems.map((item) => _DraggableItem(
                  item: item,
                  themeColor: _currentTheme?['color'] ?? AppColors.primary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: _currentTheme?['color'] ?? AppColors.primary,
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
          const SizedBox(width: 24),
          Text(
            'Big to Small',
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

/// Data class for sized items
class _SizedItem {
  final int id;
  final String iconId;
  final double size;
  final String sizeLabel;
  final int correctPosition;

  _SizedItem({
    required this.id,
    required this.iconId,
    required this.size,
    required this.sizeLabel,
    required this.correctPosition,
  });
}

/// Draggable item widget
class _DraggableItem extends StatelessWidget {
  final _SizedItem item;
  final Color themeColor;
  final VoidCallback onDragStarted;

  const _DraggableItem({
    required this.item,
    required this.themeColor,
    required this.onDragStarted,
  });

  @override
  Widget build(BuildContext context) {
    final baseSize = 70.0;
    final actualSize = baseSize * item.size;

    return Draggable<int>(
      data: item.id,
      onDragStarted: onDragStarted,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: _buildContent(actualSize, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildContent(actualSize),
      ),
      child: _buildContent(actualSize),
    );
  }

  Widget _buildContent(double size, {bool isDragging = false}) {
    return Container(
      width: size + 24,
      height: size + 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor,
          width: 3,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
      ),
      child: Center(
        child: IllustratedIcon(
          iconId: item.iconId,
          size: size,
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
  final bool isHinted;
  final Function(int) onItemDropped;

  const _SlotWidget({
    required this.index,
    required this.item,
    required this.themeColor,
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
      // Show placed item
      final baseSize = 55.0;
      final actualSize = baseSize * widget.item!.size;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success, width: 3),
        ),
        child: Center(
          child: IllustratedIcon(
            iconId: widget.item!.iconId,
            size: actualSize,
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
                ? widget.themeColor.withValues(alpha: 0.3)
                : widget.isHinted
                    ? AppColors.attention.withValues(alpha: 0.3)
                    : AppColors.neutral.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovering
                  ? widget.themeColor
                  : widget.isHinted
                      ? AppColors.attention
                      : AppColors.neutral,
              width: widget.isHinted ? 4 : 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            boxShadow: widget.isHinted
                ? [
                    BoxShadow(
                      color: AppColors.attention.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '${widget.index + 1}',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: widget.isHinted
                    ? AppColors.attention
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}
