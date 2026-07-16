import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import 'post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<AppState>().posts;
    return Scaffold(
      appBar: AppBar(title: const Text('Happy Feed')),
      body: posts.isEmpty
          ? const Center(
              child: Text(
                'No posts yet. Complete a mission to share your first win!',
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: posts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => PostCard(post: posts[i]),
            ),
    );
  }
}
