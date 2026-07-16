import 'package:flutter/material.dart';
import '../data/achievements_data.dart';
import '../data/missions_data.dart';
import '../data/seed_posts.dart';
import '../models/achievement.dart';
import '../models/journal_entry.dart';
import '../models/mission.dart';
import '../models/post.dart';
import '../models/user_profile.dart';
import '../services/ai_coach_service.dart';
import '../services/gamification_service.dart';
import '../services/membership_service.dart';
import '../services/mission_engine.dart';
import '../services/storage_service.dart';

export '../services/membership_service.dart'
    show MembershipStatus, MembershipStatusX, MembershipPlan, MembershipPlanX;

/// Result returned from [AppState.completeTodayMission] so the celebration
/// screen can show exactly what was earned.
class MissionRewardResult {
  MissionRewardResult({
    required this.xpEarned,
    required this.coinsEarned,
    required this.isSurpriseBonus,
    required this.newStreak,
    required this.leveledUp,
    required this.newlyUnlocked,
    required this.completedMission,
  });

  final int xpEarned;
  final int coinsEarned;
  final bool isSurpriseBonus;
  final int newStreak;
  final bool leveledUp;
  final List<Achievement> newlyUnlocked;
  final CompletedMission completedMission;
}

/// Single source of truth for the whole app. A real deployment would split
/// this into repositories backed by Firebase Auth + Firestore (with this
/// class's shape mostly unchanged) — see [StorageService] for the seam.
class AppState extends ChangeNotifier {
  AppState({
    required StorageService storage,
    MissionEngine? missionEngine,
    MembershipService? membershipService,
    AiCoachService? aiCoachService,
  }) : _storage = storage,
       _missionEngine = missionEngine ?? MissionEngine(),
       _membershipService = membershipService ?? MembershipService(),
       _aiCoach = aiCoachService ?? AiCoachService();

  final StorageService _storage;
  final MissionEngine _missionEngine;
  final MembershipService _membershipService;
  final AiCoachService _aiCoach;

  AiCoachService get aiCoach => _aiCoach;

  bool isLoading = true;
  bool onboardingComplete = false;
  MembershipStatus membershipStatus = MembershipStatus.none;
  ThemeMode themeMode = ThemeMode.system;

  late UserProfile profile;

  int xp = 0;
  int coins = 0;
  int streak = 0;
  int longestStreak = 0;
  DateTime? lastCompletionDate;

  final List<CompletedMission> completedMissions = [];
  final List<Post> posts = [];
  final List<GratitudeEntry> gratitudeEntries = [];
  final List<ReflectionEntry> reflectionEntries = [];
  final List<MoodEntry> moodEntries = [];
  final Set<String> unlockedAchievementIds = {};

  int communityReactionCount = 0;
  int communityPostCount = 0;

  Mission? todayMission;
  int? todayMoodBefore;
  int? todayMoodAfter;

  bool get todayMissionCompleted {
    if (lastCompletionDate == null) return false;
    final now = DateTime.now();
    return lastCompletionDate!.year == now.year &&
        lastCompletionDate!.month == now.month &&
        lastCompletionDate!.day == now.day;
  }

  int get level => GamificationService.levelForXp(xp);
  double get levelProgress => GamificationService.levelProgress(xp);
  String get levelTitle => LevelTitle.forLevel(level);

  double get happinessScore => GamificationService.happinessScore(
    streak: streak,
    totalMissions: completedMissions.length,
    gratitudeEntries: gratitudeEntries.length,
    kindnessMissions: completedMissions
        .where((m) => GamificationService.isKindnessCategory(m.category))
        .length,
    recentMoods: moodEntries.take(14).toList(),
    communityEncouragements: communityReactionCount,
  );

  // ---------------------------------------------------------------------
  // Bootstrapping
  // ---------------------------------------------------------------------

  Future<void> init() async {
    onboardingComplete =
        _storage.getBool(StorageKeys.onboardingComplete) ?? false;

    final statusName = _storage.getString(StorageKeys.membershipStatus);
    membershipStatus = MembershipStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => MembershipStatus.none,
    );

    final themeName = _storage.getString(StorageKeys.themeMode);
    themeMode = ThemeMode.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => ThemeMode.system,
    );

    profile =
        _storage.getJson(StorageKeys.userProfile, UserProfile.fromJson) ??
        UserProfile.fresh();

    xp = _storage.getInt(StorageKeys.xp) ?? 0;
    coins = _storage.getInt(StorageKeys.coins) ?? 0;
    streak = _storage.getInt(StorageKeys.streak) ?? 0;
    longestStreak = _storage.getInt(StorageKeys.longestStreak) ?? 0;
    final lastCompletionRaw = _storage.getString(
      StorageKeys.lastCompletionDate,
    );
    lastCompletionDate = lastCompletionRaw != null
        ? DateTime.tryParse(lastCompletionRaw)
        : null;

    completedMissions
      ..clear()
      ..addAll(
        _storage
            .getJsonList(StorageKeys.completedMissions)
            .map(CompletedMission.fromJson),
      );

    gratitudeEntries
      ..clear()
      ..addAll(
        _storage
            .getJsonList(StorageKeys.gratitudeEntries)
            .map(GratitudeEntry.fromJson),
      );

    reflectionEntries
      ..clear()
      ..addAll(
        _storage
            .getJsonList(StorageKeys.reflectionEntries)
            .map(ReflectionEntry.fromJson),
      );

    moodEntries
      ..clear()
      ..addAll(
        _storage.getJsonList(StorageKeys.moodEntries).map(MoodEntry.fromJson),
      );

    unlockedAchievementIds
      ..clear()
      ..addAll(_storage.getStringList(StorageKeys.unlockedAchievements));

    communityReactionCount =
        _storage.getInt(StorageKeys.communityReactionCount) ?? 0;
    communityPostCount = _storage.getInt(StorageKeys.communityPostCount) ?? 0;

    posts
      ..clear()
      ..addAll(SeedPosts.generate());

    _resolveTodayMission();
    _resolveTodayMood();

    isLoading = false;
    notifyListeners();
  }

  void _resolveTodayMission() {
    final storedDate = _storage.getString(StorageKeys.todayMissionDate);
    final storedId = _storage.getString(StorageKeys.todayMissionId);
    final today = DateTime.now();
    final todayKey = _dateKey(today);

    if (storedDate == todayKey && storedId != null) {
      todayMission = MissionEngineLookup.byId(storedId);
    }
    todayMission ??= _missionEngine.pickMission(
      history: completedMissions,
      seed: today,
    );
    _storage.setString(StorageKeys.todayMissionDate, todayKey);
    _storage.setString(StorageKeys.todayMissionId, todayMission!.id);
  }

  void _resolveTodayMood() {
    if (moodEntries.isEmpty) return;
    final today = DateTime.now();
    final latest = moodEntries.first;
    if (_dateKey(latest.date) == _dateKey(today)) {
      todayMoodBefore = latest.before;
      todayMoodAfter = latest.after;
    }
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  // ---------------------------------------------------------------------
  // Onboarding & membership
  // ---------------------------------------------------------------------

  Future<void> completeOnboarding() async {
    onboardingComplete = true;
    await _storage.setBool(StorageKeys.onboardingComplete, true);
    notifyListeners();
  }

  Future<bool> purchaseMembership(MembershipPlan plan) async {
    final success = await _membershipService.purchase(plan);
    if (success) {
      membershipStatus = switch (plan) {
        MembershipPlan.trial => MembershipStatus.trialActive,
        MembershipPlan.monthly => MembershipStatus.monthly,
        MembershipPlan.yearly => MembershipStatus.yearly,
      };
      await _storage.setString(
        StorageKeys.membershipStatus,
        membershipStatus.name,
      );
      notifyListeners();
    }
    return success;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _storage.setString(StorageKeys.themeMode, mode.name);
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? avatarEmoji}) async {
    if (name != null) profile.name = name;
    if (avatarEmoji != null) profile.avatarEmoji = avatarEmoji;
    await _storage.setJson(StorageKeys.userProfile, profile.toJson());
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Mood
  // ---------------------------------------------------------------------

  Future<void> recordMoodBefore(int value) async {
    final today = DateTime.now();
    if (moodEntries.isEmpty ||
        _dateKey(moodEntries.first.date) != _dateKey(today)) {
      moodEntries.insert(0, MoodEntry(date: today, before: value));
    }
    todayMoodBefore = value;
    await _persistMood();
    notifyListeners();
  }

  Future<void> recordMoodAfter(int value) async {
    final today = DateTime.now();
    if (moodEntries.isNotEmpty &&
        _dateKey(moodEntries.first.date) == _dateKey(today)) {
      moodEntries.first.after = value;
    } else {
      moodEntries.insert(
        0,
        MoodEntry(date: today, before: value, after: value),
      );
    }
    todayMoodAfter = value;
    await _persistMood();
    notifyListeners();
  }

  Future<void> _persistMood() => _storage.setJsonList(
    StorageKeys.moodEntries,
    moodEntries.map((e) => e.toJson()).toList(),
  );

  // ---------------------------------------------------------------------
  // Mission completion
  // ---------------------------------------------------------------------

  Future<MissionRewardResult> completeTodayMission({String? note}) async {
    final mission = todayMission!;
    final today = DateTime.now();
    final levelBefore = level;

    streak = GamificationService.nextStreak(
      lastCompletion: lastCompletionDate,
      currentStreak: streak,
      today: today,
    );
    longestStreak = streak > longestStreak ? streak : longestStreak;
    lastCompletionDate = today;

    final reward = GamificationService.rewardForCompletion(streak: streak);
    xp += reward.xp;
    coins += reward.coins;

    final completed = CompletedMission(
      missionId: mission.id,
      missionTitle: mission.title,
      category: mission.category,
      completedAt: today,
    );
    completedMissions.insert(0, completed);

    final newlyUnlocked = _checkAchievements();

    await Future.wait([
      _storage.setInt(StorageKeys.xp, xp),
      _storage.setInt(StorageKeys.coins, coins),
      _storage.setInt(StorageKeys.streak, streak),
      _storage.setInt(StorageKeys.longestStreak, longestStreak),
      _storage.setString(
        StorageKeys.lastCompletionDate,
        today.toIso8601String(),
      ),
      _storage.setJsonList(
        StorageKeys.completedMissions,
        completedMissions.map((m) => m.toJson()).toList(),
      ),
      _storage.setStringList(
        StorageKeys.unlockedAchievements,
        unlockedAchievementIds.toList(),
      ),
    ]);

    notifyListeners();

    return MissionRewardResult(
      xpEarned: reward.xp,
      coinsEarned: reward.coins,
      isSurpriseBonus: reward.isSurpriseBonus,
      newStreak: streak,
      leveledUp: level > levelBefore,
      newlyUnlocked: newlyUnlocked,
      completedMission: completed,
    );
  }

  List<Achievement> _checkAchievements() {
    final unlocked = <Achievement>[];
    for (final a in AchievementsData.all) {
      if (unlockedAchievementIds.contains(a.id)) continue;
      final progress = switch (a.kind) {
        AchievementKind.streak => streak,
        AchievementKind.missions => completedMissions.length,
        AchievementKind.gratitude => gratitudeEntries.length,
        AchievementKind.kindness =>
          completedMissions
              .where((m) => GamificationService.isKindnessCategory(m.category))
              .length,
        AchievementKind.community =>
          communityReactionCount + communityPostCount,
        AchievementKind.level => level,
      };
      if (progress >= a.threshold) {
        unlockedAchievementIds.add(a.id);
        unlocked.add(a);
      }
    }
    return unlocked;
  }

  // ---------------------------------------------------------------------
  // Community feed
  // ---------------------------------------------------------------------

  String buildAutoPostText(CompletedMission mission) {
    final dayLabel = 'Day $streak';
    return '✅ $dayLabel Complete\n\n'
        '${mission.missionTitle}\n\n'
        'One small habit can change everything.\n#HappyClub';
  }

  Future<void> publishAutoPost(String text) async {
    final post = Post(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      authorName: profile.name,
      authorEmoji: profile.avatarEmoji,
      text: text,
      postedAt: DateTime.now(),
      dayStreak: streak,
      category: completedMissions.isNotEmpty
          ? completedMissions.first.category
          : null,
      isCurrentUser: true,
    );
    posts.insert(0, post);
    communityPostCount++;
    await _storage.setInt(StorageKeys.communityPostCount, communityPostCount);
    _checkAchievements();
    notifyListeners();
  }

  Future<void> reactToPost(Post post, ReactionType reaction) async {
    if (post.userReaction == reaction) {
      post.reactionCounts[reaction] = (post.reactionCounts[reaction] ?? 1) - 1;
      post.userReaction = null;
    } else {
      if (post.userReaction != null) {
        final prev = post.userReaction!;
        post.reactionCounts[prev] = (post.reactionCounts[prev] ?? 1) - 1;
      } else {
        communityReactionCount++;
        await _storage.setInt(
          StorageKeys.communityReactionCount,
          communityReactionCount,
        );
        _checkAchievements();
      }
      post.reactionCounts[reaction] = (post.reactionCounts[reaction] ?? 0) + 1;
      post.userReaction = reaction;
    }
    notifyListeners();
  }

  void addComment(Post post, String text) {
    post.comments.add(
      Comment(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        authorName: profile.name,
        text: text,
        postedAt: DateTime.now(),
        isCurrentUser: true,
      ),
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Journals
  // ---------------------------------------------------------------------

  Future<void> addGratitudeEntry(
    List<String> items, {
    bool isPublic = false,
  }) async {
    final entry = GratitudeEntry(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      items: items,
      isPublic: isPublic,
    );
    gratitudeEntries.insert(0, entry);
    _checkAchievements();
    await _storage.setJsonList(
      StorageKeys.gratitudeEntries,
      gratitudeEntries.map((e) => e.toJson()).toList(),
    );
    await _storage.setStringList(
      StorageKeys.unlockedAchievements,
      unlockedAchievementIds.toList(),
    );
    notifyListeners();
  }

  Future<void> addReflectionEntry({
    required String meaningful,
    required String proud,
    required String improve,
  }) async {
    final entry = ReflectionEntry(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      meaningful: meaningful,
      proud: proud,
      improve: improve,
    );
    reflectionEntries.insert(0, entry);
    await _storage.setJsonList(
      StorageKeys.reflectionEntries,
      reflectionEntries.map((e) => e.toJson()).toList(),
    );
    notifyListeners();
  }
}

/// Resolves a persisted mission id back to a [Mission].
class MissionEngineLookup {
  MissionEngineLookup._();

  static Mission? byId(String id) {
    for (final m in MissionsData.all) {
      if (m.id == id) return m;
    }
    return null;
  }
}
