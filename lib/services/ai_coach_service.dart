import 'dart:math';
import '../models/mission.dart';

/// Template-driven "AI Happiness Coach".
///
/// This ships fully offline so the coaching experience always works, using
/// curated response templates instead of a live model. To upgrade to a real
/// LLM-backed coach, swap the body of these methods for calls to a backend
/// endpoint that proxies the Claude API (never call a model API directly
/// from the client with an embedded key) — the method signatures here are
/// deliberately the integration seam for that change.
class AiCoachService {
  AiCoachService({Random? random}) : _random = random ?? Random();

  final Random _random;

  String dailyEncouragement({required String name, required int streak}) {
    final lines = streak >= 3
        ? [
            "$name, $streak days in a row — that's not luck, that's who you're becoming.",
            "Every streak day is proof you keep your promises to yourself, $name.",
            'You showed up again, $name. That consistency is the whole game.',
          ]
        : [
            "Hey $name, today is a great day for one small positive step.",
            'No pressure, $name — just one meaningful action today.',
            "$name, small starts are still starts. Let's go.",
          ];
    return lines[_random.nextInt(lines.length)];
  }

  String reflectionPrompt() {
    const prompts = [
      'What is one moment from today you\'d like to remember?',
      'Where did you show yourself kindness today?',
      'What\'s one thing that felt lighter today than yesterday?',
      'If today had a headline, what would it say?',
      'What\'s one small win you almost overlooked?',
    ];
    return prompts[_random.nextInt(prompts.length)];
  }

  String missionSuggestion(MissionCategory recentFocus) {
    return 'Since you\'ve been focused on ${recentFocus.label.toLowerCase()} lately, '
        'consider mixing in something from a different category tomorrow — variety keeps habits sticky.';
  }

  String weeklySummary({
    required int missionsCompleted,
    required int streak,
    required double happinessScore,
  }) {
    final trend = happinessScore >= 60
        ? 'trending upward'
        : 'still building momentum';
    return 'This week you completed $missionsCompleted mission${missionsCompleted == 1 ? '' : 's'} '
        'and kept a $streak-day streak alive. Your happiness score is $trend. '
        'Keep stacking small wins — they compound faster than they feel.';
  }

  /// Very small keyword-based conversational responder for the coach chat.
  String respond(String userMessage) {
    final text = userMessage.toLowerCase();
    if (text.contains('sad') ||
        text.contains('down') ||
        text.contains('depress')) {
      return "I'm really glad you shared that. Happy Club isn't a substitute for professional support, "
          "but I'm here to help you find one small positive step today. Would a gratitude entry or a short walk feel doable right now?";
    }
    if (text.contains('tired') || text.contains('exhaust')) {
      return "Rest is productive too. Maybe today's win is simply an earlier bedtime — that counts.";
    }
    if (text.contains('thank')) {
      return "You're so welcome. Showing up for yourself today is worth celebrating.";
    }
    if (text.contains('streak') || text.contains('missed')) {
      return "One missed day doesn't erase your progress — it's a single data point, not your whole story. Let's restart today.";
    }
    return "I hear you. Want a mission suggestion, a reflection prompt, or just some encouragement?";
  }
}
