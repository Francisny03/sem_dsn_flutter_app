import 'package:flutter_test/flutter_test.dart';
import 'package:sem_dsn/main.dart';

void main() {
  testWidgets('App démarre et affiche SEM DSN', (WidgetTester tester) async {
    await tester.pumpWidget(const SemDsnApp());
    expect(find.text('SEM DSN'), findsWidgets);
  });
}
