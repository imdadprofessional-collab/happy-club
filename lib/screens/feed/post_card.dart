import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mission.dart';
import '../../models/post.dart';
import '../../services/moderation_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.compact = false});

  final Post post;
  final bool compact;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: (post.category?.color ?? AppColors.primary)
                    .withValues(alpha: 0.15),
                child: Text(
                  post.authorEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        if (post.dayStreak != null) ...[
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 13,
                            color: AppColors.sunrise,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Day ${post.dayStreak}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const Text(
                            ' · ',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                        Text(
                          _timeAgo(post.postedAt),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.text, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 14),
          if (!compact) _ReactionBar(post: post),
          if (!compact && post.comments.isNotEmpty) ...[
            const Divider(height: 24),
            ...post.comments
                .take(2)
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${c.authorName}  ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).textTheme.titleMedium?.color,
                            ),
                          ),
                          TextSpan(text: c.text),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
          if (!compact) ...[
            const SizedBox(height: 4),
            _CommentComposer(post: post),
          ],
        ],
      ),
    );
  }
}

class _ReactionBar extends StatelessWidget {
  const _ReactionBar({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReactionType.values.map((r) {
        final count = post.reactionCounts[r] ?? 0;
        final active = post.userReaction == r;
        return GestureDetector(
          onTap: () => appState.reactToPost(post, r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
              border: active
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(r.emoji, style: const TextStyle(fontSize: 14)),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CommentComposer extends StatefulWidget {
  const _CommentComposer({required this.post});

  final Post post;

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _controller = TextEditingController();
  String? _error;

  void _submit() {
    final error = ModerationService.validate(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    context.read<AppState>().addComment(widget.post, _controller.text.trim());
    _controller.clear();
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Add an encouraging comment…',
              errorText: _error,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send_rounded, color: AppColors.primary),
          onPressed: _submit,
        ),
      ],
    );
  }
}
