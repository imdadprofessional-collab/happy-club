import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Slim animated progress bar showing XP progress toward the next level.
class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.progress, this.height = 10});

  /// 0.0 - 1.0
  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF0E6DC),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) =>
                Opacity(opacity: value, child: child),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.goldGradient),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
