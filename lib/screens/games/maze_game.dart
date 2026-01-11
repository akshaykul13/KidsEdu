import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

/// Maze Game - Find path from start to finish
class MazeGame extends StatefulWidget {
  const MazeGame({super.key});

  @override
  State<MazeGame> createState() => _MazeGameState();
}

class _MazeGameState extends State<MazeGame> {
  late ConfettiController _confettiController;
  int _level = 1;
  int _playerRow = 0;
  int _playerCol = 0;
  int _goalRow = 0;
  int _goalCol = 0;
  List<List<int>> _maze = [];
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    AudioHelper.init();
    _generateMaze();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _generateMaze() {
    // Simple maze: 0 = path, 1 = wall
    final mazes = [
      // Level 1 - Easy (5x5)
      [
        [0, 0, 0, 1, 0],
        [1, 1, 0, 1, 0],
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
      ],
      // Level 2
      [
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 1],
        [0, 0, 0, 0, 0],
        [1, 0, 1, 0, 1],
        [0, 0, 0, 0, 0],
      ],
      // Level 3
      [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 0, 0, 0],
        [0, 0, 0, 1, 0],
        [1, 1, 0, 0, 0],
      ],
    ];

    setState(() {
      _maze = mazes[(_level - 1) % mazes.length];
      _playerRow = 0;
      _playerCol = 0;
      _goalRow = 4;
      _goalCol = 4;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      AudioHelper.speak("Help the bunny find the carrot! Tap the arrows to move.");
    });
  }

  void _move(int dRow, int dCol) {
    final newRow = _playerRow + dRow;
    final newCol = _playerCol + dCol;

    // Check bounds
    if (newRow < 0 || newRow >= _maze.length || newCol < 0 || newCol >= _maze[0].length) {
      HapticHelper.error();
      return;
    }

    // Check wall
    if (_maze[newRow][newCol] == 1) {
      HapticHelper.error();
      return;
    }

    HapticHelper.lightTap();
    setState(() {
      _playerRow = newRow;
      _playerCol = newCol;
    });

    // Check win
    if (_playerRow == _goalRow && _playerCol == _goalCol) {
      _onLevelComplete();
    }
  }

  void _onLevelComplete() {
    HapticHelper.success();
    _confettiController.play();
    _score++;
    AudioHelper.speakSuccess();

    if (_level < 3) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() => _level++);
        _generateMaze();
      });
    } else {
      _showGameComplete();
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
        totalRounds: 3,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() { _level = 1; _score = 0; });
          _generateMaze();
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
                Expanded(
                  child: Row(
                    children: [
                      // Maze grid
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.secondary, width: 4),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(_maze.length, (row) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(_maze[row].length, (col) {
                                    final isPlayer = row == _playerRow && col == _playerCol;
                                    final isGoal = row == _goalRow && col == _goalCol;
                                    final isWall = _maze[row][col] == 1;

                                    return Container(
                                      width: 70,
                                      height: 70,
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: isWall ? AppColors.textSecondary : AppColors.accent1.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: isPlayer
                                            ? const Text('🐰', style: TextStyle(fontSize: 40))
                                            : isGoal
                                                ? const Text('🥕', style: TextStyle(fontSize: 40))
                                                : null,
                                      ),
                                    );
                                  }),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),

                      // Controls
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ArrowButton(icon: Icons.arrow_upward, onTap: () => _move(-1, 0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _ArrowButton(icon: Icons.arrow_back, onTap: () => _move(0, -1)),
                                const SizedBox(width: 80),
                                _ArrowButton(icon: Icons.arrow_forward, onTap: () => _move(0, 1)),
                              ],
                            ),
                            _ArrowButton(icon: Icons.arrow_downward, onTap: () => _move(1, 0)),
                          ],
                        ),
                      ),
                    ],
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
      color: AppColors.secondary,
      child: Row(
        children: [
          const GameBackButton(),
          const SizedBox(width: 24),
          const Text('Maze Adventure', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24)),
            child: Text('Level $_level/3', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
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

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 48, color: Colors.white),
      ),
    );
  }
}
