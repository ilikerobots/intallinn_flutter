import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intallinn_app/main.dart' as intallinn_main;

void main() {
  TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is LiveTestWidgetsFlutterBinding)
    binding.allowAllFrames = true;

  testWidgets('InTallinn app simple smoke test', (WidgetTester tester) async {
    intallinn_main.main(); // builds the app and schedules a frame but doesn't trigger one
    await tester.pump(); // see https://github.com/flutter/flutter/issues/1865
    await tester.pump(); // triggers a frame

    Finder finder = find.byWidgetPredicate((Widget widget) {
      return widget is Tooltip && widget.message == 'Open navigation menu';
    });
    expect(finder, findsOneWidget);

    // Open drawer
    await tester.tap(finder);
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1)); // end animation

    // Change theme
    await tester.tap(find.byType(Switch));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1)); // end animation

    // Close drawer
    await tester.tap(find.byType(DrawerController));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1)); // end animation

    // Open Demos
    await tester.tap(find.text('Sightseeing'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Transport'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Airport'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byType(RichText).first);
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1));

    // Scroll it up
    await tester.scroll(find.byType(RichText).first, const Offset(0.0, -50.0));
    await tester.pump(const Duration(milliseconds: 200));

    await tester.pump(const Duration(hours: 100)); // for testing
  });
}
