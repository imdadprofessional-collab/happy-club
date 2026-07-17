import 'mission.dart';

enum ReactionType { love, care, applaud, inspired, keepGoing, smile }

extension ReactionTypeX on ReactionType {
  String get emoji {
    switch (this) {
      case ReactionType.love:
        return '❤️';
      case ReactionType.care:
        return '🤗';
      case ReactionType.applaud:
        return '👏';
      case ReactionType.inspired:
        return '🌟';
      case ReactionType.keepGoing:
        return '💪';
      case ReactionType.smile:
        return '😊';
    }
  }

  String get label {
    switch (this) {
      case ReactionType.love:
        return 'Love';
      case ReactionType.care:
        return 'Care';
      case ReactionType.applaud:
        return 'Applaud';
      case ReactionType.inspired:
        return 'Inspired';
      case ReactionType.keepGoing:
        return 'Keep Going';
      case ReactionType.smile:
        return 'Smile';
    }
  }
}

class Comment {
  Comment({
    required this.id,
    required this.authorName,
    required this.text,
    required this.postedAt,
    this.isCurrentUser = false,
    this.authorUid,
  });

  final String id;
  final String authorName;
  final String text;
  final DateTime postedAt;
  final bool isCurrentUser;
  final String? authorUid;

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorName': authorName,
    'text': text,
    'postedAt': postedAt.toIso8601String(),
    'authorUid': authorUid,
  };

  factory Comment.fromJson(Map<String, dynamic> json, {String? currentUid}) =>
      Comment(
        id: json['id'] as String,
        authorName: json['authorName'] as String,
        text: json['text'] as String,
        postedAt: DateTime.parse(json['postedAt'] as String),
        authorUid: json['authorUid'] as String?,
        isCurrentUser: currentUid != null && json['authorUid'] == currentUid,
      );
}

class Post {
  Post({
    required this.id,
    required this.authorName,
    required this.authorEmoji,
    required this.text,
    required this.postedAt,
    this.dayStreak,
    this.category,
    this.isCurrentUser = false,
    this.authorUid,
    Map<ReactionType, int>? reactionCounts,
    this.userReaction,
    List<Comment>? comments,
  }) : reactionCounts = reactionCounts ?? {},
       comments = comments ?? [];

  final String id;
  final String authorName;
  final String authorEmoji;
  final String text;
  final DateTime postedAt;
  final int? dayStreak;
  final MissionCategory? category;
  final bool isCurrentUser;
  final String? authorUid;
  final Map<ReactionType, int> reactionCounts;
  ReactionType? userReaction;
  final List<Comment> comments;

  int get totalReactions => reactionCounts.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorName': authorName,
    'authorEmoji': authorEmoji,
    'text': text,
    'postedAt': postedAt.toIso8601String(),
    'dayStreak': dayStreak,
    'category': category?.name,
    'authorUid': authorUid,
    'reactionCounts': reactionCounts.map((k, v) => MapEntry(k.name, v)),
  };

  factory Post.fromJson(Map<String, dynamic> json, {String? currentUid}) {
    final categoryName = json['category'] as String?;
    final rawCounts =
        (json['reactionCounts'] as Map?)?.cast<String, dynamic>() ?? {};
    return Post(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      authorEmoji: json['authorEmoji'] as String,
      text: json['text'] as String,
      postedAt: DateTime.parse(json['postedAt'] as String),
      dayStreak: json['dayStreak'] as int?,
      category: categoryName == null
          ? null
          : MissionCategory.values.firstWhere(
              (c) => c.name == categoryName,
              orElse: () => MissionCategory.gratitude,
            ),
      authorUid: json['authorUid'] as String?,
      isCurrentUser: currentUid != null && json['authorUid'] == currentUid,
      reactionCounts: {
        for (final entry in rawCounts.entries)
          ReactionType.values.firstWhere((r) => r.name == entry.key):
              entry.value as int,
      },
    );
  }
}
