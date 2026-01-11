import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Chore Tracker - Daily tasks chart
class ChoreTrackerGame extends StatefulWidget {
  const ChoreTrackerGame({super.key});

  @override
  State<ChoreTrackerGame> createState() => _ChoreTrackerGameState();
}

class _ChoreTrackerGameState extends State<ChoreTrackerGame> {
  late ConfettiController _confettiController;

  final List<Map<String, dynamic>> _chores = [
    {'name': 'Brush Teeth', 'emoji': '🦷', 'done': false},
    {'name': 'Make Bed', 'emoji': '🛏️', 'done': false},
    {'name': 'Eat Breakfast', 'emoji': '🥣', 'done': false},
    {'name': 'Get Dressed', 'emoji': '👕', 'done': false},
    {'name': 'Tidy Toys', 'emoji': '🧸', 'done': false},
    {'name': 'Read a Book', 'emoji': '📚', 'done': false},
    {'name': 'Wash Hands', 'emoji': '🧼', 'done': false},
    {'name': 'Help Parents', 'emoji': '🏠', 'done': false},
  ];

  int get _completedCount => _chores.where((c) => c['done']).length;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    AudioHelper.init();
    Future.delayed(const Duration(milliseconds: 500), () {
      AudioHelper.speak("Tap a chore when you complete it!");
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleChore(int index) {
    HapticHelper.lightTap();

    setState(() {
      _chores[index]['done'] = !_chores[index]['done'];
    });

    if (_chores[index]['done']) {
      AudioHelper.speak("Great job! You completed ${_chores[index]['name']}!");

      // Check if all done
      if (_completedCount == _chores.length) {
        _celebrateAllDone();
      }
    }
  }

  void _celebrateAllDone() {
    HapticHelper.celebration();
    _confettiController.play();
    AudioHelper.speak("Amazing! You completed all your chores! You're a superstar!");
  }

  void _resetAll() {
    HapticHelper.lightTap();
    setState(() {
      for (var chore in _chores) {
        chore['done'] = false;
      }
    });
    AudioHelper.speak("Starting fresh! Good luck with your chores today!");
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

                // Progress
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.success, width: 3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_completedCount}/${_chores.length}',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _completedCount / _chores.length,
                            minHeight: 20,
                            backgroundColor: AppColors.disabled,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _completedCount == _chores.length ? '🎉' : '💪',
                        style: const TextStyle(fontSize: 36),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Chores grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _chores.length,
                      itemBuilder: (context, index) {
                        final chore = _chores[index];
                        return _ChoreCard(
                          name: chore['name'],
                          emoji: chore['emoji'],
                          isDone: chore['done'],
                          onTap: () => _toggleChore(index),
                        );
                      },
                    ),
                  ),
                ),

                // Reset button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: GestureDetector(
                    onTap: _resetAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.error, width: 3),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: AppColors.error, size: 28),
                          SizedBox(width: 12),
                          Text('Start New Day', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.error)),
                        ],
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
      color: AppColors.accent1,
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          const Text('My Chores', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: AppColors.textPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text('$_completedCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoreCard extends StatelessWidget {
  final String name;
  final String emoji;
  final bool isDone;
  final VoidCallback onTap;

  const _ChoreCard({required this.name, required this.emoji, required this.isDone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDone ? AppColors.success : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDone ? AppColors.success : AppColors.secondary, width: 3),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: TextStyle(fontSize: 48, color: isDone ? Colors.white70 : null)),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDone ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (isDone)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: AppColors.success, size: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
