import 'package:flutter/material.dart';
import 'gratitude_journal_tab.dart';
import 'happiness_calendar_tab.dart';
import 'reflection_journal_tab.dart';
import 'weekly_challenges_tab.dart';

class GrowHubScreen extends StatelessWidget {
  const GrowHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grow'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Gratitude'),
              Tab(text: 'Reflection'),
              Tab(text: 'Calendar'),
              Tab(text: 'Challenges'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GratitudeJournalTab(),
            ReflectionJournalTab(),
            HappinessCalendarTab(),
            WeeklyChallengesTab(),
          ],
        ),
      ),
    );
  }
}
