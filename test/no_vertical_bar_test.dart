import 'package:iphone_duo/iphone_duo.dart';
import 'package:iphone_duo/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  final ios = TargetPlatformVariant.only(TargetPlatform.iOS);
  late List<bool> asked;
  var taken = true;

  setUp(() {
    NoVerticalBar.debugReset();
    asked = [];
    taken = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('iphone_duo'),
            (call) async {
      if (call.method == 'setVerticalBarDisabled') {
        asked.add(call.arguments as bool);
        return taken;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('iphone_duo'), null);
  });

  Future<void> push(WidgetTester tester, Widget page) async {
    Navigator.of(tester.element(find.byType(Scaffold).last))
        .push(MaterialPageRoute<void>(builder: (_) => page));
    await tester.pumpAndSettle();
  }

  testWidgets('while the screen shows, iOS keeps the bars across', (
    tester,
  ) async {
    await pumpIn(tester, DuoSimulator.closed, const Scaffold(body: Text('A')));
    expect(asked, isEmpty);

    await push(tester, const NoVerticalBar(child: Scaffold(body: Text('B'))));
    expect(asked, [true]);

    Navigator.of(tester.element(find.text('B'))).pop();
    await tester.pumpAndSettle();
    expect(asked, [true, false]);
  }, variant: ios);

  testWidgets('covered by a page of its own, the column comes back', (
    tester,
  ) async {
    await pumpIn(
      tester,
      DuoSimulator.closed,
      const NoVerticalBar(child: Scaffold(body: Text('A'))),
    );
    await tester.pump();
    expect(asked, [true]);

    await push(tester, const Scaffold(body: Text('B')));
    expect(asked, [true, false]);
  }, variant: ios);

  testWidgets('from one such screen to the next, nothing in between', (
    tester,
  ) async {
    await pumpIn(
      tester,
      DuoSimulator.closed,
      const NoVerticalBar(child: Scaffold(body: Text('A'))),
    );
    await tester.pump();
    await push(tester, const NoVerticalBar(child: Scaffold(body: Text('B'))));
    expect(asked, [true]);
  }, variant: ios);

  testWidgets('off iOS it asks nothing', (tester) async {
    await pumpIn(
      tester,
      DuoSimulator.phone,
      const NoVerticalBar(child: Scaffold(body: Text('A'))),
    );
    await tester.pump();
    expect(asked, isEmpty);
  });
}
