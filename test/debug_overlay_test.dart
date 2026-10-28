import 'package:iphone_duo/iphone_duo.dart';
import 'package:iphone_duo/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    DuoSimulator simulator, {
    bool enabled = true,
  }) =>
      tester.pumpWidget(
        simulator.scope(
          child: DuoDebugOverlay(enabled: enabled, child: const SizedBox()),
        ),
      );

  testWidgets('it names the posture, the column and the window', (
    tester,
  ) async {
    await pump(tester, DuoSimulator.tabletop);
    expect(
        find.text('tabletop · column: none · 669×951 · iOS'), findsOneWidget);

    await pump(tester, DuoSimulator.closed);
    expect(find.text('closed · column: right · 466×678 · iOS'), findsOneWidget);

    await pump(tester, DuoSimulator.phone);
    expect(
      find.text('no hinge · column: none · 390×844 · safe area'),
      findsOneWidget,
    );
  });

  testWidgets('off, it draws nothing', (tester) async {
    await pump(tester, DuoSimulator.tabletop, enabled: false);
    expect(find.byType(CustomPaint), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('it takes no taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      DuoSimulator.closed.scope(
        child: DuoDebugOverlay(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
          ),
        ),
      ),
    );
    await tester.tapAt(const Offset(200, 300));
    expect(taps, 1);
  });

  testWidgets('DuoScope keeps the app as the overlay is turned on', (
    tester,
  ) async {
    Future<void> pumpScope(bool show) => tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => DuoScope(
              lockPhonesUpright: false,
              debugShowRegions: show,
              child: child!,
            ),
            home: const _Counter(),
          ),
        );
    await pumpScope(false);
    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await pumpScope(true);
    expect(find.text('1'), findsOneWidget);
    expect(find.textContaining('column:'), findsOneWidget);
  });
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  var _count = 0;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => setState(() => _count++),
        child: Text('$_count'),
      );
}
