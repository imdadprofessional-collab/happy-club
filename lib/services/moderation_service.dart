/// Lightweight client-side moderation for the Happy Feed.
///
/// This is a first line of defense (instant feedback while typing); a real
/// deployment must also run server-side moderation (e.g. a hosted content
/// classifier) before anything becomes publicly visible, since a
/// client-only filter can always be bypassed.
class ModerationService {
  ModerationService._();

  static const List<String> _blockedWords = [
    'idiot',
    'stupid',
    'hate you',
    'kill',
    'die',
    'ugly',
    'loser',
    'dumb',
    'shut up',
    'worthless',
  ];

  static bool containsDisallowedContent(String text) {
    final lower = text.toLowerCase();
    return _blockedWords.any(lower.contains);
  }

  /// Returns a user-facing reason if the text should be blocked, or null if
  /// it's fine to post/comment.
  static String? validate(String text) {
    if (text.trim().isEmpty) return 'Say something to share with the club!';
    if (containsDisallowedContent(text)) {
      return 'Let\'s keep Happy Club kind. Try rephrasing with encouragement in mind.';
    }
    return null;
  }
}
