import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/moderation_service.dart';
import '../../state/app_state.dart';
import '../../widgets/primary_button.dart';

class AutoPostComposerSheet extends StatefulWidget {
  const AutoPostComposerSheet({super.key, required this.initialText});

  final String initialText;

  static Future<void> show(
    BuildContext context, {
    required String initialText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AutoPostComposerSheet(initialText: initialText),
    );
  }

  @override
  State<AutoPostComposerSheet> createState() => _AutoPostComposerSheetState();
}

class _AutoPostComposerSheetState extends State<AutoPostComposerSheet> {
  late final TextEditingController _controller;
  String? _error;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final error = ModerationService.validate(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() => _posting = true);
    await context.read<AppState>().publishAutoPost(_controller.text.trim());
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Shared with Happy Club! 🎉')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Share Your Win',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Edit your post before sharing it with the club.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 6,
              minLines: 4,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                errorText: _error,
                hintText: 'Share what today\'s mission meant to you…',
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: _posting ? 'Posting…' : 'Post to Happy Feed',
              icon: Icons.send_rounded,
              onPressed: _posting ? null : _post,
            ),
          ],
        ),
      ),
    );
  }
}
