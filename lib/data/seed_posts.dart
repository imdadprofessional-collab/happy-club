import '../models/mission.dart';
import '../models/post.dart';

/// Seed community content so the Happy Feed feels alive from first launch.
/// In a production build this would be replaced by real posts fetched from
/// the backend (see BackendService).
class SeedPosts {
  SeedPosts._();

  static List<Post> generate() {
    final now = DateTime.now();
    final raw = <(String, String, String, int, MissionCategory)>[
      (
        'Maya',
        '🌻',
        'Day 42 complete! Today\'s mission had me call my mom just to talk — we ended up laughing for an hour. #HappyClub',
        42,
        MissionCategory.family,
      ),
      (
        'Jordan',
        '🌊',
        '✅ Day 15 done. Walked outside for 20 minutes and noticed the sunrise for the first time in weeks. Small habit, big shift. #HappyClub',
        15,
        MissionCategory.exercise,
      ),
      (
        'Amara',
        '🌸',
        'Wrote three things I\'m grateful for and realized how much good is already in my life. Grateful for this community. #HappyClub',
        8,
        MissionCategory.gratitude,
      ),
      (
        'Leo',
        '🔥',
        'Finally finished that task I\'ve been avoiding for two weeks. Felt so light afterward! Day 27 complete. #HappyClub',
        27,
        MissionCategory.productivity,
      ),
      (
        'Priya',
        '✨',
        'Complimented a stranger today and her whole face lit up. Kindness really is contagious. #HappyClub',
        63,
        MissionCategory.kindness,
      ),
      (
        'Sam',
        '🌿',
        'One hour off social media turned into an evening of actually being present with my family. Highly recommend. #HappyClub',
        5,
        MissionCategory.digitalDetox,
      ),
      (
        'Tasha',
        '🌈',
        'Read ten pages before bed instead of scrolling — best sleep I\'ve had in weeks. Day 19! #HappyClub',
        19,
        MissionCategory.reading,
      ),
      (
        'Diego',
        '⚡',
        'Did something that scared me a little today: spoke up in a meeting. Proud of myself. #HappyClub',
        33,
        MissionCategory.confidence,
      ),
      (
        'Nina',
        '🍃',
        'Sat outside with my coffee and just breathed for five minutes. Needed that more than I realized. #HappyClub',
        11,
        MissionCategory.mindfulness,
      ),
      (
        'Owen',
        '🌤️',
        'Helped a neighbor carry groceries up four flights of stairs. Tiny act, huge smile. Day 2! #HappyClub',
        2,
        MissionCategory.communityService,
      ),
      (
        'Chloe',
        '💫',
        'Told my best friend exactly why she matters to me. We both cried a little (happy tears). #HappyClub',
        51,
        MissionCategory.friends,
      ),
      (
        'Ravi',
        '🌅',
        'Skipped a purchase I didn\'t need and put the money into savings instead. Future me says thanks. #HappyClub',
        9,
        MissionCategory.finance,
      ),
    ];

    return List.generate(raw.length, (i) {
      final (name, emoji, text, streak, category) = raw[i];
      return Post(
        id: 'seed_$i',
        authorName: name,
        authorEmoji: emoji,
        text: text,
        postedAt: now.subtract(Duration(hours: (i + 1) * 3)),
        dayStreak: streak,
        category: category,
        reactionCounts: {
          ReactionType.love: 12 + i * 3,
          ReactionType.inspired: 4 + i,
          ReactionType.keepGoing: 6 + i,
          ReactionType.smile: 3 + i,
        },
        comments: [
          Comment(
            id: 'seed_${i}_c1',
            authorName: 'Happy Club Team',
            text: 'Love this! Keep shining. 🌟',
            postedAt: now.subtract(Duration(hours: (i + 1) * 3 - 1)),
          ),
        ],
      );
    });
  }
}
