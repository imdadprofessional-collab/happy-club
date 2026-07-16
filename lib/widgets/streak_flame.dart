import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// A small animated flame + streak count, the app's signature "don't break
/// the chain" indicator.
class StreakFlame extends StatelessWidget {
  const StreakFlame({super.key, required this.streak, this.size = 22});

  final int streak;
  final double size;

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
      ],
    );
  }
}
