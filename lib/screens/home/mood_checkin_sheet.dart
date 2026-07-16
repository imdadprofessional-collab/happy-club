import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

const _moodEmojis = ['😔', '😐', '🙂', '😁', '🤩'];

class MoodCheckinSheet extends StatelessWidget {
  const MoodCheckinSheet({
    super.key,
    required this.title,
    required this.onSelected,
  });

  final String title;
  final ValueChanged<int> onSelected;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required ValueChanged<int> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MoodCheckinSheet(title: title, onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_moodEmojis.length, (i) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onSelected(i);
                },
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.moodColors[i].withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _moodEmojis[i],
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

String moodEmoji(int value) =>
    _moodEmojis[value.clamp(0, _moodEmojis.length - 1)];
