import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../theme/app_colors.dart';

class AchievementsData {
  AchievementsData._();

  static const List<Achievement> streakMilestones = [
    Achievement(
      id: 'streak_7',
      title: '7-Day Spark',
      description: 'Completed missions 7 days in a row.',
      icon: Icons.local_fire_department_rounded,
      kind: AchievementKind.streak,
      threshold: 7,
      gradient: AppColors.heroGradient,
    ),
    Achievement(
      id: 'streak_14',
      title: 'Two-Week Glow',
      description: 'Completed missions 14 days in a row.',
      icon: Icons.local_fire_department_rounded,
      kind: AchievementKind.streak,
      threshold: 14,
      gradient: AppColors.heroGradient,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Monthly Momentum',
      description: 'Completed missions 30 days in a row.',
      icon: Icons.whatshot_rounded,
      kind: AchievementKind.streak,
      threshold: 30,
      gradient: AppColors.goldGradient,
    ),
    Achievement(
      id: 'streak_60',
      title: '60-Day Blaze',
      description: 'Completed missions 60 days in a row.',
      icon: Icons.whatshot_rounded,
      kind: AchievementKind.streak,
      threshold: 60,
      gradient: AppColors.goldGradient,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Centurion of Joy',
      description: 'Completed missions 100 days in a row.',
      icon: Icons.military_tech_rounded,
      kind: AchievementKind.streak,
      threshold: 100,
      gradient: AppColors.goldGradient,
    ),
    Achievement(
      id: 'streak_180',
      title: 'Half-Year Hero',
      description: 'Completed missions 180 days in a row.',
      icon: Icons.military_tech_rounded,
      kind: AchievementKind.streak,
      threshold: 180,
      gradient: AppColors.calmGradient,
    ),
    Achievement(
      id: 'streak_365',
      title: 'Year of Happy',
      description: 'Completed missions 365 days in a row.',
      icon: Icons.emoji_events_rounded,
      kind: AchievementKind.streak,
      threshold: 365,
      gradient: AppColors.goldGradient,
    ),
  ];

  static const List<Achievement> missionMilestones = [
    Achievement(
      id: 'missions_10',
      title: 'Getting Started',
      description: 'Completed 10 missions.',
      icon: Icons.check_circle_rounded,
      kind: AchievementKind.missions,
      threshold: 10,
    ),
    Achievement(
      id: 'missions_50',
      title: 'Habit Builder',
      description: 'Completed 50 missions.',
      icon: Icons.check_circle_rounded,
      kind: AchievementKind.missions,
      threshold: 50,
    ),
    Achievement(
      id: 'missions_100',
      title: 'Century Club',
      description: 'Completed 100 missions.',
      icon: Icons.workspace_premium_rounded,
      kind: AchievementKind.missions,
      threshold: 100,
      gradient: AppColors.goldGradient,
    ),
    Achievement(
      id: 'missions_365',
      title: 'Everyday Achiever',
      description: 'Completed 365 missions.',
      icon: Icons.workspace_premium_rounded,
      kind: AchievementKind.missions,
      threshold: 365,
      gradient: AppColors.goldGradient,
    ),
  ];

  static const List<Achievement> communityMilestones = [
    Achievement(
      id: 'community_5',
      title: 'Encourager',
      description: 'Reacted to 5 posts in the community.',
      icon: Icons.favorite_rounded,
      kind: AchievementKind.community,
      threshold: 5,
      gradient: AppColors.calmGradient,
    ),
    Achievement(
      id: 'community_25',
      title: 'Cheerleader',
      description: 'Reacted to 25 posts in the community.',
      icon: Icons.favorite_rounded,
      kind: AchievementKind.community,
      threshold: 25,
      gradient: AppColors.calmGradient,
    ),
    Achievement(
      id: 'community_posts_10',
      title: 'Kindness Champion',
      description: 'Shared 10 happy posts with the community.',
      icon: Icons.diversity_3_rounded,
      kind: AchievementKind.community,
      threshold: 10,
      gradient: AppColors.growthGradient,
    ),
  ];

  static const List<Achievement> gratitudeMilestones = [
    Achievement(
      id: 'gratitude_7',
      title: 'Grateful Heart',
      description: 'Wrote 7 gratitude journal entries.',
      icon: Icons.favorite_rounded,
      kind: AchievementKind.gratitude,
      threshold: 7,
    ),
    Achievement(
      id: 'gratitude_30',
      title: 'Abundance Mindset',
      description: 'Wrote 30 gratitude journal entries.',
      icon: Icons.favorite_rounded,
      kind: AchievementKind.gratitude,
      threshold: 30,
      gradient: AppColors.goldGradient,
    ),
  ];

  static List<Achievement> get all => [
    ...streakMilestones,
    ...missionMilestones,
    ...communityMilestones,
    ...gratitudeMilestones,
  ];
}
