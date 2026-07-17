import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';
import '../models/mission.dart';
import '../models/post.dart';

/// Firestore-backed sync layer, used alongside (not instead of)
/// [StorageService]: local storage stays the fast, always-available source
/// of truth, and this service best-effort mirrors writes to Firestore and
/// pulls remote state down when a user signs in, so data can follow a user
/// across devices. Every method is designed to be safe to call from a
/// fire-and-forget context — callers should catch/ignore failures rather
/// than block the local UX on network state.
class FirestoreService {
  // A getter, not a field initializer: constructing FirestoreService (which
  // happens unconditionally inside AppState) must not itself touch Firebase,
  // so plain local/offline usage — including widget tests that never call
  // Firebase.initializeApp() — keeps working. Firebase is only touched once
  // a method below actually runs.
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _postsCol() =>
      _db.collection('posts');

  // ---------------------------------------------------------------------
  // User profile + gamification state (one doc per user)
  // ---------------------------------------------------------------------

  Future<Map<String, dynamic>?> loadUserDoc(String uid) async {
    final snap = await _userDoc(uid).get();
    return snap.data();
  }

  Future<void> saveUserDoc(String uid, Map<String, dynamic> data) {
    return _userDoc(uid).set(data, SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------
  // Completed missions
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _missionsCol(String uid) =>
      _userDoc(uid).collection('completedMissions');

  Future<void> addCompletedMission(String uid, CompletedMission mission) {
    return _missionsCol(uid)
        .doc(
          '${mission.missionId}_${mission.completedAt.millisecondsSinceEpoch}',
        )
        .set(mission.toJson());
  }

  Future<List<CompletedMission>> loadCompletedMissions(String uid) async {
    final snap = await _missionsCol(
      uid,
    ).orderBy('completedAt', descending: true).limit(500).get();
    return snap.docs.map((d) => CompletedMission.fromJson(d.data())).toList();
  }

  // ---------------------------------------------------------------------
  // Gratitude journal
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _gratitudeCol(String uid) =>
      _userDoc(uid).collection('gratitudeEntries');

  Future<void> addGratitudeEntry(String uid, GratitudeEntry entry) {
    return _gratitudeCol(uid).doc(entry.id).set(entry.toJson());
  }

  Future<List<GratitudeEntry>> loadGratitudeEntries(String uid) async {
    final snap = await _gratitudeCol(
      uid,
    ).orderBy('date', descending: true).limit(500).get();
    return snap.docs.map((d) => GratitudeEntry.fromJson(d.data())).toList();
  }

  // ---------------------------------------------------------------------
  // Reflection journal
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _reflectionCol(String uid) =>
      _userDoc(uid).collection('reflectionEntries');

  Future<void> addReflectionEntry(String uid, ReflectionEntry entry) {
    return _reflectionCol(uid).doc(entry.id).set(entry.toJson());
  }

  Future<List<ReflectionEntry>> loadReflectionEntries(String uid) async {
    final snap = await _reflectionCol(
      uid,
    ).orderBy('date', descending: true).limit(500).get();
    return snap.docs.map((d) => ReflectionEntry.fromJson(d.data())).toList();
  }

  // ---------------------------------------------------------------------
  // Mood entries — keyed by calendar day so re-saving "today" upserts.
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _moodCol(String uid) =>
      _userDoc(uid).collection('moodEntries');

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<void> upsertMoodEntry(String uid, MoodEntry entry) {
    return _moodCol(
      uid,
    ).doc(_dayKey(entry.date)).set(entry.toJson(), SetOptions(merge: true));
  }

  Future<List<MoodEntry>> loadMoodEntries(String uid) async {
    final snap = await _moodCol(
      uid,
    ).orderBy('date', descending: true).limit(500).get();
    return snap.docs.map((d) => MoodEntry.fromJson(d.data())).toList();
  }

  // ---------------------------------------------------------------------
  // Happy Feed (shared across all users)
  // ---------------------------------------------------------------------

  Future<void> publishPost(Post post) {
    return _postsCol().doc(post.id).set(post.toJson());
  }

  Future<List<Post>> loadRecentPosts({
    int limit = 30,
    String? currentUid,
  }) async {
    final snap = await _postsCol()
        .orderBy('postedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => Post.fromJson(d.data(), currentUid: currentUid))
        .toList();
  }

  Future<void> setReactionCount(
    String postId,
    Map<ReactionType, int> reactionCounts,
  ) {
    return _postsCol().doc(postId).update({
      'reactionCounts': reactionCounts.map((k, v) => MapEntry(k.name, v)),
    });
  }

  Future<void> addComment(String postId, Comment comment) {
    return _postsCol()
        .doc(postId)
        .collection('comments')
        .doc(comment.id)
        .set(comment.toJson());
  }
}
