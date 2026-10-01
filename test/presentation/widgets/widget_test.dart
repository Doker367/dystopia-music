import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dystopia/presentation/widgets/loading_view.dart';
import 'package:dystopia/presentation/widgets/error_view.dart';
import 'package:dystopia/presentation/widgets/empty_view.dart';

void main() {
  Widget createWidgetUnderTest(Widget widget) {
    return MaterialApp(home: Scaffold(body: widget));
  }

  testWidgets('LoadingView renders', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const LoadingView()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ErrorView shows message and retry button', (WidgetTester tester) async {
    bool retryPressed = false;
    await tester.pumpWidget(createWidgetUnderTest(
      ErrorView(
        message: 'Something went wrong',
        onRetry: () => retryPressed = true,
      ),
    ));

    expect(find.text('Something went wrong'), findsOneWidget);
    
    final retryButton = find.byType(ElevatedButton);
    expect(retryButton, findsOneWidget);
    
    await tester.tap(retryButton);
    expect(retryPressed, true);
  });

  testWidgets('EmptyView shows message', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      const EmptyView(message: 'No items found', icon: Icons.album),
    ));

    expect(find.text('No items found'), findsOneWidget);
  });
}
