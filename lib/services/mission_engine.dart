import 'dart:math';
import '../data/missions_data.dart';
import '../models/mission.dart';

/// Picks the day's mission while avoiding recent repeats and gently
/// rotating through categories, so the daily habit stays fresh over time.
class MissionEngine {
  static const int _lookback = 40;

  /// Chooses a mission for [seed] (typically today's date) given the
  /// [history] of previously-completed missions, most recent first.
  /// Deterministic in [seed] so the same day always yields the same pick.
  Mission pickMission({
    required List<CompletedMission> history,
    required DateTime seed,
  }) {
    final recentIds = history.take(_lookback).map((m) => m.missionId).toSet();
    final recentCategories = history.take(6).map((m) => m.category).toList();

    var candidates = MissionsData.all
        .where((m) => !recentIds.contains(m.id))
        .toList();
    if (candidates.isEmpty) {
      candidates = List.of(MissionsData.all);
    }

    // Prefer categories that haven't shown up in the last few days, so the
    // mix feels varied rather than clustering on one theme.
    final fresh = candidates
        .where((m) => !recentCategories.contains(m.category))
        .toList();
    final pool = fresh.isNotEmpty ? fresh : candidates;

    final seededRandom = Random(
      seed.year * 10000 + seed.month * 100 + seed.day,
    );
    return pool[seededRandom.nextInt(pool.length)];
  }
}
