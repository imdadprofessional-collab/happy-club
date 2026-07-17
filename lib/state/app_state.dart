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
import '../services/firestore_service.dart';
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
    required this.freezeUsed,
  });

  final int xpEarned;
  final int coinsEarned;
  final bool isSurpriseBonus;
  final int newStreak;
  final bool leveledUp;
  final List<Achievement> newlyUnlocked;
  final CompletedMission completedMission;
  final bool freezeUsed;
}

/// Single source of truth for the whole app. A real deployment would split
/// this into repositories backed by Firebase Auth + Firestore (with this
/// class's shape mostly unchanged) — see [StorageService] for the seam.
class AppState extends ChangeNotifier {
  /// Coin price of a single streak freeze for non-members. Premium members
  /// also get one free with every purchase (see [purchaseMembership]).
  static const int streakFreezeCoinCost = 150;

  /// A soft, non-blocking upgrade offer appears once the user has proven
  /// out the habit loop — after this many completed missions — rather than
  /// gating the app before they've felt any value.
  static const int upgradeOfferMissionThreshold = 3;

  AppState({
    required StorageService storage,
    MissionEngine? missionEngine,
    MembershipService? membershipService,
    AiCoachService? aiCoachService,
    FirestoreService? firestoreService,
  }) : // `this._storage` would make the named parameter itself private
       // (`_storage`), which other libraries (e.g. main.dart) can't pass by
       // name — so this stays a manual assignment instead.
       // ignore: prefer_initializing_formals
       _storage = storage,
       _missionEngine = missionEngine ?? MissionEngine(),
       _membershipService = membershipService ?? MembershipService(),
       _aiCoach = aiCoachService ?? AiCoachService(),
       _firestore = firestoreService ?? FirestoreService();

  final StorageService _storage;
  final MissionEngine _missionEngine;
  final MembershipService _membershipService;
  final AiCoachService _aiCoach;
  final FirestoreService _firestore;

  AiCoachService get aiCoach => _aiCoach;

  /// Firebase Auth uid once signed in via [attachUser], or null while
  /// running purely on local storage. Mutations mirror to Firestore
  /// (best-effort, fire-and-forget) only when this is set.
  String? uid;
  bool get isSignedIn => uid != null;

  bool isLoading = true;
  bool onboardingComplete = false;
  MembershipStatus membershipStatus = MembershipStatus.none;
  ThemeMode themeMode = ThemeMode.system;

  late UserProfile profile;

  int xp = 0;
  int coins = 0;
  int streak = 0;
  int longestStreak = 0;
  int streakFreezes = 0;
  bool upgradeOfferShown = false;
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

  /// True once the user has real momentum (a few completed missions) but
  /// isn't a member yet and hasn't already dismissed the one-time offer —
  /// the trigger point for the soft, post-engagement upgrade prompt.
  bool get shouldShowUpgradeOffer =>
      !membershipStatus.isActive &&
      !upgradeOfferShown &&
      completedMissions.length >= upgradeOfferMissionThreshold;

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
    streakFreezes = _storage.getInt(StorageKeys.streakFreezes) ?? 0;
    upgradeOfferShown =
        _storage.getBool(StorageKeys.upgradeOfferShown) ?? false;
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
  // Firebase account sync
  // ---------------------------------------------------------------------

  /// Called after a successful Firebase sign-in. If the account already has
  /// data in Firestore (returning user / another device), that data wins
  /// and replaces local state. Otherwise, this device's current local state
  /// is pushed up as the account's first snapshot. This is a simple
  /// "remote wins if present" strategy, not field-level merge — good enough
  /// for a single-device-at-a-time app, but a real multi-device product
  /// would want conflict resolution.
  Future<void> attachUser({required String newUid, String? email}) async {
    uid = newUid;
    try {
      final remote = await _firestore.loadUserDoc(newUid);
      if (remote != null) {
        await _hydrateFromRemote(newUid, remote);
      } else {
        await _pushFullStateToRemote(newUid);
      }
      final remotePosts = await _firestore.loadRecentPosts(currentUid: newUid);
      if (remotePosts.isNotEmpty) {
        final existingIds = posts.map((p) => p.id).toSet();
        posts.insertAll(
          0,
          remotePosts.where((p) => !existingIds.contains(p.id)),
        );
      }
    } catch (_) {
      // Offline or first-run permissions hiccup — keep going on local data.
    }
    notifyListeners();
  }

  /// Signs the local session out of the synced account without deleting
  /// locally cached data — the app keeps working offline/local-only.
  void detachUser() {
    uid = null;
    notifyListeners();
  }

  Future<void> _hydrateFromRemote(
    String remoteUid,
    Map<String, dynamic> data,
  ) async {
    if (data['name'] != null) profile.name = data['name'] as String;
    if (data['avatarEmoji'] != null) {
      profile.avatarEmoji = data['avatarEmoji'] as String;
    }
    xp = data['xp'] as int? ?? xp;
    coins = data['coins'] as int? ?? coins;
    streak = data['streak'] as int? ?? streak;
    longestStreak = data['longestStreak'] as int? ?? longestStreak;
    streakFreezes = data['streakFreezes'] as int? ?? streakFreezes;
    final lastCompletionRaw = data['lastCompletionDate'] as String?;
    if (lastCompletionRaw != null) {
      lastCompletionDate = DateTime.tryParse(lastCompletionRaw);
    }
    final statusName = data['membershipStatus'] as String?;
    if (statusName != null) {
      membershipStatus = MembershipStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => membershipStatus,
      );
    }
    communityReactionCount =
        data['communityReactionCount'] as int? ?? communityReactionCount;
    communityPostCount =
        data['communityPostCount'] as int? ?? communityPostCount;
    final unlocked = (data['unlockedAchievementIds'] as List?)?.cast<String>();
    if (unlocked != null) {
      unlockedAchievementIds
        ..clear()
        ..addAll(unlocked);
    }

    final remoteMissions = await _firestore.loadCompletedMissions(remoteUid);
    if (remoteMissions.isNotEmpty) {
      completedMissions
        ..clear()
        ..addAll(remoteMissions);
    }
    final remoteGratitude = await _firestore.loadGratitudeEntries(remoteUid);
    if (remoteGratitude.isNotEmpty) {
      gratitudeEntries
        ..clear()
        ..addAll(remoteGratitude);
    }
    final remoteReflections = await _firestore.loadReflectionEntries(remoteUid);
    if (remoteReflections.isNotEmpty) {
      reflectionEntries
        ..clear()
        ..addAll(remoteReflections);
    }
    final remoteMoods = await _firestore.loadMoodEntries(remoteUid);
    if (remoteMoods.isNotEmpty) {
      moodEntries
        ..clear()
        ..addAll(remoteMoods);
    }

    await _persistEverythingLocally();
    _resolveTodayMission();
    _resolveTodayMood();
  }

  Future<void> _pushFullStateToRemote(String remoteUid) async {
    await _firestore.saveUserDoc(remoteUid, _userDocSnapshot());
    for (final m in completedMissions) {
      await _firestore.addCompletedMission(remoteUid, m);
    }
    for (final g in gratitudeEntries) {
      await _firestore.addGratitudeEntry(remoteUid, g);
    }
    for (final r in reflectionEntries) {
      await _firestore.addReflectionEntry(remoteUid, r);
    }
    for (final mood in moodEntries) {
      await _firestore.upsertMoodEntry(remoteUid, mood);
    }
  }

  Map<String, dynamic> _userDocSnapshot() => {
    'name': profile.name,
    'avatarEmoji': profile.avatarEmoji,
    'xp': xp,
    'coins': coins,
    'streak': streak,
    'longestStreak': longestStreak,
    'streakFreezes': streakFreezes,
    'lastCompletionDate': lastCompletionDate?.toIso8601String(),
    'membershipStatus': membershipStatus.name,
    'communityReactionCount': communityReactionCount,
    'communityPostCount': communityPostCount,
    'unlockedAchievementIds': unlockedAchievementIds.toList(),
  };

  /// Best-effort mirror of the user doc to Firestore; never throws.
  void _syncUserDoc() {
    final currentUid = uid;
    if (currentUid == null) return;
    _firestore.saveUserDoc(currentUid, _userDocSnapshot()).catchError((_) {});
  }

  Future<void> _persistEverythingLocally() async {
    await Future.wait([
      _storage.setJson(StorageKeys.userProfile, profile.toJson()),
      _storage.setInt(StorageKeys.xp, xp),
      _storage.setInt(StorageKeys.coins, coins),
      _storage.setInt(StorageKeys.streak, streak),
      _storage.setInt(StorageKeys.longestStreak, longestStreak),
      _storage.setInt(StorageKeys.streakFreezes, streakFreezes),
      if (lastCompletionDate != null)
        _storage.setString(
          StorageKeys.lastCompletionDate,
          lastCompletionDate!.toIso8601String(),
        ),
      _storage.setString(StorageKeys.membershipStatus, membershipStatus.name),
      _storage.setJsonList(
        StorageKeys.completedMissions,
        completedMissions.map((m) => m.toJson()).toList(),
      ),
      _storage.setJsonList(
        StorageKeys.gratitudeEntries,
        gratitudeEntries.map((e) => e.toJson()).toList(),
      ),
      _storage.setJsonList(
        StorageKeys.reflectionEntries,
        reflectionEntries.map((e) => e.toJson()).toList(),
      ),
      _storage.setJsonList(
        StorageKeys.moodEntries,
        moodEntries.map((e) => e.toJson()).toList(),
      ),
      _storage.setStringList(
        StorageKeys.unlockedAchievements,
        unlockedAchievementIds.toList(),
      ),
      _storage.setInt(
        StorageKeys.communityReactionCount,
        communityReactionCount,
      ),
      _storage.setInt(StorageKeys.communityPostCount, communityPostCount),
    ]);
  }

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
      streakFreezes += 1; // welcome perk for new members
      await Future.wait([
        _storage.setString(
          StorageKeys.membershipStatus,
          membershipStatus.name,
        ),
        _storage.setInt(StorageKeys.streakFreezes, streakFreezes),
      ]);
      _syncUserDoc();
      notifyListeners();
    }
    return success;
  }

  /// Marks the one-time, post-engagement upgrade offer as seen so it never
  /// interrupts the user again (they can still open the paywall manually
  /// from their profile at any time).
  Future<void> markUpgradeOfferShown() async {
    upgradeOfferShown = true;
    await _storage.setBool(StorageKeys.upgradeOfferShown, true);
  }

  /// Lets free users buy a streak freeze directly with coins instead of
  /// subscribing — a small monetization lever that also keeps non-payers
  /// engaged enough to come back and try the paid tier later.
  Future<bool> buyStreakFreeze() async {
    if (coins < streakFreezeCoinCost) return false;
    coins -= streakFreezeCoinCost;
    streakFreezes += 1;
    await Future.wait([
      _storage.setInt(StorageKeys.coins, coins),
      _storage.setInt(StorageKeys.streakFreezes, streakFreezes),
    ]);
    _syncUserDoc();
    notifyListeners();
    return true;
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
    _syncUserDoc();
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
    if (uid != null) {
      _firestore.upsertMoodEntry(uid!, moodEntries.first).catchError((_) {});
    }
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
    if (uid != null) {
      _firestore.upsertMoodEntry(uid!, moodEntries.first).catchError((_) {});
    }
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

    final streakResult = GamificationService.nextStreak(
      lastCompletion: lastCompletionDate,
      currentStreak: streak,
      today: today,
      freezesAvailable: streakFreezes,
    );
    streak = streakResult.streak;
    if (streakResult.freezeUsed) streakFreezes -= 1;
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
      _storage.setInt(StorageKeys.streakFreezes, streakFreezes),
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

    if (uid != null) {
      _firestore.addCompletedMission(uid!, completed).catchError((_) {});
      _syncUserDoc();
    }

    notifyListeners();

    return MissionRewardResult(
      xpEarned: reward.xp,
      coinsEarned: reward.coins,
      isSurpriseBonus: reward.isSurpriseBonus,
      newStreak: streak,
      leveledUp: level > levelBefore,
      newlyUnlocked: newlyUnlocked,
      completedMission: completed,
      freezeUsed: streakResult.freezeUsed,
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
      authorUid: uid,
    );
    posts.insert(0, post);
    communityPostCount++;
    await _storage.setInt(StorageKeys.communityPostCount, communityPostCount);
    _checkAchievements();
    if (uid != null) {
      _firestore.publishPost(post).catchError((_) {});
      _syncUserDoc();
    }
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
    if (uid != null && post.authorUid != null) {
      _firestore
          .setReactionCount(post.id, post.reactionCounts)
          .catchError((_) {});
      _syncUserDoc();
    }
    notifyListeners();
  }

  void addComment(Post post, String text) {
    final comment = Comment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      authorName: profile.name,
      text: text,
      postedAt: DateTime.now(),
      isCurrentUser: true,
      authorUid: uid,
    );
    post.comments.add(comment);
    if (uid != null && post.authorUid != null) {
      _firestore.addComment(post.id, comment).catchError((_) {});
    }
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
    if (uid != null) {
      _firestore.addGratitudeEntry(uid!, entry).catchError((_) {});
      _syncUserDoc();
    }
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
    if (uid != null) {
      _firestore.addReflectionEntry(uid!, entry).catchError((_) {});
    }
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
