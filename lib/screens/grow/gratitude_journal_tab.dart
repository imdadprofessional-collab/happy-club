import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';

class GratitudeJournalTab extends StatefulWidget {
  const GratitudeJournalTab({super.key});

  @override
  State<GratitudeJournalTab> createState() => _GratitudeJournalTabState();
}

class _GratitudeJournalTabState extends State<GratitudeJournalTab> {
  final _controllers = List.generate(3, (_) => TextEditingController());
  bool _isPublic = false;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final items = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (items.isEmpty) return;
    final appState = context.read<AppState>();
    await appState.addGratitudeEntry(items, isPublic: _isPublic);
    if (_isPublic) {
      await appState.publishAutoPost(
        '🙏 Today I\'m grateful for:\n${items.map((e) => '• $e').join('\n')}\n\n#HappyClub',
      );
    }
    for (final c in _controllers) {
      c.clear();
    }
    setState(() => _isPublic = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gratitude entry saved 🌿')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final entries = appState.gratitudeEntries.where((e) {
      if (_query.isEmpty) return true;
      return e.items.any((i) => i.toLowerCase().contains(_query.toLowerCase()));
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Three things I\'m grateful for',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _controllers[i],
                    decoration: InputDecoration(hintText: 'Gratitude ${i + 1}'),
                  ),
                ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Share to Happy Feed'),
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
              ),
              const SizedBox(height: 6),
              PrimaryButton(
                label: 'Save Entry',
                icon: Icons.favorite_rounded,
                onPressed: _save,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Search past entries…',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No entries yet — your gratitude journal starts today.',
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
                    Row(
                      children: [
                        Text(
                          DateFormat.yMMMd().format(e.date),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        if (e.isPublic) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.public_rounded, size: 13),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...e.items.map(
                      (i) => Text(
                        '• $i',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
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
