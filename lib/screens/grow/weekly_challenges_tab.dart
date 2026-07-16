import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';

class _WeeklyTheme {
  const _WeeklyTheme(this.title, this.emoji, this.gradient);
  final String title;
  final String emoji;
  final List<Color> gradient;
}

const _weeklyThemes = [
  _WeeklyTheme('Kindness Week', '💛', AppColors.heroGradient),
  _WeeklyTheme('Reading Week', '📚', AppColors.calmGradient),
  _WeeklyTheme('Fitness Week', '🏃', AppColors.growthGradient),
  _WeeklyTheme('Hydration Week', '💧', AppColors.calmGradient),
  _WeeklyTheme('Family Week', '🏡', AppColors.heroGradient),
  _WeeklyTheme('Mindfulness Week', '🧘', AppColors.growthGradient),
  _WeeklyTheme('Digital Detox Week', '📵', AppColors.goldGradient),
];

class _CommunityChallenge {
  const _CommunityChallenge(this.title, this.icon, this.target);
  final String title;
  final IconData icon;
  final int target;
}

const _communityChallenges = [
  _CommunityChallenge(
    '100,000 Acts of Kindness',
    Icons.volunteer_activism_rounded,
    100000,
  ),
  _CommunityChallenge(
    '10,000 Gratitude Entries',
    Icons.favorite_rounded,
    10000,
  ),
  _CommunityChallenge(
    '50,000 Reading Sessions',
    Icons.menu_book_rounded,
    50000,
  ),
  _CommunityChallenge(
    'Global Walking Challenge',
    Icons.directions_walk_rounded,
    1000000,
  ),
];

class WeeklyChallengesTab extends StatelessWidget {
  const WeeklyChallengesTab({super.key});

  int _weekOfYear(DateTime date) =>
      ((date.difference(DateTime(date.year, 1, 1)).inDays) / 7).floor();

  int _mockProgress(int target, int seed) {
    final now = DateTime.now();
    final dayFactor = now.difference(DateTime(now.year, 1, 1)).inDays;
    final pct = (0.35 + 0.5 * ((dayFactor + seed * 17) % 100) / 100).clamp(
      0.1,
      0.95,
    );
    return (target * pct).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        _weeklyThemes[_weekOfYear(DateTime.now()) % _weeklyThemes.length];
    final monthName = _monthName(DateTime.now().month);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        GradientCard(
          colors: theme.gradient,
          child: Row(
            children: [
              Text(theme.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Week',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      theme.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Row(
            children: [
              const Icon(
                Icons.event_available_rounded,
                color: AppColors.violet,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$monthName Event',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Limited-time missions & badges all month long.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Community Challenges',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'The whole club working toward shared goals together.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        ...List.generate(_communityChallenges.length, (i) {
          final c = _communityChallenges[i];
          final progress = _mockProgress(c.target, i);
          final pct = progress / c.target;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(c.icon, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          c.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation(AppColors.mint),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$progress / ${c.target}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _monthName(int month) => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
}
