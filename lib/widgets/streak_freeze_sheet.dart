import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'primary_button.dart';

/// Bottom sheet explaining streak freezes and letting free users buy one
/// with coins instead of subscribing — a small monetization lever that
/// also keeps non-payers engaged.
class StreakFreezeSheet extends StatelessWidget {
  const StreakFreezeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const StreakFreezeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final canAfford = appState.coins >= AppState.streakFreezeCoinCost;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.ac_unit_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streak Freezes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'You have ${appState.streakFreezes}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Miss a day and a streak freeze automatically covers the gap, '
              'so your streak keeps going. Members get one free with every '
              'renewal — everyone else can buy one with coins.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: canAfford
                  ? 'Buy 1 Freeze — ${AppState.streakFreezeCoinCost} coins'
                  : 'Need ${AppState.streakFreezeCoinCost} coins',
              icon: Icons.monetization_on_rounded,
              onPressed: canAfford
                  ? () async {
                      final success = await appState.buyStreakFreeze();
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Streak freeze added!'
                                : "Couldn't complete purchase.",
                          ),
                        ),
                      );
                    }
                  : null,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
