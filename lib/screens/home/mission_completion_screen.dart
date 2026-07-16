import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/primary_button.dart';
import 'auto_post_composer_sheet.dart';

class MissionCompletionScreen extends StatefulWidget {
  const MissionCompletionScreen({super.key, required this.result});

  final MissionRewardResult result;

  @override
  State<MissionCompletionScreen> createState() =>
      _MissionCompletionScreenState();
}

class _MissionCompletionScreenState extends State<MissionCompletionScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    HapticFeedback.heavyImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    '🎉',
                    style: const TextStyle(fontSize: 72),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Text(
                    'Mission Complete!',
                    style: Theme.of(context).textTheme.displayMedium,
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    r.completedMission.missionTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _RewardTile(
                          label: 'XP',
                          value: '+${r.xpEarned}',
                          icon: Icons.bolt_rounded,
                          gradient: AppColors.goldGradient,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RewardTile(
                          label: 'Coins',
                          value: '+${r.coinsEarned}',
                          icon: Icons.monetization_on_rounded,
                          gradient: AppColors.growthGradient,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RewardTile(
                          label: 'Streak',
                          value: '${r.newStreak} days',
                          icon: Icons.local_fire_department_rounded,
                          gradient: AppColors.heroGradient,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.15, end: 0),
                  if (r.isSurpriseBonus) ...[
                    const SizedBox(height: 16),
                    GradientCard(
                      colors: AppColors.goldGradient,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Surprise bonus! Extra XP and coins just for you.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 450.ms).scale(),
                  ],
                  if (r.leveledUp) ...[
                    const SizedBox(height: 16),
                    GradientCard(
                      colors: AppColors.calmGradient,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Level up! You\'ve grown stronger on your journey.',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).scale(),
                  ],
                  if (r.newlyUnlocked.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'New Achievement${r.newlyUnlocked.length > 1 ? 's' : ''}!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...r.newlyUnlocked.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GradientCard(
                          colors: a.gradient,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(a.icon, color: Colors.white, size: 28),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      a.description,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Share Your Win',
                    icon: Icons.campaign_rounded,
                    onPressed: () async {
                      final appState = context.read<AppState>();
                      final text = appState.buildAutoPostText(
                        r.completedMission,
                      );
                      await AutoPostComposerSheet.show(
                        context,
                        initialText: text,
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirection: pi / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 18,
            maxBlastForce: 22,
            minBlastForce: 10,
            gravity: 0.25,
            shouldLoop: false,
            colors: const [
              AppColors.sunrise,
              AppColors.coral,
              AppColors.amber,
              AppColors.violet,
              AppColors.mint,
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gradient.last.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: gradient).createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
