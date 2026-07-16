import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/quotes_data.dart';
import '../../models/mission.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/streak_flame.dart';
import '../../widgets/xp_bar.dart';
import '../feed/post_card.dart';
import 'mission_completion_screen.dart';
import 'mood_checkin_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptMood());
  }

  void _maybePromptMood() {
    final appState = context.read<AppState>();
    if (appState.todayMoodBefore == null && !appState.todayMissionCompleted) {
      MoodCheckinSheet.show(
        context,
        title: 'How are you feeling today?',
        onSelected: (v) => appState.recordMoodBefore(v),
      );
    }
  }

  Future<void> _completeMission(AppState appState) async {
    if (appState.todayMoodAfter == null) {
      await MoodCheckinSheet.show(
        context,
        title: 'How do you feel now?',
        onSelected: (v) => appState.recordMoodAfter(v),
      );
    }
    if (!mounted) return;
    final result = await appState.completeTodayMission();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MissionCompletionScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final mission = appState.todayMission;
    final completed = appState.todayMissionCompleted;
    final quote = QuotesData.forDay(
      DateTime.now().difference(DateTime(DateTime.now().year)).inDays,
    );
    final highlights = appState.posts.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi ${appState.profile.name} ${appState.profile.avatarEmoji}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            appState.levelTitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    StreakFlame(streak: appState.streak),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _StatsRow(appState: appState),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            quote,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (mission != null)
                    _TodayMissionCard(
                      mission: mission,
                      completed: completed,
                      onComplete: () => _completeMission(appState),
                    ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Community Highlights',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...highlights.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PostCard(post: p, compact: true),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(label: 'Level', value: '${appState.level}'),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Happiness',
                  value: appState.happinessScore.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _StatItem(label: 'Streak', value: '${appState.streak}d'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('XP', style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Text(
                '${appState.xp} total',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          XpBar(progress: appState.levelProgress),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _TodayMissionCard extends StatelessWidget {
  const _TodayMissionCard({
    required this.mission,
    required this.completed,
    required this.onComplete,
  });

  final Mission mission;
  final bool completed;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mission.category.color,
            mission.category.color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: mission.category.color.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(mission.category.icon, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      mission.category.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Today\'s Mission',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            mission.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          if (completed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Completed for today',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            PrimaryButton(
              label: 'Complete Today\'s Mission',
              icon: Icons.check_rounded,
              gradient: const [Colors.white, Colors.white],
              textColor: mission.category.color,
              onPressed: onComplete,
            ),
        ],
      ),
    );
  }
}
