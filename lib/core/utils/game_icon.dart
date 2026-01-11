import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Rich SVG-based game icons with cute, detailed illustrations
class GameIcon extends StatelessWidget {
  final String iconId;
  final double size;
  final Color? backgroundColor;

  const GameIcon({
    super.key,
    required this.iconId,
    this.size = 60,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final svgData = _svgIcons[iconId];

    Widget icon;
    if (svgData != null) {
      icon = SvgPicture.string(
        svgData,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    } else {
      // Fallback to emoji
      final emoji = _emojiMap[iconId] ?? '❓';
      icon = Text(emoji, style: TextStyle(fontSize: size * 0.7));
    }

    if (backgroundColor != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      );
    }

    return icon;
  }

  /// Get icon data for theming
  static IconData? getIconColor(String iconId) {
    return _iconColors[iconId];
  }

  /// All available icon IDs
  static List<String> get availableIcons => _svgIcons.keys.toList();

  /// Icon primary colors for card backgrounds
  static final Map<String, IconData> _iconColors = {
    'cat': const IconData(0xFFFF9800),
    'dog': const IconData(0xFF8D6E63),
    'rabbit': const IconData(0xFFE91E63),
    'bear': const IconData(0xFF795548),
    'fox': const IconData(0xFFFF5722),
    'owl': const IconData(0xFF9C27B0),
    'elephant': const IconData(0xFF78909C),
    'lion': const IconData(0xFFFFC107),
    'monkey': const IconData(0xFF8D6E63),
    'penguin': const IconData(0xFF37474F),
    'fish': const IconData(0xFF2196F3),
    'bird': const IconData(0xFF4CAF50),
    'turtle': const IconData(0xFF4CAF50),
    'butterfly': const IconData(0xFFE91E63),
    'star': const IconData(0xFFFFC107),
    'heart': const IconData(0xFFF44336),
    'flower': const IconData(0xFFE91E63),
    'sun': const IconData(0xFFFFC107),
    'moon': const IconData(0xFF3F51B5),
    'cloud': const IconData(0xFF90CAF9),
  };

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

  /// Rich, detailed SVG icons with cute cartoon style
  static const Map<String, String> _svgIcons = {
    // Cute Cat - Orange tabby with big eyes
    'cat': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Ears -->
      <path d="M20 35 L30 10 L45 30 Z" fill="#FF9800"/>
      <path d="M80 35 L70 10 L55 30 Z" fill="#FF9800"/>
      <path d="M25 32 L32 15 L42 28 Z" fill="#FFE0B2"/>
      <path d="M75 32 L68 15 L58 28 Z" fill="#FFE0B2"/>
      <!-- Face -->
      <ellipse cx="50" cy="55" rx="35" ry="32" fill="#FF9800"/>
      <!-- Inner face -->
      <ellipse cx="50" cy="60" rx="25" ry="22" fill="#FFE0B2"/>
      <!-- Eyes -->
      <ellipse cx="38" cy="50" rx="8" ry="10" fill="white"/>
      <ellipse cx="62" cy="50" rx="8" ry="10" fill="white"/>
      <ellipse cx="40" cy="51" rx="5" ry="6" fill="#2D2D2D"/>
      <ellipse cx="64" cy="51" rx="5" ry="6" fill="#2D2D2D"/>
      <circle cx="42" cy="49" r="2" fill="white"/>
      <circle cx="66" cy="49" r="2" fill="white"/>
      <!-- Nose -->
      <ellipse cx="50" cy="62" rx="5" ry="4" fill="#FF6B6B"/>
      <!-- Mouth -->
      <path d="M50 66 Q45 72 40 68" stroke="#6D4C41" stroke-width="2" fill="none" stroke-linecap="round"/>
      <path d="M50 66 Q55 72 60 68" stroke="#6D4C41" stroke-width="2" fill="none" stroke-linecap="round"/>
      <!-- Whiskers -->
      <line x1="20" y1="58" x2="35" y2="60" stroke="#6D4C41" stroke-width="1.5" stroke-linecap="round"/>
      <line x1="20" y1="65" x2="35" y2="65" stroke="#6D4C41" stroke-width="1.5" stroke-linecap="round"/>
      <line x1="65" y1="60" x2="80" y2="58" stroke="#6D4C41" stroke-width="1.5" stroke-linecap="round"/>
      <line x1="65" y1="65" x2="80" y2="65" stroke="#6D4C41" stroke-width="1.5" stroke-linecap="round"/>
      <!-- Stripes -->
      <path d="M35 35 Q50 25 65 35" stroke="#E65100" stroke-width="3" fill="none" stroke-linecap="round"/>
    </svg>''',

    // Cute Dog - Brown puppy with floppy ears
    'dog': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Floppy ears -->
      <ellipse cx="22" cy="45" rx="15" ry="25" fill="#8D6E63"/>
      <ellipse cx="78" cy="45" rx="15" ry="25" fill="#8D6E63"/>
      <ellipse cx="22" cy="45" rx="10" ry="20" fill="#6D4C41"/>
      <ellipse cx="78" cy="45" rx="10" ry="20" fill="#6D4C41"/>
      <!-- Face -->
      <ellipse cx="50" cy="55" rx="32" ry="30" fill="#8D6E63"/>
      <!-- Snout -->
      <ellipse cx="50" cy="65" rx="18" ry="15" fill="#D7CCC8"/>
      <!-- Eyes -->
      <ellipse cx="38" cy="48" rx="8" ry="9" fill="white"/>
      <ellipse cx="62" cy="48" rx="8" ry="9" fill="white"/>
      <ellipse cx="40" cy="49" rx="5" ry="6" fill="#2D2D2D"/>
      <ellipse cx="64" cy="49" rx="5" ry="6" fill="#2D2D2D"/>
      <circle cx="42" cy="47" r="2" fill="white"/>
      <circle cx="66" cy="47" r="2" fill="white"/>
      <!-- Eyebrows -->
      <path d="M30 40 Q38 35 46 40" stroke="#5D4037" stroke-width="2.5" fill="none" stroke-linecap="round"/>
      <path d="M54 40 Q62 35 70 40" stroke="#5D4037" stroke-width="2.5" fill="none" stroke-linecap="round"/>
      <!-- Nose -->
      <ellipse cx="50" cy="62" rx="8" ry="6" fill="#2D2D2D"/>
      <ellipse cx="48" cy="60" rx="2" ry="1.5" fill="#4A4A4A"/>
      <!-- Mouth -->
      <path d="M50 68 L50 75" stroke="#5D4037" stroke-width="2" stroke-linecap="round"/>
      <path d="M50 75 Q42 82 35 75" stroke="#5D4037" stroke-width="2" fill="none" stroke-linecap="round"/>
      <path d="M50 75 Q58 82 65 75" stroke="#5D4037" stroke-width="2" fill="none" stroke-linecap="round"/>
      <!-- Tongue -->
      <ellipse cx="50" cy="80" rx="6" ry="5" fill="#FF6B6B"/>
    </svg>''',

    // Cute Rabbit - Pink bunny with long ears
    'rabbit': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Long ears -->
      <ellipse cx="35" cy="25" rx="10" ry="25" fill="#F8BBD9"/>
      <ellipse cx="65" cy="25" rx="10" ry="25" fill="#F8BBD9"/>
      <ellipse cx="35" cy="25" rx="6" ry="20" fill="#FCE4EC"/>
      <ellipse cx="65" cy="25" rx="6" ry="20" fill="#FCE4EC"/>
      <!-- Face -->
      <ellipse cx="50" cy="62" rx="30" ry="28" fill="#F8BBD9"/>
      <!-- Cheeks -->
      <ellipse cx="30" cy="68" rx="10" ry="8" fill="#FFCDD2"/>
      <ellipse cx="70" cy="68" rx="10" ry="8" fill="#FFCDD2"/>
      <!-- Eyes -->
      <ellipse cx="38" cy="55" rx="8" ry="10" fill="white"/>
      <ellipse cx="62" cy="55" rx="8" ry="10" fill="white"/>
      <ellipse cx="40" cy="56" rx="5" ry="6" fill="#E91E63"/>
      <ellipse cx="64" cy="56" rx="5" ry="6" fill="#E91E63"/>
      <circle cx="42" cy="54" r="2" fill="white"/>
      <circle cx="66" cy="54" r="2" fill="white"/>
      <!-- Nose -->
      <ellipse cx="50" cy="67" rx="5" ry="4" fill="#FF6B6B"/>
      <!-- Mouth -->
      <path d="M45 72 Q50 78 55 72" stroke="#C2185B" stroke-width="2" fill="none" stroke-linecap="round"/>
      <!-- Teeth -->
      <rect x="47" y="72" width="6" height="6" rx="1" fill="white"/>
      <line x1="50" y1="72" x2="50" y2="78" stroke="#F8BBD9" stroke-width="1"/>
    </svg>''',

    // Cute Bear - Brown teddy bear
    'bear': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Ears -->
      <circle cx="25" cy="28" r="15" fill="#795548"/>
      <circle cx="75" cy="28" r="15" fill="#795548"/>
      <circle cx="25" cy="28" r="9" fill="#A1887F"/>
      <circle cx="75" cy="28" r="9" fill="#A1887F"/>
      <!-- Face -->
      <ellipse cx="50" cy="55" rx="35" ry="33" fill="#795548"/>
      <!-- Snout -->
      <ellipse cx="50" cy="62" rx="18" ry="14" fill="#A1887F"/>
      <!-- Eyes -->
      <ellipse cx="35" cy="48" rx="7" ry="8" fill="#2D2D2D"/>
      <ellipse cx="65" cy="48" rx="7" ry="8" fill="#2D2D2D"/>
      <circle cx="37" cy="46" r="2.5" fill="white"/>
      <circle cx="67" cy="46" r="2.5" fill="white"/>
      <!-- Nose -->
      <ellipse cx="50" cy="58" rx="8" ry="6" fill="#2D2D2D"/>
      <ellipse cx="48" cy="56" rx="2" ry="1.5" fill="#4A4A4A"/>
      <!-- Mouth -->
      <path d="M50 64 L50 70" stroke="#5D4037" stroke-width="2.5" stroke-linecap="round"/>
      <path d="M50 70 Q43 76 38 72" stroke="#5D4037" stroke-width="2.5" fill="none" stroke-linecap="round"/>
      <path d="M50 70 Q57 76 62 72" stroke="#5D4037" stroke-width="2.5" fill="none" stroke-linecap="round"/>
    </svg>''',

    // Cute Fox - Orange fox with white accents
    'fox': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Ears -->
      <path d="M20 45 L28 8 L45 35 Z" fill="#FF5722"/>
      <path d="M80 45 L72 8 L55 35 Z" fill="#FF5722"/>
      <path d="M25 42 L30 15 L42 35 Z" fill="#2D2D2D"/>
      <path d="M75 42 L70 15 L58 35 Z" fill="#2D2D2D"/>
      <!-- Face -->
      <ellipse cx="50" cy="55" rx="35" ry="32" fill="#FF5722"/>
      <!-- White face markings -->
      <path d="M50 35 Q30 55 35 85 L50 75 L65 85 Q70 55 50 35" fill="white"/>
      <!-- Eyes -->
      <ellipse cx="35" cy="50" rx="8" ry="10" fill="white"/>
      <ellipse cx="65" cy="50" rx="8" ry="10" fill="white"/>
      <ellipse cx="37" cy="51" rx="5" ry="6" fill="#FF5722"/>
      <ellipse cx="67" cy="51" rx="5" ry="6" fill="#FF5722"/>
      <ellipse cx="38" cy="51" rx="3" ry="4" fill="#2D2D2D"/>
      <ellipse cx="68" cy="51" rx="3" ry="4" fill="#2D2D2D"/>
      <circle cx="39" cy="49" r="1.5" fill="white"/>
      <circle cx="69" cy="49" r="1.5" fill="white"/>
      <!-- Nose -->
      <ellipse cx="50" cy="62" rx="6" ry="5" fill="#2D2D2D"/>
      <!-- Mouth -->
      <path d="M50 67 Q45 72 42 68" stroke="#5D4037" stroke-width="2" fill="none" stroke-linecap="round"/>
      <path d="M50 67 Q55 72 58 68" stroke="#5D4037" stroke-width="2" fill="none" stroke-linecap="round"/>
    </svg>''',

    // Cute Owl - Purple owl with big eyes
    'owl': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Ear tufts -->
      <path d="M25 35 L20 10 L40 30 Z" fill="#9C27B0"/>
      <path d="M75 35 L80 10 L60 30 Z" fill="#9C27B0"/>
      <!-- Body -->
      <ellipse cx="50" cy="58" rx="35" ry="35" fill="#9C27B0"/>
      <!-- Belly -->
      <ellipse cx="50" cy="68" rx="22" ry="20" fill="#E1BEE7"/>
      <!-- Belly pattern -->
      <path d="M35 60 Q50 55 65 60" stroke="#CE93D8" stroke-width="2" fill="none"/>
      <path d="M38 68 Q50 63 62 68" stroke="#CE93D8" stroke-width="2" fill="none"/>
      <path d="M40 76 Q50 71 60 76" stroke="#CE93D8" stroke-width="2" fill="none"/>
      <!-- Eyes -->
      <circle cx="35" cy="48" r="14" fill="white"/>
      <circle cx="65" cy="48" r="14" fill="white"/>
      <circle cx="35" cy="48" r="10" fill="#FFC107"/>
      <circle cx="65" cy="48" r="10" fill="#FFC107"/>
      <circle cx="35" cy="48" r="5" fill="#2D2D2D"/>
      <circle cx="65" cy="48" r="5" fill="#2D2D2D"/>
      <circle cx="37" cy="46" r="2" fill="white"/>
      <circle cx="67" cy="46" r="2" fill="white"/>
      <!-- Beak -->
      <path d="M50 55 L45 65 L50 62 L55 65 Z" fill="#FF9800"/>
    </svg>''',

    // Cute Elephant - Gray elephant with big ears
    'elephant': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Ears -->
      <ellipse cx="18" cy="50" rx="18" ry="25" fill="#78909C"/>
      <ellipse cx="82" cy="50" rx="18" ry="25" fill="#78909C"/>
      <ellipse cx="20" cy="50" rx="12" ry="18" fill="#B0BEC5"/>
      <ellipse cx="80" cy="50" rx="12" ry="18" fill="#B0BEC5"/>
      <!-- Face -->
      <ellipse cx="50" cy="50" rx="30" ry="32" fill="#78909C"/>
      <!-- Trunk -->
      <path d="M50 60 Q50 75 45 85 Q43 90 48 90 Q53 90 52 85 Q55 75 50 60" fill="#78909C" stroke="#546E7A" stroke-width="1"/>
      <!-- Eyes -->
      <ellipse cx="38" cy="42" rx="7" ry="8" fill="white"/>
      <ellipse cx="62" cy="42" rx="7" ry="8" fill="white"/>
      <ellipse cx="40" cy="43" rx="4" ry="5" fill="#2D2D2D"/>
      <ellipse cx="64" cy="43" rx="4" ry="5" fill="#2D2D2D"/>
      <circle cx="41" cy="41" r="1.5" fill="white"/>
      <circle cx="65" cy="41" r="1.5" fill="white"/>
      <!-- Eyebrows -->
      <path d="M30 35 Q38 32 46 36" stroke="#455A64" stroke-width="2" fill="none" stroke-linecap="round"/>
      <path d="M54 36 Q62 32 70 35" stroke="#455A64" stroke-width="2" fill="none" stroke-linecap="round"/>
      <!-- Tusks -->
      <ellipse cx="38" cy="70" rx="3" ry="8" fill="#ECEFF1" transform="rotate(-15 38 70)"/>
      <ellipse cx="62" cy="70" rx="3" ry="8" fill="#ECEFF1" transform="rotate(15 62 70)"/>
    </svg>''',

    // Cute Lion - Yellow lion with mane
    'lion': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Mane -->
      <circle cx="50" cy="50" r="42" fill="#FF9800"/>
      <circle cx="25" cy="35" r="12" fill="#FFA726"/>
      <circle cx="75" cy="35" r="12" fill="#FFA726"/>
      <circle cx="20" cy="55" r="10" fill="#FFA726"/>
      <circle cx="80" cy="55" r="10" fill="#FFA726"/>
      <circle cx="30" cy="75" r="10" fill="#FFA726"/>
      <circle cx="70" cy="75" r="10" fill="#FFA726"/>
      <circle cx="50" cy="82" r="10" fill="#FFA726"/>
      <!-- Face -->
      <ellipse cx="50" cy="52" rx="28" ry="26" fill="#FFC107"/>
      <!-- Snout -->
      <ellipse cx="50" cy="60" rx="15" ry="12" fill="#FFECB3"/>
      <!-- Eyes -->
      <ellipse cx="38" cy="48" rx="7" ry="8" fill="white"/>
      <ellipse cx="62" cy="48" rx="7" ry="8" fill="white"/>
      <ellipse cx="40" cy="49" rx="4" ry="5" fill="#795548"/>
      <ellipse cx="64" cy="49" rx="4" ry="5" fill="#795548"/>
      <circle cx="41" cy="47" r="1.5" fill="white"/>
      <circle cx="65" cy="47" r="1.5" fill="white"/>
      <!-- Nose -->
      <ellipse cx="50" cy="58" rx="6" ry="5" fill="#2D2D2D"/>
      <!-- Mouth -->
      <path d="M50 63 L50 68" stroke="#5D4037" stroke-width="2" stroke-linecap="round"/>
      <path d="M50 68 Q44 73 40 70" stroke="#5D4037" stroke-width="2" fill="none" stroke-linecap="round"/>
      <path d="M50 68 Q56 73 60 70" stroke="#5D4037" stroke-width="2" fill="none" stroke-linecap="round"/>
    </svg>''',

    // Cute Monkey - Brown monkey
    'monkey': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Ears -->
      <circle cx="15" cy="50" r="15" fill="#8D6E63"/>
      <circle cx="85" cy="50" r="15" fill="#8D6E63"/>
      <circle cx="15" cy="50" r="10" fill="#FFCCBC"/>
      <circle cx="85" cy="50" r="10" fill="#FFCCBC"/>
      <!-- Face -->
      <ellipse cx="50" cy="50" rx="32" ry="35" fill="#8D6E63"/>
      <!-- Face marking -->
      <ellipse cx="50" cy="58" rx="22" ry="22" fill="#FFCCBC"/>
      <!-- Eyes -->
      <ellipse cx="38" cy="45" rx="7" ry="8" fill="white"/>
      <ellipse cx="62" cy="45" rx="7" ry="8" fill="white"/>
      <ellipse cx="40" cy="46" rx="4" ry="5" fill="#2D2D2D"/>
      <ellipse cx="64" cy="46" rx="4" ry="5" fill="#2D2D2D"/>
      <circle cx="41" cy="44" r="1.5" fill="white"/>
      <circle cx="65" cy="44" r="1.5" fill="white"/>
      <!-- Nose -->
      <ellipse cx="50" cy="58" rx="8" ry="6" fill="#FFAB91"/>
      <circle cx="46" cy="58" r="2.5" fill="#5D4037"/>
      <circle cx="54" cy="58" r="2.5" fill="#5D4037"/>
      <!-- Mouth -->
      <path d="M42 68 Q50 75 58 68" stroke="#5D4037" stroke-width="2.5" fill="none" stroke-linecap="round"/>
    </svg>''',

    // Cute Penguin - Black and white penguin
    'penguin': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Body -->
      <ellipse cx="50" cy="55" rx="32" ry="38" fill="#37474F"/>
      <!-- Belly -->
      <ellipse cx="50" cy="60" rx="22" ry="28" fill="white"/>
      <!-- Eyes -->
      <ellipse cx="38" cy="40" rx="8" ry="9" fill="white"/>
      <ellipse cx="62" cy="40" rx="8" ry="9" fill="white"/>
      <ellipse cx="40" cy="41" rx="5" ry="6" fill="#2D2D2D"/>
      <ellipse cx="64" cy="41" rx="5" ry="6" fill="#2D2D2D"/>
      <circle cx="42" cy="39" r="2" fill="white"/>
      <circle cx="66" cy="39" r="2" fill="white"/>
      <!-- Beak -->
      <path d="M50 48 L42 58 L50 55 L58 58 Z" fill="#FF9800"/>
      <!-- Cheeks -->
      <ellipse cx="30" cy="52" rx="6" ry="5" fill="#FFCCBC"/>
      <ellipse cx="70" cy="52" rx="6" ry="5" fill="#FFCCBC"/>
      <!-- Feet -->
      <ellipse cx="40" cy="90" rx="8" ry="4" fill="#FF9800"/>
      <ellipse cx="60" cy="90" rx="8" ry="4" fill="#FF9800"/>
    </svg>''',

    // Cute Fish - Blue tropical fish
    'fish': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Tail -->
      <path d="M15 50 L0 35 L5 50 L0 65 Z" fill="#1976D2"/>
      <!-- Body -->
      <ellipse cx="50" cy="50" rx="40" ry="25" fill="#2196F3"/>
      <!-- Stripes -->
      <path d="M55 28 Q60 50 55 72" stroke="#1565C0" stroke-width="5" fill="none"/>
      <path d="M70 32 Q75 50 70 68" stroke="#1565C0" stroke-width="5" fill="none"/>
      <!-- Top fin -->
      <path d="M40 25 L50 10 L60 25" fill="#1976D2"/>
      <!-- Bottom fin -->
      <path d="M40 75 L50 90 L55 75" fill="#1976D2"/>
      <!-- Eye -->
      <circle cx="75" cy="45" r="8" fill="white"/>
      <circle cx="77" cy="45" r="5" fill="#2D2D2D"/>
      <circle cx="79" cy="43" r="2" fill="white"/>
      <!-- Mouth -->
      <ellipse cx="90" cy="52" rx="3" ry="4" fill="#1565C0"/>
      <!-- Bubbles -->
      <circle cx="95" cy="40" r="3" fill="#BBDEFB" opacity="0.7"/>
      <circle cx="92" cy="32" r="2" fill="#BBDEFB" opacity="0.7"/>
    </svg>''',

    // Cute Bird - Green songbird
    'bird': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Tail -->
      <path d="M15 55 L0 45 L5 55 L0 70 L15 60" fill="#388E3C"/>
      <!-- Body -->
      <ellipse cx="45" cy="55" rx="30" ry="22" fill="#4CAF50"/>
      <!-- Wing -->
      <ellipse cx="35" cy="55" rx="18" ry="15" fill="#388E3C"/>
      <path d="M25 50 L18 55 L25 60" stroke="#2E7D32" stroke-width="2" fill="none"/>
      <path d="M30 48 L22 52 L30 58" stroke="#2E7D32" stroke-width="2" fill="none"/>
      <!-- Head -->
      <circle cx="70" cy="45" r="18" fill="#4CAF50"/>
      <!-- Eye -->
      <circle cx="75" cy="42" r="6" fill="white"/>
      <circle cx="77" cy="42" r="4" fill="#2D2D2D"/>
      <circle cx="78" cy="40" r="1.5" fill="white"/>
      <!-- Beak -->
      <path d="M88 45 L95 48 L88 51" fill="#FF9800"/>
      <!-- Cheek -->
      <circle cx="72" cy="52" r="4" fill="#FFCCBC"/>
      <!-- Feet -->
      <line x1="40" y1="75" x2="40" y2="90" stroke="#FF9800" stroke-width="2"/>
      <line x1="50" y1="75" x2="50" y2="90" stroke="#FF9800" stroke-width="2"/>
      <path d="M35 90 L40 85 L45 90" stroke="#FF9800" stroke-width="2" fill="none"/>
      <path d="M45 90 L50 85 L55 90" stroke="#FF9800" stroke-width="2" fill="none"/>
    </svg>''',

    // Cute Turtle - Green turtle with shell pattern
    'turtle': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Shell -->
      <ellipse cx="50" cy="55" rx="38" ry="30" fill="#4CAF50"/>
      <!-- Shell pattern -->
      <ellipse cx="50" cy="55" rx="25" ry="18" fill="#8BC34A" stroke="#388E3C" stroke-width="2"/>
      <path d="M35 45 L35 65" stroke="#388E3C" stroke-width="2"/>
      <path d="M50 40 L50 70" stroke="#388E3C" stroke-width="2"/>
      <path d="M65 45 L65 65" stroke="#388E3C" stroke-width="2"/>
      <path d="M28 55 L72 55" stroke="#388E3C" stroke-width="2"/>
      <!-- Head -->
      <ellipse cx="88" cy="50" rx="12" ry="10" fill="#8BC34A"/>
      <!-- Eye -->
      <circle cx="92" cy="47" r="4" fill="white"/>
      <circle cx="93" cy="47" r="2.5" fill="#2D2D2D"/>
      <circle cx="94" cy="46" r="1" fill="white"/>
      <!-- Smile -->
      <path d="M92 53 Q95 56 98 53" stroke="#388E3C" stroke-width="1.5" fill="none" stroke-linecap="round"/>
      <!-- Legs -->
      <ellipse cx="22" cy="45" rx="10" ry="6" fill="#8BC34A"/>
      <ellipse cx="22" cy="65" rx="10" ry="6" fill="#8BC34A"/>
      <ellipse cx="75" cy="72" rx="8" ry="5" fill="#8BC34A"/>
      <!-- Tail -->
      <path d="M12 55 L5 55" stroke="#8BC34A" stroke-width="5" stroke-linecap="round"/>
    </svg>''',

    // Cute Butterfly - Colorful butterfly
    'butterfly': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Wings -->
      <ellipse cx="30" cy="35" rx="25" ry="20" fill="#E91E63"/>
      <ellipse cx="70" cy="35" rx="25" ry="20" fill="#E91E63"/>
      <ellipse cx="30" cy="65" rx="22" ry="18" fill="#9C27B0"/>
      <ellipse cx="70" cy="65" rx="22" ry="18" fill="#9C27B0"/>
      <!-- Wing patterns -->
      <circle cx="30" cy="35" r="10" fill="#F8BBD9"/>
      <circle cx="70" cy="35" r="10" fill="#F8BBD9"/>
      <circle cx="30" cy="35" r="5" fill="#E91E63"/>
      <circle cx="70" cy="35" r="5" fill="#E91E63"/>
      <circle cx="30" cy="65" r="8" fill="#CE93D8"/>
      <circle cx="70" cy="65" r="8" fill="#CE93D8"/>
      <!-- Body -->
      <ellipse cx="50" cy="50" rx="6" ry="25" fill="#2D2D2D"/>
      <!-- Head -->
      <circle cx="50" cy="22" r="8" fill="#2D2D2D"/>
      <!-- Eyes -->
      <circle cx="47" cy="20" r="2.5" fill="white"/>
      <circle cx="53" cy="20" r="2.5" fill="white"/>
      <!-- Antennae -->
      <path d="M45 15 Q40 5 35 8" stroke="#2D2D2D" stroke-width="2" fill="none" stroke-linecap="round"/>
      <path d="M55 15 Q60 5 65 8" stroke="#2D2D2D" stroke-width="2" fill="none" stroke-linecap="round"/>
      <circle cx="35" cy="8" r="3" fill="#FFC107"/>
      <circle cx="65" cy="8" r="3" fill="#FFC107"/>
    </svg>''',

    // Star - Golden star with glow
    'star': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Glow -->
      <polygon points="50,5 61,35 95,35 68,57 79,90 50,70 21,90 32,57 5,35 39,35" fill="#FFF59D" opacity="0.5"/>
      <!-- Star -->
      <polygon points="50,10 59,35 88,35 65,52 74,80 50,65 26,80 35,52 12,35 41,35" fill="#FFC107"/>
      <!-- Highlight -->
      <polygon points="50,15 56,32 75,32 60,45 66,65 50,55 34,65 40,45 25,32 44,32" fill="#FFEB3B"/>
      <!-- Sparkle -->
      <circle cx="42" cy="30" r="3" fill="white" opacity="0.8"/>
    </svg>''',

    // Heart - Red heart with shine
    'heart': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Heart shape -->
      <path d="M50 88 C20 60 5 40 5 28 C5 12 20 5 35 5 C42 5 48 10 50 15 C52 10 58 5 65 5 C80 5 95 12 95 28 C95 40 80 60 50 88" fill="#F44336"/>
      <!-- Highlight -->
      <path d="M35 15 C25 15 15 22 15 32 C15 38 20 45 30 55" stroke="white" stroke-width="5" fill="none" opacity="0.4" stroke-linecap="round"/>
      <!-- Shine -->
      <ellipse cx="30" cy="28" rx="8" ry="6" fill="white" opacity="0.3"/>
    </svg>''',

    // Flower - Pink flower
    'flower': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Petals -->
      <ellipse cx="50" cy="25" rx="15" ry="20" fill="#E91E63"/>
      <ellipse cx="75" cy="40" rx="15" ry="20" fill="#EC407A" transform="rotate(72 75 40)"/>
      <ellipse cx="68" cy="70" rx="15" ry="20" fill="#E91E63" transform="rotate(144 68 70)"/>
      <ellipse cx="32" cy="70" rx="15" ry="20" fill="#EC407A" transform="rotate(-144 32 70)"/>
      <ellipse cx="25" cy="40" rx="15" ry="20" fill="#E91E63" transform="rotate(-72 25 40)"/>
      <!-- Center -->
      <circle cx="50" cy="50" r="15" fill="#FFC107"/>
      <circle cx="50" cy="50" r="10" fill="#FFD54F"/>
      <!-- Center dots -->
      <circle cx="45" cy="47" r="2" fill="#FF8F00"/>
      <circle cx="55" cy="47" r="2" fill="#FF8F00"/>
      <circle cx="50" cy="55" r="2" fill="#FF8F00"/>
      <circle cx="45" cy="53" r="1.5" fill="#FF8F00"/>
      <circle cx="55" cy="53" r="1.5" fill="#FF8F00"/>
    </svg>''',

    // Sun - Bright sun with rays
    'sun': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Rays -->
      <g stroke="#FFC107" stroke-width="4" stroke-linecap="round">
        <line x1="50" y1="5" x2="50" y2="20"/>
        <line x1="50" y1="80" x2="50" y2="95"/>
        <line x1="5" y1="50" x2="20" y2="50"/>
        <line x1="80" y1="50" x2="95" y2="50"/>
        <line x1="18" y1="18" x2="28" y2="28"/>
        <line x1="72" y1="72" x2="82" y2="82"/>
        <line x1="18" y1="82" x2="28" y2="72"/>
        <line x1="72" y1="28" x2="82" y2="18"/>
      </g>
      <!-- Sun body -->
      <circle cx="50" cy="50" r="28" fill="#FFC107"/>
      <circle cx="50" cy="50" r="22" fill="#FFEB3B"/>
      <!-- Face -->
      <ellipse cx="40" cy="45" rx="4" ry="5" fill="#FF8F00"/>
      <ellipse cx="60" cy="45" rx="4" ry="5" fill="#FF8F00"/>
      <path d="M38 58 Q50 68 62 58" stroke="#FF8F00" stroke-width="3" fill="none" stroke-linecap="round"/>
      <!-- Cheeks -->
      <circle cx="32" cy="55" r="4" fill="#FFAB40" opacity="0.6"/>
      <circle cx="68" cy="55" r="4" fill="#FFAB40" opacity="0.6"/>
    </svg>''',

    // Moon - Crescent moon with stars
    'moon': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Moon glow -->
      <circle cx="45" cy="50" r="38" fill="#C5CAE9" opacity="0.3"/>
      <!-- Moon -->
      <circle cx="45" cy="50" r="35" fill="#FFF59D"/>
      <circle cx="60" cy="45" r="28" fill="#1A237E"/>
      <!-- Moon face -->
      <ellipse cx="35" cy="45" rx="3" ry="4" fill="#FBC02D"/>
      <path d="M30 58 Q38 62 42 58" stroke="#FBC02D" stroke-width="2" fill="none" stroke-linecap="round"/>
      <!-- Stars -->
      <polygon points="80,20 82,26 88,26 83,30 85,36 80,32 75,36 77,30 72,26 78,26" fill="#FFF59D"/>
      <polygon points="15,25 16,28 20,28 17,30 18,34 15,31 12,34 13,30 10,28 14,28" fill="#FFF59D" opacity="0.8"/>
      <polygon points="75,70 76,73 79,73 77,75 78,78 75,76 72,78 73,75 71,73 74,73" fill="#FFF59D" opacity="0.7"/>
    </svg>''',

    // Cloud - Fluffy white cloud
    'cloud': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <!-- Cloud shadow -->
      <ellipse cx="52" cy="62" rx="38" ry="18" fill="#B0BEC5" opacity="0.5"/>
      <!-- Cloud body -->
      <circle cx="35" cy="55" r="20" fill="white"/>
      <circle cx="55" cy="48" r="25" fill="white"/>
      <circle cx="75" cy="55" r="18" fill="white"/>
      <ellipse cx="55" cy="62" rx="35" ry="15" fill="white"/>
      <!-- Highlights -->
      <circle cx="45" cy="42" r="8" fill="#E3F2FD"/>
      <circle cx="65" cy="38" r="6" fill="#E3F2FD"/>
      <!-- Face -->
      <ellipse cx="45" cy="52" rx="3" ry="4" fill="#90A4AE"/>
      <ellipse cx="60" cy="52" rx="3" ry="4" fill="#90A4AE"/>
      <path d="M48 62 Q52 66 58 62" stroke="#90A4AE" stroke-width="2" fill="none" stroke-linecap="round"/>
      <!-- Cheeks -->
      <circle cx="38" cy="58" r="4" fill="#FFCCBC" opacity="0.5"/>
      <circle cx="68" cy="58" r="4" fill="#FFCCBC" opacity="0.5"/>
    </svg>''',
  };
}
