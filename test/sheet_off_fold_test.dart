import 'package:iphone_duo/iphone_duo.dart';
import 'package:iphone_duo/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  const content = Key('content');

  Future<Rect> open(
    WidgetTester tester,
    DuoSimulator simulator, {
    TextDirection direction = TextDirection.ltr,
    double height = 2000,
  }) async {
    await pumpIn(
      tester,
      simulator,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showModalBottomSheetOffFold<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: SizedBox(
                key: content,
                width: double.infinity,
                height: height,
              ),
            ),
          ),
          child: const Text('open'),
        ),
      ),
      direction: direction,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return tester.getRect(find.byKey(content));
  }

  /// The card the sheet is drawn on: the nearest [Material] around it.
  Rect sheet(WidgetTester tester) => tester.getRect(
        find
            .ancestor(of: find.byKey(content), matching: find.byType(Material))
            .first,
      );

  testWidgets('open upright, no taller than the half under the fold', (
    tester,
  ) async {
    await open(tester, DuoSimulator.upright);
    final rect = sheet(tester);
    expect(rect.top, greaterThanOrEqualTo(495.5));
    expect(rect.bottom, 951);
  });

  testWidgets('a short sheet keeps its own height', (tester) async {
    await open(tester, DuoSimulator.tabletop, height: 200);
    expect(sheet(tester).height, 200);
  });

  testWidgets('on its side, in the end half, from the fold', (tester) async {
    await open(tester, DuoSimulator.onItsSide);
    final rect = sheet(tester);
    expect(rect.left, 475.5);
    expect(rect.right, 951);
  });

  testWidgets('beside the column, its content keeps clear of it', (
    tester,
  ) async {
    final rect = await open(tester, DuoSimulator.onItsSide);
    expect(rect.right, 951 - 84);
  });

  testWidgets('in Arabic, the end half is the left one', (tester) async {
    final inside = await open(
      tester,
      DuoSimulator.onItsSide,
      direction: TextDirection.rtl,
    );
    final rect = sheet(tester);
    expect(rect.left, 0);
    expect(rect.right, 475.5);
    // The column is down the other half: nothing of this one is given to it.
    expect(inside.right, 475.5);
  });

  testWidgets('a tap on the other half closes it', (tester) async {
    await open(tester, DuoSimulator.onItsSide, height: 200);
    await tester.tapAt(const Offset(200, 600));
    await tester.pumpAndSettle();
    expect(find.byKey(content), findsNothing);
  });

  testWidgets('on an iPad, the end half of the window', (tester) async {
    await open(tester, DuoSimulator.iPad);
    final rect = sheet(tester);
    expect(rect.left, 597);
    expect(rect.right, 1194);
  });

  testWidgets('on a phone, the sheet Flutter opens', (tester) async {
    await open(tester, DuoSimulator.phone, height: 200);
    final rect = sheet(tester);
    expect(rect.left, 0);
    expect(rect.right, 390);
    expect(rect.bottom, 844);
  });
}
