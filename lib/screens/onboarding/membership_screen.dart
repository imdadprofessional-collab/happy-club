import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/primary_button.dart';

/// The upgrade paywall. No longer a hard gate in onboarding — this is
/// pushed on top of whatever screen the user is already on (a post-
/// engagement prompt from the home screen, or a manual tap from their
/// profile), so both the purchase and "not now" paths simply pop back.
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key, this.contextLine});

  /// Optional strap-line shown above the pitch card, used to make the
  /// engagement-triggered prompt feel earned rather than generic — e.g.
  /// "You've completed 3 missions — nice momentum! 🎉".
  final String? contextLine;

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  bool _purchasing = false;

  static const _benefits = [
    ('Real AI Happiness Coach', Icons.psychology_alt_rounded),
    ('Happiness Trends & Analytics', Icons.insights_rounded),
    ('Streak Freeze (protect your streak)', Icons.ac_unit_rounded),
    ('Exclusive Frames & Cosmetics', Icons.auto_awesome_rounded),
    ('Early Access to Monthly Events', Icons.event_available_rounded),
    ('Founding Member Badge', Icons.workspace_premium_rounded),
  ];

  Future<void> _unlock() async {
    setState(() => _purchasing = true);
    final appState = context.read<AppState>();
    final success = await appState.purchaseMembership(MembershipPlan.trial);
    if (!mounted) return;
    setState(() => _purchasing = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome aboard! Your first month is unlocked.'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.contextLine != null) ...[
                GradientCard(
                  colors: AppColors.growthGradient,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Text(
                    widget.contextLine!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              GradientCard(
                colors: AppColors.heroGradient,
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Text('😊', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    Text(
                      'Buy Yourself a Smile',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Only \$1 for your first month.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Join thousands of members committed to building healthier habits '
                      'and supporting one another through daily positive actions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'What you unlock',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ..._benefits.map(
                (b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(b.$2, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          b.$1,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.mint,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _purchasing
                    ? 'Unlocking…'
                    : 'Unlock My First Month — \$1',
                onPressed: _purchasing ? null : _unlock,
              ),
              const SizedBox(height: 10),
              Text(
                'Renews at \$4.99/month after your first month, or switch to \$39.99/year anytime. Cancel anytime.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _purchasing
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Not now, maybe later'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
