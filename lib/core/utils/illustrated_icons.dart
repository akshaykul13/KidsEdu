import 'package:flutter/material.dart';

/// Illustrated icons for games - custom drawn for consistent visual style
class IllustratedIcon extends StatelessWidget {
  final String iconId;
  final double size;
  final Color? backgroundColor;

  const IllustratedIcon({
    super.key,
    required this.iconId,
    this.size = 60,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _iconData[iconId];

    if (iconData != null) {
      return Container(
        width: size,
        height: size,
        decoration: backgroundColor != null
            ? BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              )
            : null,
        child: CustomPaint(
          size: Size(size, size),
          painter: _IconPainter(iconId: iconId, iconData: iconData),
        ),
      );
    }

    // Fallback to emoji
    final emoji = _emojiMap[iconId] ?? '❓';
    return Container(
      width: size,
      height: size,
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            )
          : null,
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.7)),
      ),
    );
  }

  // Icon data with colors and simple shapes
  static const Map<String, Map<String, dynamic>> _iconData = {
    'cat': {
      'primaryColor': Color(0xFFFF9800),
      'accentColor': Color(0xFFFFE0B2),
      'type': 'cat',
    },
    'dog': {
      'primaryColor': Color(0xFF8D6E63),
      'accentColor': Color(0xFFD7CCC8),
      'type': 'dog',
    },
    'rabbit': {
      'primaryColor': Color(0xFFE91E63),
      'accentColor': Color(0xFFF8BBD9),
      'type': 'rabbit',
    },
    'bear': {
      'primaryColor': Color(0xFF795548),
      'accentColor': Color(0xFFD7CCC8),
      'type': 'bear',
    },
    'fox': {
      'primaryColor': Color(0xFFFF5722),
      'accentColor': Color(0xFFFFCCBC),
      'type': 'fox',
    },
    'owl': {
      'primaryColor': Color(0xFF9C27B0),
      'accentColor': Color(0xFFE1BEE7),
      'type': 'owl',
    },
    'elephant': {
      'primaryColor': Color(0xFF78909C),
      'accentColor': Color(0xFFCFD8DC),
      'type': 'elephant',
    },
    'lion': {
      'primaryColor': Color(0xFFFFC107),
      'accentColor': Color(0xFFFFECB3),
      'type': 'lion',
    },
    'monkey': {
      'primaryColor': Color(0xFF8D6E63),
      'accentColor': Color(0xFFFFE0B2),
      'type': 'monkey',
    },
    'penguin': {
      'primaryColor': Color(0xFF37474F),
      'accentColor': Color(0xFFFFFFFF),
      'type': 'penguin',
    },
    'fish': {
      'primaryColor': Color(0xFF2196F3),
      'accentColor': Color(0xFFBBDEFB),
      'type': 'fish',
    },
    'bird': {
      'primaryColor': Color(0xFF4CAF50),
      'accentColor': Color(0xFFC8E6C9),
      'type': 'bird',
    },
    'turtle': {
      'primaryColor': Color(0xFF4CAF50),
      'accentColor': Color(0xFF8BC34A),
      'type': 'turtle',
    },
    'butterfly': {
      'primaryColor': Color(0xFFE91E63),
      'accentColor': Color(0xFF9C27B0),
      'type': 'butterfly',
    },
    'star': {
      'primaryColor': Color(0xFFFFC107),
      'accentColor': Color(0xFFFFEB3B),
      'type': 'star',
    },
    'heart': {
      'primaryColor': Color(0xFFF44336),
      'accentColor': Color(0xFFE91E63),
      'type': 'heart',
    },
    'flower': {
      'primaryColor': Color(0xFFE91E63),
      'accentColor': Color(0xFFFFC107),
      'type': 'flower',
    },
    'sun': {
      'primaryColor': Color(0xFFFFC107),
      'accentColor': Color(0xFFFF9800),
      'type': 'sun',
    },
    'moon': {
      'primaryColor': Color(0xFF3F51B5),
      'accentColor': Color(0xFFC5CAE9),
      'type': 'moon',
    },
    'cloud': {
      'primaryColor': Color(0xFF90CAF9),
      'accentColor': Color(0xFFFFFFFF),
      'type': 'cloud',
    },
  };

  // Emoji fallback map
  static const Map<String, String> _emojiMap = {
    'cat': '🐱',
    'dog': '🐕',
    'rabbit': '🐰',
    'bear': '🐻',
    'fox': '🦊',
    'owl': '🦉',
    'elephant': '🐘',
    'lion': '🦁',
    'monkey': '🐵',
    'penguin': '🐧',
    'fish': '🐟',
    'bird': '🐦',
    'turtle': '🐢',
    'butterfly': '🦋',
    'star': '⭐',
    'heart': '❤️',
    'flower': '🌸',
    'sun': '☀️',
    'moon': '🌙',
    'cloud': '☁️',
  };

  // Get all available icon IDs
  static List<String> get availableIcons => _iconData.keys.toList();
}

/// Custom painter for illustrated icons
class _IconPainter extends CustomPainter {
  final String iconId;
  final Map<String, dynamic> iconData;

  _IconPainter({required this.iconId, required this.iconData});

  @override
  void paint(Canvas canvas, Size size) {
    final primary = iconData['primaryColor'] as Color;
    final accent = iconData['accentColor'] as Color;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    final primaryPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = primary.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (iconData['type']) {
      case 'cat':
        _drawCat(canvas, size, primaryPaint, accentPaint, outlinePaint);
        break;
      case 'dog':
        _drawDog(canvas, size, primaryPaint, accentPaint, outlinePaint);
        break;
      case 'bear':
        _drawBear(canvas, size, primaryPaint, accentPaint, outlinePaint);
        break;
      case 'rabbit':
        _drawRabbit(canvas, size, primaryPaint, accentPaint, outlinePaint);
        break;
      case 'owl':
        _drawOwl(canvas, size, primaryPaint, accentPaint, outlinePaint);
        break;
      case 'star':
        _drawStar(canvas, center, radius, primaryPaint);
        break;
      case 'heart':
        _drawHeart(canvas, size, primaryPaint);
        break;
      case 'flower':
        _drawFlower(canvas, center, radius, primaryPaint, accentPaint);
        break;
      case 'sun':
        _drawSun(canvas, center, radius, primaryPaint, accentPaint);
        break;
      case 'moon':
        _drawMoon(canvas, size, primaryPaint, accentPaint);
        break;
      default:
        // Draw a simple circle for unknown icons
        canvas.drawCircle(center, radius, primaryPaint);
    }
  }

  void _drawCat(Canvas canvas, Size size, Paint primary, Paint accent, Paint outline) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Face
    canvas.drawCircle(center, radius, primary);

    // Ears (triangles)
    final earPath = Path();
    earPath.moveTo(center.dx - radius * 0.7, center.dy - radius * 0.3);
    earPath.lineTo(center.dx - radius * 0.9, center.dy - radius * 1.1);
    earPath.lineTo(center.dx - radius * 0.2, center.dy - radius * 0.7);
    earPath.close();
    canvas.drawPath(earPath, primary);

    final earPath2 = Path();
    earPath2.moveTo(center.dx + radius * 0.7, center.dy - radius * 0.3);
    earPath2.lineTo(center.dx + radius * 0.9, center.dy - radius * 1.1);
    earPath2.lineTo(center.dx + radius * 0.2, center.dy - radius * 0.7);
    earPath2.close();
    canvas.drawPath(earPath2, primary);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.1), radius * 0.25, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy - radius * 0.1), radius * 0.25, eyePaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.1), radius * 0.12, pupilPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy - radius * 0.1), radius * 0.12, pupilPaint);

    // Nose
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.2), radius * 0.12, Paint()..color = Colors.pink);
  }

  void _drawDog(Canvas canvas, Size size, Paint primary, Paint accent, Paint outline) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Face
    canvas.drawCircle(center, radius, primary);

    // Ears (floppy)
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - radius * 0.9, center.dy - radius * 0.2), width: radius * 0.6, height: radius * 1.0), primary);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + radius * 0.9, center.dy - radius * 0.2), width: radius * 0.6, height: radius * 1.0), primary);

    // Snout
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.3), width: radius * 0.8, height: radius * 0.5), accent);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.2), radius * 0.2, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy - radius * 0.2), radius * 0.2, eyePaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.2), radius * 0.1, pupilPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy - radius * 0.2), radius * 0.1, pupilPaint);

    // Nose
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.25), radius * 0.15, Paint()..color = Colors.black);
  }

  void _drawBear(Canvas canvas, Size size, Paint primary, Paint accent, Paint outline) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Ears
    canvas.drawCircle(Offset(center.dx - radius * 0.8, center.dy - radius * 0.7), radius * 0.35, primary);
    canvas.drawCircle(Offset(center.dx + radius * 0.8, center.dy - radius * 0.7), radius * 0.35, primary);

    // Face
    canvas.drawCircle(center, radius, primary);

    // Inner ears
    canvas.drawCircle(Offset(center.dx - radius * 0.8, center.dy - radius * 0.7), radius * 0.2, accent);
    canvas.drawCircle(Offset(center.dx + radius * 0.8, center.dy - radius * 0.7), radius * 0.2, accent);

    // Snout
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.25), width: radius * 0.7, height: radius * 0.5), accent);

    // Eyes
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.15), radius * 0.12, pupilPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy - radius * 0.15), radius * 0.12, pupilPaint);

    // Nose
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.2), radius * 0.15, Paint()..color = Colors.black);
  }

  void _drawRabbit(Canvas canvas, Size size, Paint primary, Paint accent, Paint outline) {
    final center = Offset(size.width / 2, size.height / 2 + size.height * 0.1);
    final radius = size.width / 3.5;

    // Ears (long ovals)
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - radius * 0.5, center.dy - radius * 1.5), width: radius * 0.5, height: radius * 1.2), primary);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + radius * 0.5, center.dy - radius * 1.5), width: radius * 0.5, height: radius * 1.2), primary);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - radius * 0.5, center.dy - radius * 1.5), width: radius * 0.3, height: radius * 0.9), accent);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + radius * 0.5, center.dy - radius * 1.5), width: radius * 0.3, height: radius * 0.9), accent);

    // Face
    canvas.drawCircle(center, radius, primary);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.1), radius * 0.22, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy - radius * 0.1), radius * 0.22, eyePaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.1), radius * 0.1, pupilPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy - radius * 0.1), radius * 0.1, pupilPaint);

    // Nose
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.3), radius * 0.12, Paint()..color = Colors.pink);
  }

  void _drawOwl(Canvas canvas, Size size, Paint primary, Paint accent, Paint outline) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Body/face
    canvas.drawCircle(center, radius, primary);

    // Ear tufts
    final leftEar = Path();
    leftEar.moveTo(center.dx - radius * 0.7, center.dy - radius * 0.5);
    leftEar.lineTo(center.dx - radius * 0.5, center.dy - radius * 1.2);
    leftEar.lineTo(center.dx - radius * 0.2, center.dy - radius * 0.7);
    leftEar.close();
    canvas.drawPath(leftEar, primary);

    final rightEar = Path();
    rightEar.moveTo(center.dx + radius * 0.7, center.dy - radius * 0.5);
    rightEar.lineTo(center.dx + radius * 0.5, center.dy - radius * 1.2);
    rightEar.lineTo(center.dx + radius * 0.2, center.dy - radius * 0.7);
    rightEar.close();
    canvas.drawPath(rightEar, primary);

    // Big eyes
    canvas.drawCircle(Offset(center.dx - radius * 0.4, center.dy - radius * 0.1), radius * 0.35, accent);
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy - radius * 0.1), radius * 0.35, accent);
    canvas.drawCircle(Offset(center.dx - radius * 0.4, center.dy - radius * 0.1), radius * 0.15, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy - radius * 0.1), radius * 0.15, Paint()..color = Colors.black);

    // Beak
    final beakPath = Path();
    beakPath.moveTo(center.dx, center.dy + radius * 0.1);
    beakPath.lineTo(center.dx - radius * 0.15, center.dy + radius * 0.4);
    beakPath.lineTo(center.dx + radius * 0.15, center.dy + radius * 0.4);
    beakPath.close();
    canvas.drawPath(beakPath, Paint()..color = const Color(0xFFFF9800));
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 5;
    const innerRadius = 0.4;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * innerRadius;
      final angle = (i * 3.14159 / points) - (3.14159 / 2);
      final x = center.dx + r * (i == 0 ? 0 : (i.isEven ? 1 : 1)) * (i == 0 ? 0 : (angle < 0 ? -1 : 1)) * r * 0 + r * (angle).cos;
      final y = center.dy + r * (angle).sin;
      if (i == 0) {
        path.moveTo(center.dx, center.dy - radius);
      }
      final a = (i * 3.14159 / points) - (3.14159 / 2);
      path.lineTo(center.dx + r * a.cos, center.dy + r * a.sin);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width * 0.6;
    final h = size.height * 0.55;

    final path = Path();
    path.moveTo(center.dx, center.dy + h * 0.4);
    path.cubicTo(center.dx - w * 0.8, center.dy - h * 0.1, center.dx - w * 0.5, center.dy - h * 0.6, center.dx, center.dy - h * 0.2);
    path.cubicTo(center.dx + w * 0.5, center.dy - h * 0.6, center.dx + w * 0.8, center.dy - h * 0.1, center.dx, center.dy + h * 0.4);
    canvas.drawPath(path, paint);
  }

  void _drawFlower(Canvas canvas, Offset center, double radius, Paint primary, Paint accent) {
    // Petals
    for (int i = 0; i < 5; i++) {
      final angle = (i * 3.14159 * 2 / 5) - (3.14159 / 2);
      final petalCenter = Offset(center.dx + radius * 0.5 * angle.cos, center.dy + radius * 0.5 * angle.sin);
      canvas.drawCircle(petalCenter, radius * 0.4, primary);
    }
    // Center
    canvas.drawCircle(center, radius * 0.3, accent);
  }

  void _drawSun(Canvas canvas, Offset center, double radius, Paint primary, Paint accent) {
    // Rays
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      final start = Offset(center.dx + radius * 0.6 * angle.cos, center.dy + radius * 0.6 * angle.sin);
      final end = Offset(center.dx + radius * 1.1 * angle.cos, center.dy + radius * 1.1 * angle.sin);
      canvas.drawLine(start, end, Paint()..color = primary.color..strokeWidth = radius * 0.15..strokeCap = StrokeCap.round);
    }
    // Circle
    canvas.drawCircle(center, radius * 0.55, primary);
  }

  void _drawMoon(Canvas canvas, Size size, Paint primary, Paint accent) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Main circle
    canvas.drawCircle(center, radius, primary);
    // Shadow circle to create crescent
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy - radius * 0.2), radius * 0.8, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
