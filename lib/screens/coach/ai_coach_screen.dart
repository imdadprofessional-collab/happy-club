import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ai_backend_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';

class _ChatMessage {
  const _ChatMessage(this.text, this.fromCoach);
  final String text;
  final bool fromCoach;
}

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final List<_ChatMessage> _messages = [];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _backend = AiBackendService();
  bool _greeted = false;
  bool _thinking = false;

  void _greet(AppState appState) {
    if (_greeted) return;
    _greeted = true;
    _messages.add(
      _ChatMessage(
        appState.aiCoach.dailyEncouragement(
          name: appState.profile.name,
          streak: appState.streak,
        ),
        true,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _thinking) return;
    final appState = context.read<AppState>();
    setState(() {
      _messages.add(_ChatMessage(trimmed, false));
      _thinking = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Real Gemini-backed reply when signed in and the backend is reachable;
    // otherwise the offline template coach, which always works.
    final reply = appState.isSignedIn
        ? await _backend.chat(
            message: trimmed,
            name: appState.profile.name,
            streak: appState.streak,
            happinessScore: appState.happinessScore,
          )
        : null;

    if (!mounted) return;
    setState(() {
      _thinking = false;
      _messages.add(
        _ChatMessage(reply ?? appState.aiCoach.respond(trimmed), true),
      );
    });
    _scrollToBottom();
  }

  void _quickAction(AppState appState, String label) {
    String reply;
    switch (label) {
      case 'Reflection prompt':
        reply = appState.aiCoach.reflectionPrompt();
        break;
      case 'Weekly summary':
        reply = appState.aiCoach.weeklySummary(
          missionsCompleted: appState.completedMissions
              .where(
                (m) => DateTime.now().difference(m.completedAt).inDays <= 7,
              )
              .length,
          streak: appState.streak,
          happinessScore: appState.happinessScore,
        );
        break;
      case 'Suggest a mission':
      default:
        final recent = appState.completedMissions.isNotEmpty
            ? appState.completedMissions.first.category
            : appState.todayMission?.category;
        reply = recent != null
            ? appState.aiCoach.missionSuggestion(recent)
            : 'Try starting with a gratitude mission today — it\'s a gentle way to begin.';
    }
    setState(() {
      _messages.add(_ChatMessage(label, false));
      _messages.add(_ChatMessage(reply, true));
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    _greet(appState);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Happiness Coach')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_thinking ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return const _MessageBubble(
                    message: _ChatMessage('Thinking…', true),
                  );
                }
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children:
                  ['Suggest a mission', 'Reflection prompt', 'Weekly summary']
                      .map(
                        (label) => Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 8),
                          child: ActionChip(
                            label: Text(label),
                            onPressed: () => _quickAction(appState, label),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_thinking,
                      decoration: const InputDecoration(
                        hintText: 'Talk to your coach…',
                      ),
                      onSubmitted: (value) => _send(value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: _thinking ? null : () => _send(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isCoach = message.fromCoach;
    return Align(
      alignment: isCoach ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: isCoach
              ? null
              : const LinearGradient(colors: AppColors.heroGradient),
          color: isCoach
              ? Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isCoach ? 4 : 18),
            bottomRight: Radius.circular(isCoach ? 18 : 4),
          ),
        ),
        child: Text(
          message.text,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: isCoach ? null : Colors.white),
        ),
      ),
    );
  }
}
