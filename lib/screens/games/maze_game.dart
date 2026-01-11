import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/navigation_buttons.dart';
import '../../widgets/celebration_overlay.dart';

enum MazeDifficulty { easy, medium, hard }

/// Maze Game - Find path from start to finish
class MazeGame extends StatefulWidget {
  const MazeGame({super.key});

  @override
  State<MazeGame> createState() => _MazeGameState();
}

class _MazeGameState extends State<MazeGame> {
  late ConfettiController _confettiController;
  MazeDifficulty _difficulty = MazeDifficulty.easy;
  bool _showDifficultyPicker = true;
  int _level = 1;
  int _playerRow = 0;
  int _playerCol = 0;
  int _goalRow = 0;
  int _goalCol = 0;
  List<List<int>> _maze = [];
  int _score = 0;
  bool _showControls = true; // Toggle for D-pad visibility

  // Maze configurations per difficulty
  static const Map<MazeDifficulty, List<List<List<int>>>> _mazesByDifficulty = {
    MazeDifficulty.easy: [
      [
        [0, 0, 0, 1, 0],
        [1, 1, 0, 1, 0],
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
      ],
      [
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 1],
        [0, 0, 0, 0, 0],
        [1, 0, 1, 0, 1],
        [0, 0, 0, 0, 0],
      ],
      [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 0, 0, 0],
        [0, 0, 0, 1, 0],
        [1, 1, 0, 0, 0],
      ],
    ],
    MazeDifficulty.medium: [
      [
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 0, 1, 0, 1, 0],
        [0, 0, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 1],
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 0, 0, 0, 1, 0],
      ],
      [
        [0, 0, 1, 0, 0, 0, 0],
        [0, 0, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [1, 0, 1, 1, 1, 0, 1],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 1, 1, 0, 0, 0, 1],
        [0, 0, 0, 0, 1, 0, 0],
      ],
      [
        [0, 0, 0, 0, 1, 0, 0],
        [0, 1, 1, 0, 1, 0, 1],
        [0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 1, 1, 0],
        [1, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 1, 0],
        [0, 1, 0, 0, 0, 0, 0],
      ],
    ],
    MazeDifficulty.hard: [
      [
        [0, 0, 0, 1, 0, 0, 0, 1, 0],
        [1, 1, 0, 1, 0, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 1, 0, 1],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [1, 1, 0, 1, 1, 1, 0, 1, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 1, 0, 0, 0],
      ],
      [
        [0, 0, 1, 0, 0, 0, 1, 0, 0],
        [0, 0, 1, 0, 1, 0, 1, 0, 1],
        [0, 0, 0, 0, 1, 0, 0, 0, 0],
        [1, 0, 1, 1, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 1, 1, 1, 0, 1],
        [0, 0, 0, 0, 1, 0, 0, 0, 0],
        [1, 0, 1, 0, 0, 0, 1, 1, 0],
        [0, 0, 0, 0, 1, 0, 0, 0, 0],
      ],
      [
        [0, 0, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 1, 0, 1, 0, 1, 1, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 1, 1, 1, 0, 1],
        [1, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 1, 1, 1, 0],
        [0, 1, 0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 1, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
      ],
    ],
  };

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    AudioHelper.init();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _selectDifficulty(MazeDifficulty difficulty) {
    setState(() {
      _difficulty = difficulty;
      _showDifficultyPicker = false;
      _level = 1;
      _score = 0;
    });
    _generateMaze();
  }

  int get _totalLevels => _mazesByDifficulty[_difficulty]!.length;

  int get _mazeSize {
    switch (_difficulty) {
      case MazeDifficulty.easy:
        return 5;
      case MazeDifficulty.medium:
        return 7;
      case MazeDifficulty.hard:
        return 9;
    }
  }

  void _generateMaze() {
    final mazes = _mazesByDifficulty[_difficulty]!;
    final size = _mazeSize;

    setState(() {
      _maze = mazes[(_level - 1) % mazes.length];
      _playerRow = 0;
      _playerCol = 0;
      _goalRow = size - 1;
      _goalCol = size - 1;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      AudioHelper.speak("Swipe to help the bunny find the carrot!");
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

  void _onTapCell(int row, int col) {
    // Only allow tapping adjacent cells
    final rowDiff = row - _playerRow;
    final colDiff = col - _playerCol;

    // Must be exactly one step away (not diagonal)
    if ((rowDiff.abs() == 1 && colDiff == 0) || (rowDiff == 0 && colDiff.abs() == 1)) {
      _move(rowDiff, colDiff);
    }
  }

  void _onLevelComplete() {
    HapticHelper.success();
    _confettiController.play();
    _score++;
    AudioHelper.speakSuccess();

    if (_level < _totalLevels) {
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
        totalRounds: _totalLevels,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _showDifficultyPicker = true;
            _level = 1;
            _score = 0;
          });
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
    if (_showDifficultyPicker) {
      return _buildDifficultyPicker();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // Sky blue background
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 100) {
              _move(0, 1); // Swipe right
            } else if (details.primaryVelocity! < -100) {
              _move(0, -1); // Swipe left
            }
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 100) {
              _move(1, 0); // Swipe down
            } else if (details.primaryVelocity! < -100) {
              _move(-1, 0); // Swipe up
            }
          }
        },
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: 100,
              left: 20,
              child: Text('☁️', style: TextStyle(fontSize: 40, color: Colors.white.withValues(alpha: 0.8))),
            ),
            Positioned(
              top: 80,
              right: 60,
              child: Text('☁️', style: TextStyle(fontSize: 50, color: Colors.white.withValues(alpha: 0.8))),
            ),
            Positioned(
              top: 140,
              right: 150,
              child: Text('☁️', style: TextStyle(fontSize: 35, color: Colors.white.withValues(alpha: 0.8))),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),

                  // Swipe hint
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.swipe, color: AppColors.primary, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Swipe or tap to move',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Maze - takes most of the screen
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: LayoutBuilder(
                          builder: (context, outerConstraints) {
                            // Calculate max size that fits in available space
                            final maxSize = outerConstraints.maxWidth < outerConstraints.maxHeight
                                ? outerConstraints.maxWidth
                                : outerConstraints.maxHeight;

                            return SizedBox(
                              width: maxSize,
                              height: maxSize,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D1B00), // Dark brown border
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      offset: const Offset(0, 6),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B4513), // Saddle brown frame
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Each cell has margin: 1 on all sides = 2px per cell
                                      // Total margin = _mazeSize * 2
                                      final totalMargin = _mazeSize * 2.0;
                                      // Use minimum dimension to ensure square cells fit
                                      final availableSize = constraints.maxWidth < constraints.maxHeight
                                          ? constraints.maxWidth
                                          : constraints.maxHeight;
                                      // Floor to avoid sub-pixel overflow
                                      final cellSize = ((availableSize - totalMargin) / _mazeSize).floorToDouble();

                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(_maze.length, (row) {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(_maze[row].length, (col) {
                                              final isPlayer = row == _playerRow && col == _playerCol;
                                              final isGoal = row == _goalRow && col == _goalCol;
                                              final isWall = _maze[row][col] == 1;
                                              final isAdjacent = !isWall && (
                                                (row == _playerRow && (col - _playerCol).abs() == 1) ||
                                                (col == _playerCol && (row - _playerRow).abs() == 1)
                                              );

                                              return GestureDetector(
                                                onTap: () => _onTapCell(row, col),
                                                child: Container(
                                                  width: cellSize,
                                                  height: cellSize,
                                                  margin: const EdgeInsets.all(1),
                                                  decoration: BoxDecoration(
                                                    color: isWall
                                                        ? const Color(0xFF2D5016) // Dark green hedge
                                                        : isAdjacent
                                                            ? const Color(0xFFFFE4B5) // Highlighted adjacent
                                                            : const Color(0xFFF5DEB3), // Wheat/sand path
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: isWall
                                                        ? Border.all(color: const Color(0xFF1A3009), width: 2)
                                                        : isAdjacent
                                                            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2)
                                                            : null,
                                                    boxShadow: isWall
                                                        ? [
                                                            const BoxShadow(
                                                              color: Color(0xFF1A3009),
                                                              offset: Offset(0, 2),
                                                              blurRadius: 0,
                                                            ),
                                                          ]
                                                        : null,
                                                  ),
                                                  child: Center(
                                                    child: isPlayer
                                                        ? Text('🐰', style: TextStyle(fontSize: cellSize * 0.55))
                                                        : isGoal
                                                            ? Text('🥕', style: TextStyle(fontSize: cellSize * 0.55))
                                                            : isWall
                                                                ? Text('🌲', style: TextStyle(fontSize: cellSize * 0.4))
                                                                : null,
                                                  ),
                                                ),
                                              );
                                            }),
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Floating D-pad (optional, togglable)
            if (_showControls)
              Positioned(
                bottom: 24,
                right: 24,
                child: _buildFloatingDPad(),
              ),

            // Toggle controls button
            Positioned(
              bottom: 24,
              left: 24,
              child: GestureDetector(
                onTap: () => setState(() => _showControls = !_showControls),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _showControls ? Icons.gamepad : Icons.gamepad_outlined,
                    size: 32,
                    color: _showControls ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            CelebrationOverlay(controller: _confettiController),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingDPad() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniArrowButton(icon: Icons.arrow_upward, onTap: () => _move(-1, 0)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniArrowButton(icon: Icons.arrow_back, onTap: () => _move(0, -1)),
              const SizedBox(width: 48),
              _MiniArrowButton(icon: Icons.arrow_forward, onTap: () => _move(0, 1)),
            ],
          ),
          _MiniArrowButton(icon: Icons.arrow_downward, onTap: () => _move(1, 0)),
        ],
      ),
    );
  }

  Widget _buildDifficultyPicker() {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
                    'Maze Adventure',
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🐰', style: TextStyle(fontSize: 100)),
                    const SizedBox(height: 8),
                    Text(
                      'Help Bunny find the Carrot!',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Choose Difficulty',
                      style: GoogleFonts.nunito(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _DifficultyButton(
                      label: 'Easy',
                      subtitle: '5×5 maze',
                      color: AppColors.success,
                      icon: '🌱',
                      onTap: () => _selectDifficulty(MazeDifficulty.easy),
                    ),
                    const SizedBox(height: 16),
                    _DifficultyButton(
                      label: 'Medium',
                      subtitle: '7×7 maze',
                      color: AppColors.attention,
                      icon: '🌿',
                      onTap: () => _selectDifficulty(MazeDifficulty.medium),
                    ),
                    const SizedBox(height: 16),
                    _DifficultyButton(
                      label: 'Hard',
                      subtitle: '9×9 maze',
                      color: AppColors.error,
                      icon: '🌳',
                      onTap: () => _selectDifficulty(MazeDifficulty.hard),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final difficultyLabel = _difficulty == MazeDifficulty.easy
        ? 'Easy'
        : _difficulty == MazeDifficulty.medium
            ? 'Medium'
            : 'Hard';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          const SizedBox(width: 16),
          Text(
            'Maze',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              difficultyLabel,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_level/$_totalLevels',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.attention,
              borderRadius: BorderRadius.circular(12),
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

class _DifficultyButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final Color color;
  final String icon;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_DifficultyButton> createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<_DifficultyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final shadeColor = HSLColor.fromColor(widget.color).withLightness(0.3).toColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticHelper.lightTap();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: 280,
        height: 80,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: shadeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              top: _isPressed ? 8 : 0,
              left: 0,
              right: 0,
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniArrowButton({required this.icon, required this.onTap});

  @override
  State<_MiniArrowButton> createState() => _MiniArrowButtonState();
}

class _MiniArrowButtonState extends State<_MiniArrowButton> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 48,
        height: 48,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.primaryShade : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(widget.icon, size: 28, color: Colors.white),
      ),
    );
  }
}
