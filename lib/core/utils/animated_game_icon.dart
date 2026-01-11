import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'game_icon.dart';

/// Animation state for game icons
enum GameIconState {
  idle,      // Normal state with gentle animation
  tapped,    // Being pressed
  correct,   // Matched/correct answer
  wrong,     // Wrong answer
  hint,      // Showing hint
}

/// Animated wrapper for game icons with engaging micro-animations
class AnimatedGameIcon extends StatefulWidget {
  final String iconId;
  final double size;
  final GameIconState state;
  final bool enableIdleAnimation;
  final Duration entranceDelay;
  final VoidCallback? onAnimationComplete;

  const AnimatedGameIcon({
    super.key,
    required this.iconId,
    this.size = 60,
    this.state = GameIconState.idle,
    this.enableIdleAnimation = true,
    this.entranceDelay = Duration.zero,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedGameIcon> createState() => _AnimatedGameIconState();
}

class _AnimatedGameIconState extends State<AnimatedGameIcon>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _bounceController;
  late Animation<double> _floatAnimation;
  late Animation<double> _breatheAnimation;

  bool _hasEnteredView = false;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Idle floating animation
    _idleController = AnimationController(
      duration: Duration(milliseconds: 2000 + _random.nextInt(1000)),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _breatheAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    // Bounce controller for tap feedback
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    if (widget.enableIdleAnimation) {
      _idleController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedGameIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state != oldWidget.state) {
      _handleStateChange(widget.state);
    }

    if (widget.enableIdleAnimation != oldWidget.enableIdleAnimation) {
      if (widget.enableIdleAnimation) {
        _idleController.repeat(reverse: true);
      } else {
        _idleController.stop();
      }
    }
  }

  void _handleStateChange(GameIconState newState) {
    switch (newState) {
      case GameIconState.tapped:
        _bounceController.forward().then((_) => _bounceController.reverse());
        break;
      case GameIconState.correct:
        // Stop idle, play celebration
        _idleController.stop();
        break;
      case GameIconState.wrong:
        // Shake handled by flutter_animate
        break;
      case GameIconState.hint:
        // Pulse handled by flutter_animate
        break;
      case GameIconState.idle:
        if (widget.enableIdleAnimation && !_idleController.isAnimating) {
          _idleController.repeat(reverse: true);
        }
        break;
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = GameIcon(
      iconId: widget.iconId,
      size: widget.size,
    );

    // Apply idle animation
    if (widget.enableIdleAnimation && widget.state == GameIconState.idle) {
      icon = AnimatedBuilder(
        animation: _idleController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Transform.scale(
              scale: _breatheAnimation.value,
              child: child,
            ),
          );
        },
        child: icon,
      );
    }

    // Apply bounce animation for tap
    icon = AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final scale = 1.0 - (_bounceController.value * 0.1);
        return Transform.scale(scale: scale, child: child);
      },
      child: icon,
    );

    // Apply state-specific animations using flutter_animate
    switch (widget.state) {
      case GameIconState.correct:
        icon = icon
            .animate(onComplete: (_) => widget.onAnimationComplete?.call())
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.3, 1.3),
              duration: 200.ms,
              curve: Curves.easeOut,
            )
            .then()
            .scale(
              begin: const Offset(1.3, 1.3),
              end: const Offset(1, 1),
              duration: 200.ms,
              curve: Curves.elasticOut,
            )
            .rotate(
              begin: 0,
              end: 0.05,
              duration: 100.ms,
            )
            .then()
            .rotate(
              begin: 0.05,
              end: -0.05,
              duration: 100.ms,
            )
            .then()
            .rotate(
              begin: -0.05,
              end: 0,
              duration: 100.ms,
            );
        break;

      case GameIconState.wrong:
        icon = icon
            .animate()
            .shake(hz: 5, rotation: 0.05, duration: 400.ms)
            .tint(color: Colors.red.withValues(alpha: 0.3), duration: 200.ms)
            .then()
            .tint(color: Colors.transparent, duration: 200.ms);
        break;

      case GameIconState.hint:
        icon = icon
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 600.ms,
              curve: Curves.easeInOut,
            )
            .boxShadow(
              begin: BoxShadow(
                color: Colors.amber.withValues(alpha: 0),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              end: BoxShadow(
                color: Colors.amber.withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 5,
              ),
              duration: 600.ms,
            );
        break;

      case GameIconState.tapped:
      case GameIconState.idle:
        // Handled by manual animations above
        break;
    }

    // Entrance animation
    if (!_hasEnteredView) {
      _hasEnteredView = true;
      icon = icon
          .animate(delay: widget.entranceDelay)
          .fadeIn(duration: 300.ms)
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            duration: 400.ms,
            curve: Curves.elasticOut,
          );
    }

    return icon;
  }
}

/// Card wrapper with animated effects for memory games
class AnimatedGameCard extends StatefulWidget {
  final Widget child;
  final bool isFlipped;
  final bool isMatched;
  final bool isWrong;
  final bool showHint;
  final VoidCallback? onTap;
  final Color cardColor;
  final Color shadeColor;
  final double width;
  final double height;

  const AnimatedGameCard({
    super.key,
    required this.child,
    this.isFlipped = false,
    this.isMatched = false,
    this.isWrong = false,
    this.showHint = false,
    this.onTap,
    this.cardColor = const Color(0xFFE5E5E5),
    this.shadeColor = const Color(0xFFAFB4BD),
    this.width = 100,
    this.height = 100,
  });

  @override
  State<AnimatedGameCard> createState() => _AnimatedGameCardState();
}

class _AnimatedGameCardState extends State<AnimatedGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
    _flipController.addListener(_updateFlipState);
  }

  void _updateFlipState() {
    if (_flipController.value >= 0.5 && !_showFront) {
      setState(() => _showFront = true);
    } else if (_flipController.value < 0.5 && _showFront) {
      setState(() => _showFront = false);
    }
  }

  @override
  void didUpdateWidget(AnimatedGameCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: _showFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );

    // Apply state effects
    if (widget.isMatched) {
      card = card
          .animate()
          .shimmer(
            duration: 1500.ms,
            color: Colors.white.withValues(alpha: 0.3),
          );
    }

    if (widget.isWrong) {
      card = card.animate().shake(hz: 4, rotation: 0.04, duration: 300.ms);
    }

    if (widget.showHint) {
      card = card
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .boxShadow(
            begin: BoxShadow(
              color: Colors.amber.withValues(alpha: 0),
              blurRadius: 0,
            ),
            end: BoxShadow(
              color: Colors.amber.withValues(alpha: 0.8),
              blurRadius: 25,
              spreadRadius: 5,
            ),
            duration: 800.ms,
          );
    }

    return card;
  }

  Widget _buildBack() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
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
                color: widget.shadeColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Face
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            left: 0,
            right: 0,
            top: _isPressed ? 6 : 0,
            bottom: _isPressed ? 0 : 6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.cardColor,
                    HSLColor.fromColor(widget.cardColor)
                        .withLightness(
                          (HSLColor.fromColor(widget.cardColor).lightness - 0.1)
                              .clamp(0.0, 1.0),
                        )
                        .toColor(),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: widget.width * 0.4,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFront() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
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
                  color: widget.isMatched
                      ? const Color(0xFF46A302)
                      : widget.shadeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // Face
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isMatched
                      ? const Color(0xFF58CC02)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isMatched
                        ? const Color(0xFF58CC02)
                        : widget.cardColor,
                    width: 3,
                  ),
                ),
                child: Center(child: widget.child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Particle effect for celebrations
class CelebrationParticles extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final int particleCount;

  const CelebrationParticles({
    super.key,
    this.isPlaying = false,
    this.color = Colors.amber,
    this.particleCount = 12,
  });

  @override
  State<CelebrationParticles> createState() => _CelebrationParticlesState();
}

class _CelebrationParticlesState extends State<CelebrationParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _generateParticles();
  }

  void _generateParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      final angle = (index / widget.particleCount) * 2 * math.pi;
      return _Particle(
        angle: angle,
        distance: 30 + _random.nextDouble() * 40,
        size: 4 + _random.nextDouble() * 6,
        color: HSLColor.fromColor(widget.color)
            .withHue((_random.nextDouble() * 60) - 30 +
                HSLColor.fromColor(widget.color).hue)
            .toColor(),
      );
    });
  }

  @override
  void didUpdateWidget(CelebrationParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _generateParticles();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying && !_controller.isAnimating) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      final distance = particle.distance * Curves.easeOut.transform(progress);
      final opacity = 1.0 - Curves.easeIn.transform(progress);
      final scale = 1.0 - (progress * 0.5);

      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        particle.size * scale,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
