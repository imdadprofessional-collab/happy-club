import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';

class ReflectionJournalTab extends StatefulWidget {
  const ReflectionJournalTab({super.key});

  @override
  State<ReflectionJournalTab> createState() => _ReflectionJournalTabState();
}

class _ReflectionJournalTabState extends State<ReflectionJournalTab> {
  final _meaningful = TextEditingController();
  final _proud = TextEditingController();
  final _improve = TextEditingController();

  @override
  void dispose() {
    _meaningful.dispose();
    _proud.dispose();
    _improve.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_meaningful.text.trim().isEmpty &&
        _proud.text.trim().isEmpty &&
        _improve.text.trim().isEmpty) {
      return;
    }
    await context.read<AppState>().addReflectionEntry(
      meaningful: _meaningful.text.trim(),
      proud: _proud.text.trim(),
      improve: _improve.text.trim(),
    );
    _meaningful.clear();
    _proud.clear();
    _improve.clear();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reflection saved 🌙')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<AppState>().reflectionEntries;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evening Reflection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              _Prompt(
                label: 'What made today meaningful?',
                controller: _meaningful,
              ),
              const SizedBox(height: 12),
              _Prompt(
                label: 'What are you proud of today?',
                controller: _proud,
              ),
              const SizedBox(height: 12),
              _Prompt(
                label: 'What will you improve tomorrow?',
                controller: _improve,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Save Reflection',
                icon: Icons.nights_stay_rounded,
                onPressed: _save,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No reflections yet — take a moment tonight.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          ...entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMd().format(e.date),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    if (e.meaningful.isNotEmpty)
                      Text(
                        'Meaningful: ${e.meaningful}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    if (e.proud.isNotEmpty)
                      Text(
                        'Proud of: ${e.proud}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    if (e.improve.isNotEmpty)
                      Text(
                        'Improve: ${e.improve}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Prompt extends StatelessWidget {
  const _Prompt({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        TextField(controller: controller, maxLines: 2),
      ],
    );
  }
}
