import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/mission.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_card.dart';

class HappinessCalendarTab extends StatefulWidget {
  const HappinessCalendarTab({super.key});

  @override
  State<HappinessCalendarTab> createState() => _HappinessCalendarTabState();
}

class _HappinessCalendarTabState extends State<HappinessCalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final byDay = <String, CompletedMission>{};
    for (final m in appState.completedMissions) {
      byDay.putIfAbsent(_key(m.completedAt), () => m);
    }
    final selected = _selectedDay != null ? byDay[_key(_selectedDay!)] : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(8),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            calendarStyle: const CalendarStyle(outsideDaysVisible: false),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) =>
                  _buildDay(context, day, byDay),
              todayBuilder: (context, day, focusedDay) =>
                  _buildDay(context, day, byDay, isToday: true),
              selectedBuilder: (context, day, focusedDay) =>
                  _buildDay(context, day, byDay, isSelected: true),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (selected != null)
          GlassCard(
            child: Row(
              children: [
                Icon(selected.category.icon, color: selected.category.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected.missionTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        selected.category.label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else if (_selectedDay != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No mission completed that day.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Colorful days mean you showed up for yourself. Keep the chain going!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDay(
    BuildContext context,
    DateTime day,
    Map<String, CompletedMission> byDay, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final mission = byDay[_key(day)];
    final color = mission?.category.color;
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            color ??
            (isToday
                ? Colors.grey.withValues(alpha: 0.15)
                : Colors.transparent),
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: color != null ? Colors.white : null,
          fontWeight: color != null ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}
