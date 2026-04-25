// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:expense_calculator/main.dart';
import 'package:expense_calculator/services/firestore_service.dart';
import 'package:expense_calculator/models/expense.dart';

// Mock FirestoreService
class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Stream<List<Expense>> getExpenses() => Stream.value([]);

  @override
  Future<void> addExpense(Expense expense) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App builds without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      Provider<FirestoreService>(
        create: (_) => MockFirestoreService(),
        child: const MyApp(),
      ),
    );

    // Wait for Firebase initialization and any async operations
    await tester.pumpAndSettle();

    // Verify that the app has loaded and shows the home screen
    expect(find.text('Home'), findsOneWidget);
  });
}
