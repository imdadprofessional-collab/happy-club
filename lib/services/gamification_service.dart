import 'dart:math';
import '../models/journal_entry.dart';
import '../models/mission.dart';

/// XP, leveling, streak, coin, and happiness-score math in one place so the
/// rules stay consistent across the home screen, profile, and celebrations.
class GamificationService {
  GamificationService._();

  static const int baseMissionXp = 30;
  static const int baseMissionCoins = 10;

  /// XP required to go from [level] to [level] + 1.
  static int xpForLevel(int level) => 100 + (level - 1) * 40;

  /// Total level reached given cumulative [totalXp].
  static int levelForXp(int totalXp) {
    var level = 1;
    var remaining = totalXp;
    while (remaining >= xpForLevel(level)) {
      remaining -= xpForLevel(level);
      level++;
    }
    return level;
  }

  /// XP earned so far within the current level (0 <= value < xpForLevel(level)).
  static int xpIntoCurrentLevel(int totalXp) {
    var remaining = totalXp;
    var level = 1;
    while (remaining >= xpForLevel(level)) {
      remaining -= xpForLevel(level);
      level++;
    }
    return remaining;
  }

  static double levelProgress(int totalXp) {
    final level = levelForXp(totalXp);
    return xpIntoCurrentLevel(totalXp) / xpForLevel(level);
  }

  /// A little bonus randomness so completion feels alive without being
  /// exploitable — surprise coin/XP bonuses referenced in the product spec.
  static ({int xp, int coins, bool isSurpriseBonus}) rewardForCompletion({
    int? streak,
  }) {
    final random = Random();
    final streakBonus = streak != null ? min(streak, 20) : 0;
    var xp = baseMissionXp + streakBonus;
    var coins = baseMissionCoins;
    final isSurprise = random.nextDouble() < 0.18;
    if (isSurprise) {
      xp += 25;
      coins += 20;
    }
    return (xp: xp, coins: coins, isSurpriseBonus: isSurprise);
  }

  /// Computes the new streak count given the last completion date, spending
  /// a streak freeze (if one is available) to bridge exactly one missed day
  /// instead of resetting to 1 — the loss-aversion safety net members can
  /// stock up on.
  static ({int streak, bool freezeUsed}) nextStreak({
    required DateTime? lastCompletion,
    required int currentStreak,
    required DateTime today,
    int freezesAvailable = 0,
  }) {
    if (lastCompletion == null) return (streak: 1, freezeUsed: false);
    final last = DateTime(
      lastCompletion.year,
      lastCompletion.month,
      lastCompletion.day,
    );
    final now = DateTime(today.year, today.month, today.day);
    final diff = now.difference(last).inDays;
    if (diff == 0) {
      // already completed today
      return (streak: currentStreak == 0 ? 1 : currentStreak, freezeUsed: false);
    }
    if (diff == 1) return (streak: currentStreak + 1, freezeUsed: false);
    if (diff == 2 && freezesAvailable > 0) {
      return (streak: currentStreak + 1, freezeUsed: true);
    }
    return (streak: 1, freezeUsed: false); // streak broken, restart
  }

  /// A private wellbeing-oriented score (0-100), not a competitive metric.
  static double happinessScore({
    required int streak,
    required int totalMissions,
    required int gratitudeEntries,
    required int kindnessMissions,
    required List<MoodEntry> recentMoods,
    required int communityEncouragements,
  }) {
    var score = 0.0;
    score += min(streak * 1.4, 28); // consistency
    score += min(totalMissions * 0.35, 22); // completion volume
    score += min(gratitudeEntries * 1.1, 15); // gratitude
    score += min(kindnessMissions * 1.3, 12); // acts of kindness
    score += min(communityEncouragements * 0.4, 8); // community encouragement

    if (recentMoods.isNotEmpty) {
      final improvements = recentMoods
          .where((m) => m.after != null && m.after! > m.before)
          .length;
      final avgMood =
          recentMoods.map((m) => m.after ?? m.before).reduce((a, b) => a + b) /
          recentMoods.length;
      score += min(improvements * 1.2, 8);
      score += min(avgMood * 1.4, 7);
    }
    return score.clamp(0, 100);
  }

  static bool isKindnessCategory(MissionCategory category) =>
      category == MissionCategory.kindness ||
      category == MissionCategory.communityService;
}
