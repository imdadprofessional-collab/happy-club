import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:happy_club/main.dart';

void main() {
  testWidgets('Happy Club boots to the onboarding welcome screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const HappyClubApp());

    // First frame shows the splash while storage/state initializes.
    await tester.pump();
    // Allow the async bootstrap (SharedPreferences + AppState.init) to complete.
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Happy Club'), findsOneWidget);
    expect(find.text('Start My Journey'), findsOneWidget);
  });
}
