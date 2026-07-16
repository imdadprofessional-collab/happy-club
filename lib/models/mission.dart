import 'package:flutter/material.dart';

enum MissionCategory {
  gratitude,
  kindness,
  relationships,
  health,
  exercise,
  productivity,
  mindfulness,
  learning,
  reading,
  creativity,
  nature,
  family,
  friends,
  confidence,
  communication,
  selfCare,
  finance,
  digitalDetox,
  communityService,
  emotionalGrowth,
}

extension MissionCategoryX on MissionCategory {
  String get label {
    switch (this) {
      case MissionCategory.gratitude:
        return 'Gratitude';
      case MissionCategory.kindness:
        return 'Kindness';
      case MissionCategory.relationships:
        return 'Relationships';
      case MissionCategory.health:
        return 'Health';
      case MissionCategory.exercise:
        return 'Exercise';
      case MissionCategory.productivity:
        return 'Productivity';
      case MissionCategory.mindfulness:
        return 'Mindfulness';
      case MissionCategory.learning:
        return 'Learning';
      case MissionCategory.reading:
        return 'Reading';
      case MissionCategory.creativity:
        return 'Creativity';
      case MissionCategory.nature:
        return 'Nature';
      case MissionCategory.family:
        return 'Family';
      case MissionCategory.friends:
        return 'Friends';
      case MissionCategory.confidence:
        return 'Confidence';
      case MissionCategory.communication:
        return 'Communication';
      case MissionCategory.selfCare:
        return 'Self-Care';
      case MissionCategory.finance:
        return 'Finance';
      case MissionCategory.digitalDetox:
        return 'Digital Detox';
      case MissionCategory.communityService:
        return 'Community Service';
      case MissionCategory.emotionalGrowth:
        return 'Emotional Growth';
    }
  }

  IconData get icon {
    switch (this) {
      case MissionCategory.gratitude:
        return Icons.favorite_rounded;
      case MissionCategory.kindness:
        return Icons.volunteer_activism_rounded;
      case MissionCategory.relationships:
        return Icons.people_alt_rounded;
      case MissionCategory.health:
        return Icons.spa_rounded;
      case MissionCategory.exercise:
        return Icons.directions_run_rounded;
      case MissionCategory.productivity:
        return Icons.checklist_rounded;
      case MissionCategory.mindfulness:
        return Icons.self_improvement_rounded;
      case MissionCategory.learning:
        return Icons.lightbulb_rounded;
      case MissionCategory.reading:
        return Icons.menu_book_rounded;
      case MissionCategory.creativity:
        return Icons.palette_rounded;
      case MissionCategory.nature:
        return Icons.park_rounded;
      case MissionCategory.family:
        return Icons.home_rounded;
      case MissionCategory.friends:
        return Icons.groups_rounded;
      case MissionCategory.confidence:
        return Icons.emoji_events_rounded;
      case MissionCategory.communication:
        return Icons.chat_bubble_rounded;
      case MissionCategory.selfCare:
        return Icons.local_florist_rounded;
      case MissionCategory.finance:
        return Icons.savings_rounded;
      case MissionCategory.digitalDetox:
        return Icons.phonelink_erase_rounded;
      case MissionCategory.communityService:
        return Icons.diversity_3_rounded;
      case MissionCategory.emotionalGrowth:
        return Icons.psychology_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MissionCategory.gratitude:
        return const Color(0xFFFF7A59);
      case MissionCategory.kindness:
        return const Color(0xFFFF6F91);
      case MissionCategory.relationships:
        return const Color(0xFF8E7CFF);
      case MissionCategory.health:
        return const Color(0xFF3DD9B4);
      case MissionCategory.exercise:
        return const Color(0xFF5AC8FA);
      case MissionCategory.productivity:
        return const Color(0xFFFFC371);
      case MissionCategory.mindfulness:
        return const Color(0xFF6C63FF);
      case MissionCategory.learning:
        return const Color(0xFFFFB84D);
      case MissionCategory.reading:
        return const Color(0xFF9B7BFF);
      case MissionCategory.creativity:
        return const Color(0xFFFF8FB1);
      case MissionCategory.nature:
        return const Color(0xFF4CAF7D);
      case MissionCategory.family:
        return const Color(0xFFFF9F6B);
      case MissionCategory.friends:
        return const Color(0xFF5AC8FA);
      case MissionCategory.confidence:
        return const Color(0xFFFFD166);
      case MissionCategory.communication:
        return const Color(0xFF6FCF97);
      case MissionCategory.selfCare:
        return const Color(0xFFFF8FA3);
      case MissionCategory.finance:
        return const Color(0xFF4DB6AC);
      case MissionCategory.digitalDetox:
        return const Color(0xFF8E8EA6);
      case MissionCategory.communityService:
        return const Color(0xFFEF9A6B);
      case MissionCategory.emotionalGrowth:
        return const Color(0xFF8E7CFF);
    }
  }
}

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.category,
    this.description = '',
  });

  final String id;
  final String title;
  final String description;
  final MissionCategory category;
}

class CompletedMission {
  CompletedMission({
    required this.missionId,
    required this.missionTitle,
    required this.category,
    required this.completedAt,
    this.note,
  });

  final String missionId;
  final String missionTitle;
  final MissionCategory category;
  final DateTime completedAt;
  final String? note;

  Map<String, dynamic> toJson() => {
    'missionId': missionId,
    'missionTitle': missionTitle,
    'category': category.name,
    'completedAt': completedAt.toIso8601String(),
    'note': note,
  };

  factory CompletedMission.fromJson(Map<String, dynamic> json) =>
      CompletedMission(
        missionId: json['missionId'] as String,
        missionTitle: json['missionTitle'] as String,
        category: MissionCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => MissionCategory.gratitude,
        ),
        completedAt: DateTime.parse(json['completedAt'] as String),
        note: json['note'] as String?,
      );
}
