import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// A small animated flame + streak count, the app's signature "don't break
/// the chain" indicator.
class StreakFlame extends StatelessWidget {
  const StreakFlame({
    super.key,
    required this.streak,
    this.size = 22,
    this.freezes = 0,
    this.onTapFreezes,
  });

  final int streak;
  final double size;

  /// Number of streak freezes the user is holding. Shown as a small
  /// snowflake chip next to the flame when > 0 — a visible reminder of the
  /// safety net so losing it (or wanting more) stays top of mind.
  final int freezes;
  final VoidCallback? onTapFreezes;

  @override
  Widget build(BuildContext context) {
    final lit = streak > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
              Icons.local_fire_department_rounded,
              color: lit
                  ? AppColors.sunrise
                  : Theme.of(context).colorScheme.outline,
              size: size,
            )
            .animate(onPlay: (c) => lit ? c.repeat(reverse: true) : null)
            .scaleXY(
              begin: 1,
              end: lit ? 1.12 : 1,
              duration: 900.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(width: 4),
        Text(
          '$streak',
          style: TextStyle(
            fontSize: size * 0.8,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        if (freezes > 0) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onTapFreezes,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF4FACFE).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.ac_unit_rounded,
                    size: 14,
                    color: Color(0xFF4FACFE),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$freezes',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4FACFE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
