import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Large, thumb-friendly call-to-action button with a gentle gradient and
/// haptic tap feedback — used for the app's primary "do the thing" moments.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppColors.heroGradient,
    this.expand = true,
    this.textColor = Colors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final List<Color> gradient;
  final bool expand;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final button = Container(
      height: 58,
      width: expand ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: disabled
            ? null
            : LinearGradient(
                colors: gradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: disabled
            ? Theme.of(context).disabledColor.withValues(alpha: 0.2)
            : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: gradient.last.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          onTap: disabled
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onPressed!();
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return button;
  }
}
