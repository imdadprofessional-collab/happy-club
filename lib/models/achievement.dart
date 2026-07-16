import 'package:flutter/material.dart';

enum AchievementKind { streak, missions, gratitude, kindness, community, level }

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.kind,
    required this.threshold,
    this.gradient = const [Color(0xFFFFD86B), Color(0xFFFFC371)],
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementKind kind;
  final int threshold;
  final List<Color> gradient;
}

class LevelTitle {
  const LevelTitle(this.minLevel, this.title);
  final int minLevel;
  final String title;

  static const List<LevelTitle> ladder = [
    LevelTitle(1, 'Positive Beginner'),
    LevelTitle(5, 'Habit Builder'),
    LevelTitle(10, 'Optimist'),
    LevelTitle(16, 'Community Hero'),
    LevelTitle(24, 'Kindness Champion'),
    LevelTitle(35, 'Happiness Master'),
  ];

  static String forLevel(int level) {
    var title = ladder.first.title;
    for (final entry in ladder) {
      if (level >= entry.minLevel) title = entry.title;
    }
    return title;
  }
}
