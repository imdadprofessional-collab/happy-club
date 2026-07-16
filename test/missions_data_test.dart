import 'package:flutter_test/flutter_test.dart';
import 'package:happy_club/data/missions_data.dart';
import 'package:happy_club/models/mission.dart';

void main() {
  test('mission library has 200+ missions across every category', () {
    expect(MissionsData.all.length, greaterThanOrEqualTo(200));

    final ids = MissionsData.all.map((m) => m.id).toSet();
    expect(
      ids.length,
      MissionsData.all.length,
      reason: 'mission ids must be unique',
    );

    for (final category in MissionCategory.values) {
      final count = MissionsData.all
          .where((m) => m.category == category)
          .length;
      expect(
        count,
        greaterThanOrEqualTo(5),
        reason: '${category.label} needs enough missions to avoid repeats',
      );
    }
  });
}
