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
  });

  final String id;
  final String authorName;
  final String text;
  final DateTime postedAt;
  final bool isCurrentUser;
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
  final Map<ReactionType, int> reactionCounts;
  ReactionType? userReaction;
  final List<Comment> comments;

  int get totalReactions => reactionCounts.values.fold(0, (a, b) => a + b);
}
