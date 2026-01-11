import 'package:flutter/material.dart';

enum GameCategory {
  literacy,
  numeracy,
  writing,
  music,
  world,
  puzzles,
  lifeSkills,
}

class GameInfo {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final GameCategory category;
  final String route;

  const GameInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.route,
  });
}

class GameData {
  static const List<GameInfo> games = [
    // Literacy
    GameInfo(
      id: 'phonics',
      title: 'Letter Phonics',
      description: 'Learn letter sounds',
      icon: Icons.record_voice_over,
      color: Color(0xFF4A90D9),
      category: GameCategory.literacy,
      route: '/phonics',
    ),
    GameInfo(
      id: 'identify_letter',
      title: 'Identify Letters',
      description: 'Find the letter',
      icon: Icons.abc,
      color: Color(0xFF5DADE2),
      category: GameCategory.literacy,
      route: '/identify-letter',
    ),
    GameInfo(
      id: 'words',
      title: 'Build Words',
      description: 'Make simple words',
      icon: Icons.text_fields,
      color: Color(0xFF48C9B0),
      category: GameCategory.literacy,
      route: '/words',
    ),

    // Numeracy
    GameInfo(
      id: 'identify_numbers',
      title: 'Identify Numbers',
      description: 'Learn numbers 1-20',
      icon: Icons.looks_one,
      color: Color(0xFF7AC74F),
      category: GameCategory.numeracy,
      route: '/identify-numbers',
    ),
    GameInfo(
      id: 'math',
      title: 'Basic Math',
      description: 'Addition & counting',
      icon: Icons.calculate,
      color: Color(0xFF82E0AA),
      category: GameCategory.numeracy,
      route: '/math',
    ),
    GameInfo(
      id: 'higher_lower',
      title: 'Higher or Lower',
      description: 'Compare numbers',
      icon: Icons.swap_vert,
      color: Color(0xFF58CC02),
      category: GameCategory.numeracy,
      route: '/higher-lower',
    ),
    GameInfo(
      id: 'before_after',
      title: 'Before & After',
      description: 'Build missing numbers',
      icon: Icons.keyboard_double_arrow_right,
      color: Color(0xFF46A302),
      category: GameCategory.numeracy,
      route: '/before-after',
    ),

    // Writing
    GameInfo(
      id: 'write_letters',
      title: 'Write Letters',
      description: 'Trace & write ABC',
      icon: Icons.edit,
      color: Color(0xFFFF9F43),
      category: GameCategory.writing,
      route: '/write-letters',
    ),
    GameInfo(
      id: 'write_words',
      title: 'Write Words',
      description: 'Write simple words',
      icon: Icons.draw,
      color: Color(0xFFF8C471),
      category: GameCategory.writing,
      route: '/write-words',
    ),
    GameInfo(
      id: 'write_numbers',
      title: 'Write Numbers',
      description: 'Trace & write 1-20',
      icon: Icons.onetwothree,
      color: Color(0xFFFAD7A0),
      category: GameCategory.writing,
      route: '/write-numbers',
    ),

    // Music
    GameInfo(
      id: 'music_notes',
      title: 'Music Notes',
      description: 'Learn musical notes',
      icon: Icons.music_note,
      color: Color(0xFF9B59B6),
      category: GameCategory.music,
      route: '/music-notes',
    ),

    // World
    GameInfo(
      id: 'flags',
      title: 'Country Flags',
      description: 'Learn world flags',
      icon: Icons.flag,
      color: Color(0xFFFF6B9D),
      category: GameCategory.world,
      route: '/flags',
    ),

    // Puzzles
    GameInfo(
      id: 'maze',
      title: 'Maze Adventure',
      description: 'Find the path',
      icon: Icons.route,
      color: Color(0xFF3498DB),
      category: GameCategory.puzzles,
      route: '/maze',
    ),
    GameInfo(
      id: 'find_hidden',
      title: 'Find Hidden',
      description: 'Spot the objects',
      icon: Icons.search,
      color: Color(0xFF1ABC9C),
      category: GameCategory.puzzles,
      route: '/find-hidden',
    ),
    GameInfo(
      id: 'memory_match',
      title: 'Memory Match',
      description: 'Find matching pairs',
      icon: Icons.grid_view_rounded,
      color: Color(0xFF9B59B6),
      category: GameCategory.puzzles,
      route: '/memory-match',
    ),
    GameInfo(
      id: 'odd_one_out',
      title: 'Odd One Out',
      description: 'Find what doesn\'t belong',
      icon: Icons.help_outline_rounded,
      color: Color(0xFFE67E22),
      category: GameCategory.puzzles,
      route: '/odd-one-out',
    ),
    GameInfo(
      id: 'spot_difference',
      title: 'Spot Difference',
      description: 'Find the changes',
      icon: Icons.compare_rounded,
      color: Color(0xFF2980B9),
      category: GameCategory.puzzles,
      route: '/spot-difference',
    ),
    GameInfo(
      id: 'color_sort',
      title: 'Color Sort',
      description: 'Sort by colors',
      icon: Icons.palette_rounded,
      color: Color(0xFFE91E63),
      category: GameCategory.puzzles,
      route: '/color-sort',
    ),
    GameInfo(
      id: 'big_to_small',
      title: 'Big to Small',
      description: 'Order by size',
      icon: Icons.sort_rounded,
      color: Color(0xFF8B4513),
      category: GameCategory.puzzles,
      route: '/big-to-small',
    ),

    // Life Skills
    GameInfo(
      id: 'calendar',
      title: 'Calendar & Date',
      description: 'Learn days & months',
      icon: Icons.calendar_today,
      color: Color(0xFFE74C3C),
      category: GameCategory.lifeSkills,
      route: '/calendar',
    ),
    GameInfo(
      id: 'chores',
      title: 'Chore Tracker',
      description: 'Daily tasks chart',
      icon: Icons.checklist,
      color: Color(0xFFFFD93D),
      category: GameCategory.lifeSkills,
      route: '/chores',
    ),
  ];
}
