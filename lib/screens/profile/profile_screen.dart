import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/mission.dart';
import '../../services/auth_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/xp_bar.dart';
import '../onboarding/membership_screen.dart';
import 'achievements_screen.dart';
import 'edit_profile_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final recentMissions = appState.completedMissions.take(6).toList();
    final myPosts = appState.posts
        .where((p) => p.isCurrentUser)
        .take(4)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _showThemeSheet(context, appState),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          GradientCard(
            colors: AppColors.heroGradient,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => EditProfileSheet.show(context),
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      appState.profile.avatarEmoji,
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  appState.profile.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Level ${appState.level} · ${appState.levelTitle}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 14),
                XpBar(progress: appState.levelProgress),
                const SizedBox(height: 6),
                Text(
                  '${appState.xp} XP total',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MembershipBadge(status: appState.membershipStatus),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Streak',
                  value: '${appState.streak}d',
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Best Streak',
                  value: '${appState.longestStreak}d',
                  icon: Icons.emoji_events_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Happiness',
                  value: appState.happinessScore.toStringAsFixed(0),
                  icon: Icons.favorite_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievements',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${appState.unlockedAchievementIds.length} unlocked',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AchievementsScreen(),
                    ),
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Mission History',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          if (recentMissions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Your completed missions will show up here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...recentMissions.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(m.category.icon, color: m.category.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          m.missionTitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Text(
                        DateFormat.MMMd().format(m.completedAt),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (myPosts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Recent Posts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...myPosts.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  child: Text(
                    p.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Appearance',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_rounded),
                  ),
                ],
                selected: {appState.themeMode},
                onSelectionChanged: (selection) =>
                    appState.setThemeMode(selection.first),
              ),
              if (appState.isSignedIn) ...[
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Sign Out'),
                  subtitle: const Text('Your data stays saved on this device.'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await AuthService().signOut();
                    appState.detachUser();
                  },
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _MembershipBadge extends StatelessWidget {
  const _MembershipBadge({required this.status});

  final MembershipStatus status;

  @override
  Widget build(BuildContext context) {
    final upgradable = !status.isActive;
    final label = switch (status) {
      MembershipStatus.trialActive => 'First Month Member',
      MembershipStatus.monthly => 'Monthly Member',
      MembershipStatus.yearly => 'Yearly Member',
      MembershipStatus.expired => 'Membership Expired',
      MembershipStatus.none => 'Free Explorer',
    };
    return GestureDetector(
      onTap: upgradable
          ? () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MembershipScreen()),
            )
          : null,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.amber,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleMedium),
            ),
            if (upgradable)
              const Icon(Icons.chevron_right_rounded, color: AppColors.amber),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
